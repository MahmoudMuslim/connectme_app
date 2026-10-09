import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/firebase_error_mapper.dart';
import '../../core/result/result.dart';
import '../../domain/entities/community_member.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../models/community_member_model.dart';
import '../models/user_model.dart';

/// Authentication + profile persistence using Firebase Firestore as the single source of truth.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required this.authService,
    required this.firestoreService,
  });

  final AuthService authService;
  final FirestoreService firestoreService;

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
    // No-op: session is managed by Firebase Auth persistence
    return const Success<void>(null);
  }

  @override
  Future<Result<List<CommunityMember>>> getCommunityMembers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestoreService.usersCollection
              .where('isCommunityMember', isEqualTo: true)
              .get();
      final List<CommunityMember> members = snapshot.docs
          .map((doc) => CommunityMemberModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
      if (members.isEmpty) {
        return Success<List<CommunityMember>>(CommunityMemberModel.seeded);
      }
      return Success<List<CommunityMember>>(members);
    } on Object catch (error) {
      return ResultFailure<List<CommunityMember>>(
        FirebaseErrorMapper.map(error),
      );
    }
  }

  // --- Internals -------------------------------------------------------------

  /// Reads a `users/{id}` document from Firestore.
  Future<UserModel?> _readProfile(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final snapshot = await firestoreService.usersCollection.doc(userId).get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      final Map<String, dynamic> data = {
        ...snapshot.data()!,
        'id': snapshot.id,
      };
      return UserModel.fromJson(data);
    } on Object {
      return null;
    }
  }

  /// Writes the profile document to Firestore.
  Future<void> _writeProfile(UserModel profile) async {
    if (profile.id.isEmpty) return;
    await firestoreService.usersCollection
        .doc(profile.id)
        .set(profile.toJson(), SetOptions(merge: true));
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