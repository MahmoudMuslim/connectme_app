import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/firebase_error_mapper.dart';
import '../../core/result/result.dart';
import '../../domain/entities/community_member.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../models/community_member_model.dart';
import '../models/user_model.dart';

/// Authentication + profile persistence.
///
/// * Firebase mode — the `users` collection is the single source of truth and
///   Firestore streams drive [authStateChanges].
/// * Demo mode — [AuthService] keeps the session in `SharedPreferences` and
///   this repository mirrors the profile document into the same storage so the
///   rest of the app behaves identically.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required this.authService,
    required this.firestoreService,
    required this.preferences,
  });

  final AuthService authService;
  final FirestoreService firestoreService;
  final SharedPreferences preferences;

  @override
  Stream<User?> authStateChanges() => authService.authStateChanges();

  @override
  Future<Result<User?>> restoreSession() async {
    try {
      final User? user = await authService.restoreSession();
      return Success<User?>(user);
    } on Object catch (error) {
      return ResultFailure<User?>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final User user = await authService.signIn(
        email: email,
        password: password,
      );
      final UserModel profile =
          await _readProfile(user.id) ?? UserModel.fromEntity(user);
      final UserModel merged = _merge(profile, user);
      await _writeProfile(merged);
      await authService.updateCurrentSession(merged);
      return Success<User>(merged);
    } on Object catch (error) {
      return ResultFailure<User>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<User>> signUp({
    required String fullName,
    required String email,
    required String password,
    String? deviceModel,
    String? osVersion,
  }) async {
    try {
      final User user = await authService.signUp(
        fullName: fullName,
        email: email,
        password: password,
        deviceModel: deviceModel,
        osVersion: osVersion,
      );
      final UserModel profile = UserModel.fromEntity(user);
      await _writeProfile(profile);
      return Success<User>(profile);
    } on Object catch (error) {
      return ResultFailure<User>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await authService.signOut();
      return const Success<void>(null);
    } on Object catch (error) {
      return ResultFailure<void>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await authService.sendPasswordResetEmail(email: email);
      return const Success<void>(null);
    } on Object catch (error) {
      return ResultFailure<void>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<User>> updateProfilePhoto({
    required String userId,
    required String photoUrl,
  }) async {
    try {
      final UserModel current =
          await _readProfile(userId) ??
          UserModel.fromEntity(authService.currentUser() ?? _anonymous(userId));
      final UserModel updated = current.withPhotoUrl(photoUrl);
      await _writeProfile(updated);
      await authService.updateCurrentSession(updated);
      return Success<User>(updated);
    } on Object catch (error) {
      return ResultFailure<User>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<User>> updateDisplayName({
    required String userId,
    required String fullName,
  }) async {
    try {
      final UserModel current =
          await _readProfile(userId) ??
          UserModel.fromEntity(authService.currentUser() ?? _anonymous(userId));
      final UserModel updated = current.withFullName(fullName);
      await _writeProfile(updated);
      await authService.updateCurrentSession(updated);
      return Success<User>(updated);
    } on Object catch (error) {
      return ResultFailure<User>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<User?>> getUserById(String userId) async {
    try {
      return Success<User?>(await _readProfile(userId));
    } on Object catch (error) {
      return ResultFailure<User?>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> cacheUser(User? user) async {
    try {
      if (user == null) {
        await preferences.remove(AppConstants.localSessionKey);
        return const Success<void>(null);
      }
      await preferences.setString(
        AppConstants.localSessionKey,
        jsonEncode(UserModel.fromEntity(user).toJson()),
      );
      return const Success<void>(null);
    } on Object catch (error) {
      return ResultFailure<void>(FirebaseErrorMapper.map(error));
    }
  }

  @override
  Future<Result<List<CommunityMember>>> getCommunityMembers() async {
    try {
      final String cached =
          preferences.getString(AppConstants.cachedMembersKey) ?? '';
      if (cached.isNotEmpty) {
        return Success<List<CommunityMember>>(
          CommunityMemberModel.listFromCacheJson(cached),
        );
      }
      await preferences.setString(
        AppConstants.cachedMembersKey,
        CommunityMemberModel.seededJson(),
      );
      return Success<List<CommunityMember>>(CommunityMemberModel.seeded);
    } on Object catch (error) {
      return ResultFailure<List<CommunityMember>>(
        FirebaseErrorMapper.map(error),
      );
    }
  }

  // --- Internals -------------------------------------------------------------

  /// Reads a `users/{id}` document, falling back to the local session copy.
  Future<UserModel?> _readProfile(String userId) async {
    if (firestoreService.isReady && userId.isNotEmpty) {
      try {
        final Map<String, dynamic>? data = await firestoreService
            .usersCollection
            .doc(userId)
            .get()
            .then(
              (snapshot) => snapshot.exists && snapshot.data() != null
                  ? <String, dynamic>{...snapshot.data()!, 'id': snapshot.id}
                  : null,
            );
        if (data != null) {
          return UserModel.fromJson(data);
        }
      } on Object {
        // Fall through to the local copy.
      }
    }

    final User? session = authService.currentUser();
    if (session != null && session.id == userId) {
      return UserModel.fromEntity(session);
    }
    return null;
  }

  /// Writes the profile document to Firestore and mirrors it locally.
  Future<void> _writeProfile(UserModel profile) async {
    if (firestoreService.isReady && profile.id.isNotEmpty) {
      try {
        await firestoreService.usersCollection
            .doc(profile.id)
            .set(profile.toJson(), SetOptions(merge: true));
      } on Object {
        // Local mirror below still keeps the UI consistent.
      }
    }
    await preferences.setString(
      AppConstants.localSessionKey,
      jsonEncode(profile.toJson()),
    );
  }

  /// Keeps the freshly authenticated identity while preserving the fields that
  /// only live on the profile document (photo, device info).
  UserModel _merge(UserModel stored, User fresh) {
    return UserModel(
      id: fresh.id,
      fullName: fresh.fullName.isEmpty ? stored.fullName : fresh.fullName,
      email: fresh.email.isEmpty ? stored.email : fresh.email,
      photoUrl: fresh.photoUrl ?? stored.photoUrl,
      deviceModel: stored.deviceModel,
      osVersion: stored.osVersion,
      joinedAt: stored.joinedAt ?? DateTime.now(),
    );
  }

  User _anonymous(String id) =>
      User(id: id, fullName: 'Community member', email: '');
}
