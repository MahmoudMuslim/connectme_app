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
  FirestoreService._({required this.firestore});

  /// Test-only constructor for injecting a fake Firestore.
  FirestoreService.forTesting(this.firestore);

  /// The one and only instance.
  static FirestoreService? _instance;

  /// Firestore handle — never null after successful bootstrap.
  final FirebaseFirestore firestore;

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
      firestore.collection(AppConstants.postsCollection);

  /// Root reference of the `users` collection.
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection(AppConstants.usersCollection);

  /// Root reference of the `donations` collection.
  CollectionReference<Map<String, dynamic>> get donationsCollection =>
      firestore.collection(AppConstants.donationsCollection);

  /// `true` — Firebase is mandatory.
  bool get isReady => true;

  static FirestoreService _bootstrap() {
    // Priority 1: `--dart-define=FORCE_DEMO_MODE=true` (local development without Firebase)
    if (AppConfig.forceDemoMode) {
      throw StateError(
        'FORCE_DEMO_MODE is not supported in production. '
        'Use a real Firebase project or run tests with mocktail.',
      );
    }

    // Priority 2: `--dart-define` flags (CI / per-flavor builds)
    if (AppConfig.isFirebaseConfigured) {
      return _initWithOptions(
        FirebaseOptions(
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
        ),
      );
    }

    // Priority 3: Generated `firebase_options.dart` (flutterfire configure)
    try {
      return _initWithOptions(DefaultFirebaseOptions.currentPlatform);
    } on UnsupportedError catch (_) {
      // Platform not configured in firebase_options.dart
    } on Error catch (_) {
      // firebase_options.dart missing or invalid
    }

    // No configuration — fail fast with clear instructions
    throw StateError(
      'No Firebase configuration found.\n\n'
      'To run ConnectMe you need a Firebase project:\n'
      '1. Run `flutterfire configure` to generate firebase_options.dart, OR\n'
      '2. Supply all --dart-define=FIREBASE_* flags at build/run time:\n'
      '   --dart-define=FIREBASE_API_KEY=...\n'
      '   --dart-define=FIREBASE_APP_ID=...\n'
      '   --dart-define=FIREBASE_MESSAGING_SENDER_ID=...\n'
      '   --dart-define=FIREBASE_PROJECT_ID=...\n'
      '   --dart-define=FIREBASE_AUTH_DOMAIN=...\n'
      '   --dart-define=FIREBASE_STORAGE_BUCKET=...\n\n'
      'For web, also add Firebase SDK init to web/index.html with your web app config.',
    );
  }

  static FirestoreService _initWithOptions(FirebaseOptions options) {
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
}
