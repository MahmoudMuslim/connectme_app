import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';
import '../domain/entities/user.dart';
import 'firestore_service.dart';

/// Authentication gateway.
///
/// Wraps **Firebase Authentication** when the app is built with real
/// credentials. Otherwise it falls back to an equivalent local implementation
/// backed by `SharedPreferences`, so the published beta build stays fully
/// demonstrable without a Firebase project: sign-up, sign-in and session
/// persistence behave identically, only the storage differs.
///
/// The class is a **SINGLETON**: [AuthService.instance] is published exactly
/// once by `injection.dart` after the async `SharedPreferences` handle exists.
class AuthService {
  AuthService._({required this.preferences, required this.firestoreService});

  /// Builds the service. Only the DI container should call it, and publish the
  /// result with [registerInstance] so the singleton is unambiguous.
  factory AuthService.create({
    required SharedPreferences preferences,
    required FirestoreService firestoreService,
  }) {
    return AuthService._(
      preferences: preferences,
      firestoreService: firestoreService,
    );
  }

  static AuthService? _instance;

  final SharedPreferences preferences;

  /// Decides whether Firebase Auth can be reached and keeps the `users`
  /// collection in sync.
  final FirestoreService firestoreService;

  final StreamController<User?> _sessionController =
      StreamController<User?>.broadcast();

  firebase_auth.FirebaseAuth? _firebaseAuth;

  bool _restored = false;

  /// The shared instance.
  ///
  /// Reading it before [registerInstance] is a programming error: the service
  /// needs an already initialised `SharedPreferences`, so the DI container must
  /// publish it first.
  static AuthService get instance {
    final AuthService? service = _instance;
    if (service == null) {
      throw StateError(
        'AuthService.instance was read before injection.registerDependencies() '
        'was awaited.',
      );
    }
    return service;
  }

  /// Publishes the instance built by the DI container.
  static void registerInstance(AuthService service) {
    _instance = service;
  }

  /// Tear-down helper for tests only.
  static void resetForTesting() {
    _instance = null;
  }

  /// `true` when Firebase Authentication is reachable.
  bool get isFirebaseReady => firestoreService.isReady && _authOrNull != null;

  /// `true` when the app falls back to local accounts.
  bool get isDemoMode => !isFirebaseReady;

  /// Firebase Auth handle, `null` in demo mode.
  firebase_auth.FirebaseAuth? get _authOrNull {
    if (!firestoreService.isReady) {
      return null;
    }
    try {
      return _firebaseAuth ??= firebase_auth.FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  /// Broadcast stream of the current session.
  Stream<User?> authStateChanges() {
    final firebase_auth.FirebaseAuth? auth = _authOrNull;
    if (auth != null) {
      return auth.userChanges().map(
        (firebase_auth.User? firebaseUser) =>
            firebaseUser == null ? null : _fromFirebase(firebaseUser),
      );
    }
    return _sessionController.stream;
  }

  /// Restores a previously persisted session exactly once.
  Future<User?> restoreSession() async {
    if (_restored) {
      return currentUser();
    }
    _restored = true;

    final firebase_auth.FirebaseAuth? auth = _authOrNull;
    if (auth != null) {
      final firebase_auth.User? firebaseUser = auth.currentUser;
      return firebaseUser == null ? null : _fromFirebase(firebaseUser);
    }

    final UserModel? cached = _readCachedSession();
    _sessionController.add(cached);
    return cached;
  }

  /// The member currently signed in, `null` when signed out.
  User? currentUser() {
    final firebase_auth.FirebaseAuth? auth = _authOrNull;
    if (auth != null) {
      final firebase_auth.User? firebaseUser = auth.currentUser;
      return firebaseUser == null ? null : _fromFirebase(firebaseUser);
    }
    return _readCachedSession();
  }

  /// Signs in with email + password.
  Future<User> signIn({required String email, required String password}) async {
    final firebase_auth.FirebaseAuth? auth = _authOrNull;
    if (auth != null) {
      final firebase_auth.UserCredential credential = await auth
          .signInWithEmailAndPassword(email: email, password: password);
      final UserModel user = _fromFirebase(credential.user!);
      await _persistSession(user);
      return user;
    }

    final List<String> accounts =
        preferences.getStringList(AppConstants.localAccountsKey) ?? <String>[];
    for (final String entry in accounts) {
      final Map<String, dynamic> account = _decodeAccount(entry);
      if ((account['email'] as String? ?? '').toLowerCase() !=
          email.toLowerCase()) {
        continue;
      }
      if (account['passwordHash'] != _hash(password)) {
        throw firebase_auth.FirebaseAuthException(code: 'wrong-password');
      }
      final UserModel user = UserModel.fromJson(account);
      await _persistSession(user);
      _sessionController.add(user);
      return user;
    }
    throw firebase_auth.FirebaseAuthException(code: 'user-not-found');
  }

  /// Creates a new account.
  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
    String? deviceModel,
    String? osVersion,
  }) async {
    final firebase_auth.FirebaseAuth? auth = _authOrNull;
    if (auth != null) {
      final firebase_auth.UserCredential credential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await auth.currentUser?.updateDisplayName(fullName);
      final UserModel user = _fromFirebase(credential.user!)
          .withDeviceInfo(deviceModel: deviceModel, osVersion: osVersion);
      await _persistSession(user);
      return user;
    }

    final List<String> accounts =
        preferences.getStringList(AppConstants.localAccountsKey) ?? <String>[];
    final bool alreadyExists = accounts.any(
      (String entry) =>
          (_decodeAccount(entry)['email'] as String? ?? '').toLowerCase() ==
          email.toLowerCase(),
    );
    if (alreadyExists) {
      throw firebase_auth.FirebaseAuthException(code: 'email-already-in-use');
    }

    final UserModel user = UserModel.fromFirebase(
      id: _generateId(),
      email: email,
      fullName: fullName,
    ).withDeviceInfo(deviceModel: deviceModel, osVersion: osVersion);

    accounts.add(
      jsonEncode(<String, dynamic>{
        ...user.toJson(),
        'passwordHash': _hash(password),
      }),
    );
    await preferences.setStringList(AppConstants.localAccountsKey, accounts);
    await _persistSession(user);
    _sessionController.add(user);
    return user;
  }

  /// Ends the session on both backends.
  Future<void> signOut() async {
    final firebase_auth.FirebaseAuth? auth = _authOrNull;
    if (auth != null) {
      await auth.signOut();
    }
    await preferences.remove(AppConstants.localSessionKey);
    _sessionController.add(null);
  }

  /// Sends a password-reset email. In demo mode this is a no-op that logs
  /// the request so the UI can display a confirmation.
  Future<void> sendPasswordResetEmail({required String email}) async {
    final firebase_auth.FirebaseAuth? auth = _authOrNull;
    if (auth != null) {
      await auth.sendPasswordResetEmail(email: email.trim());
      return;
    }
    // Demo mode: log the attempt so the UI can confirm.
    debugPrint('[AuthService] Demo mode: would send password reset to $email');
  }

  /// Applies a profile change to the active session.
  Future<void> updateCurrentSession(User user) => _persistSession(user);

  /// Releases the broadcast stream.
  Future<void> dispose() => _sessionController.close();

  // --- Internals -------------------------------------------------------------

  Future<void> _persistSession(User user) async {
    final UserModel model = UserModel.fromEntity(user);
    await preferences.setString(
      AppConstants.localSessionKey,
      jsonEncode(model.toJson()),
    );
  }

  UserModel? _readCachedSession() {
    final String raw =
        preferences.getString(AppConstants.localSessionKey) ?? '';
    if (raw.isEmpty) {
      return null;
    }
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      preferences.remove(AppConstants.localSessionKey);
      return null;
    }
  }

  Map<String, dynamic> _decodeAccount(String raw) {
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      decoded.remove('passwordHash');
      return decoded;
    } on Object {
      return <String, dynamic>{};
    }
  }

  UserModel _fromFirebase(firebase_auth.User firebaseUser) {
    final String? displayName = firebaseUser.displayName?.trim();
    return UserModel.fromFirebase(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: (displayName == null || displayName.isEmpty)
          ? 'Community member'
          : displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  /// SHA-256 with a per-install salt so demo accounts are never stored in
  /// clear text.
  String _hash(String password) {
    const String saltKey = 'local_account_salt';
    final String salt = preferences.getString(saltKey) ?? _createSalt(saltKey);
    return sha256.convert(utf8.encode('$salt::$password')).toString();
  }

  String _createSalt(String saltKey) {
    final Random random = Random.secure();
    final String salt = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    preferences.setString(saltKey, salt);
    return salt;
  }

  String _generateId() {
    final Random random = Random.secure();
    final String suffix = List<int>.generate(
      8,
      (_) => random.nextInt(0xFFFFFF),
    ).map((int byte) => byte.toRadixString(16).padLeft(6, '0')).join();
    return 'local-${DateTime.now().millisecondsSinceEpoch}-$suffix';
  }
}
