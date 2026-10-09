import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../firebase_options.dart';

/// **SINGLETON PATTERN** — the single entry point to Cloud Firestore.
///
/// Requirement 5: "Apply the Singleton Pattern to the Firestore service — only
/// one instance must exist throughout the app lifecycle."
///
/// The instance is created lazily and cached, so `FirestoreService.instance`
/// always returns the very same object no matter how many data sources,
/// repositories or cubits ask for it. Tests inject their own instance through
/// [registerInstance].
class FirestoreService {
  FirestoreService._({required this._firestore});

  /// Test-only constructor for injecting a fake Firestore.
  FirestoreService.forTesting(Object firestore) : _firestore = firestore;

  /// The one and only instance.
  static FirestoreService? _instance;

  /// Firestore handle — never null after successful bootstrap.
  final Object _firestore;

  FirebaseFirestore get _firestoreImpl => _firestore as FirebaseFirestore;

  /// The shared instance, bootstrapping Firebase on first access.
  static FirestoreService get instance => _instance ??= _bootstrap();

  /// Registers a pre-built instance. `injection.dart` uses it to publish the
  /// singleton right after Firebase bootstrap, and tests use it to inject a
  /// fake Firestore.
  static void registerInstance(FirestoreService service) {
    _instance = service;
  }

  /// Clears the singleton — tear-down helper for tests only.
  static void resetForTesting() {
    _instance = null;
  }

  /// Root reference of the `posts` collection.
  CollectionReference<Map<String, dynamic>> get postsCollection =>
      _firestoreImpl.collection(AppConstants.postsCollection);

  /// Root reference of the `users` collection.
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestoreImpl.collection(AppConstants.usersCollection);

  /// Root reference of the `donations` collection.
  CollectionReference<Map<String, dynamic>> get donationsCollection =>
      _firestoreImpl.collection(AppConstants.donationsCollection);

  /// `true` — Firebase is mandatory now, no demo mode.
  bool get isReady => true;

  static FirestoreService _bootstrap() {
    // Firebase configuration is mandatory — no demo mode fallback.
    final FirebaseOptions options = _resolveFirebaseOptions();

    try {
      if (Firebase.apps.isEmpty) {
        Firebase.initializeApp(options: options);
      }
      return FirestoreService._(firestore: FirebaseFirestore.instance);
    } on FirebaseException catch (error) {
      throw StateError(
        'Firebase rejected the supplied credentials (${error.code}). '
        'Check your Firebase project configuration.',
      );
    } on Object catch (error) {
      throw StateError('Firebase could not be started ($error).');
    }
  }

  /// Builds the [FirebaseOptions] from `--dart-define` when every mandatory
  /// value is present, otherwise falls back to the generated `firebase_options.dart`.
  /// Throws if neither is available.
  static FirebaseOptions _resolveFirebaseOptions() {
    if (AppConfig.isFirebaseConfigured) {
      return FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        authDomain: AppConfig.firebaseAuthDomain.isEmpty
            ? '${AppConfig.firebaseProjectId}.firebaseapp.com'
            : AppConfig.firebaseAuthDomain,
        storageBucket: AppConfig.firebaseStorageBucket.isEmpty
            ? '${AppConfig.firebaseProjectId}.appspot.com'
            : AppConfig.firebaseStorageBucket,
      );
    }
    try {
      return DefaultFirebaseOptions.currentPlatform;
    } on UnsupportedError {
      throw StateError(
        'No Firebase configuration for this platform. '
        'Run `flutterfire configure` or supply --dart-define=FIREBASE_* flags.',
      );
    } on Error {
      throw StateError('Failed to load firebase_options.dart.');
    }
  }
}