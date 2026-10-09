import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../data/models/user_model.dart';
import '../domain/entities/user.dart';
import 'firestore_service.dart';

/// Authentication gateway wrapping **Firebase Authentication**.
///
/// The class is a **SINGLETON**: [AuthService.instance] is published exactly
/// once by `injection.dart` after Firebase initialization.
class AuthService {
  AuthService._({required this.firestoreService});

  /// Builds the service. Only the DI container should call it, and publish the
  /// result with [registerInstance] so the singleton is unambiguous.
  factory AuthService.create({required FirestoreService firestoreService}) {
    return AuthService._(firestoreService: firestoreService);
  }

  static AuthService? _instance;

  /// Firestore service for checking readiness.
  final FirestoreService firestoreService;

  final StreamController<User?> _sessionController =
      StreamController<User?>.broadcast();

  firebase_auth.FirebaseAuth? _firebaseAuth;

  bool _restored = false;

  /// The shared instance.
  ///
  /// Reading it before [registerInstance] is a programming error.
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

  /// Firebase Auth handle — available after FirestoreService initializes.
  firebase_auth.FirebaseAuth get _auth {
    return _firebaseAuth ??= firebase_auth.FirebaseAuth.instance;
  }

  /// Broadcast stream of the current session.
  Stream<User?> authStateChanges() {
    return _auth.userChanges().map(
      (firebase_auth.User? firebaseUser) =>
          firebaseUser == null ? null : _fromFirebase(firebaseUser),
    );
  }

  /// Restores a previously persisted session exactly once.
  Future<User?> restoreSession() async {
    if (_restored) {
      return currentUser();
    }
    _restored = true;

    final firebase_auth.User? firebaseUser = _auth.currentUser;
    return firebaseUser == null ? null : _fromFirebase(firebaseUser);
  }

  /// The member currently signed in, `null` when signed out.
  User? currentUser() {
    final firebase_auth.User? firebaseUser = _auth.currentUser;
    return firebaseUser == null ? null : _fromFirebase(firebaseUser);
  }

  /// Signs in with email + password.
  Future<User> signIn({required String email, required String password}) async {
    final firebase_auth.UserCredential credential = await _auth
        .signInWithEmailAndPassword(email: email, password: password);
    return _fromFirebase(credential.user!);
  }

  /// Creates a new account.
  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
    String? deviceModel,
    String? osVersion,
  }) async {
    final firebase_auth.UserCredential credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);
    await _auth.currentUser?.updateDisplayName(fullName);
    return _fromFirebase(credential.user!)
        .withDeviceInfo(deviceModel: deviceModel, osVersion: osVersion);
  }

  /// Ends the session.
  Future<void> signOut() async {
    await _auth.signOut();
    _sessionController.add(null);
  }

  /// Sends a password-reset email.
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Applies a profile change to the active session.
  Future<void> updateCurrentSession(User user) async {
    _sessionController.add(user);
  }

  /// Releases the broadcast stream.
  Future<void> dispose() => _sessionController.close();

  // --- Internals -------------------------------------------------------------

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
}