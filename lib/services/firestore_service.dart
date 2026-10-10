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
/// The instance is created once by [initialize] and cached, so
/// `FirestoreService.instance` always returns the very same object no matter how
/// many data sources, repositories or cubits ask for it. Tests inject their own
/// instance through [registerInstance].
class FirestoreService {
  FirestoreService._({required this.firestore});

  /// Test-only constructor for injecting a fake Firestore.
  FirestoreService.forTesting(this.firestore);

  /// The one and only instance.
  static FirestoreService? _instance;

  /// Firestore handle — never null after successful bootstrap.
  final FirebaseFirestore firestore;

  /// The shared instance.
  ///
  /// Reading it before [initialize] has been awaited is a programming error.
  static FirestoreService get instance {
    final FirestoreService? service = _instance;
    if (service == null) {
      throw StateError(
        'FirestoreService.instance was read before FirestoreService.initialize() '
        'was awaited.',
      );
    }
    return service;
  }

  /// Initializes Firebase (once) and returns the shared [FirestoreService].
  ///
  /// Must be awaited from `main()` before `registerDependencies()` runs, because
  /// `Firebase.initializeApp` is asynchronous on every platform — including web.
  static Future<FirestoreService> initialize() async {
    final FirestoreService? existing = _instance;
    if (existing != null) {
      return existing;
    }

    if (AppConfig.forceDemoMode) {
      throw StateError(
        'FORCE_DEMO_MODE is not supported. '
        'Use a real Firebase project or run tests with mocktail.',
      );
    }

    final FirebaseOptions options = _resolveOptions();

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
    } on FirebaseException catch (error) {
      throw StateError(
        'Firebase rejected the supplied credentials (${error.code}). '
        'Check your Firebase project configuration: $error',
      );
    } on Object catch (error) {
      throw StateError('Firebase could not be started ($error).');
    }

    final FirestoreService service = FirestoreService._(
      firestore: FirebaseFirestore.instance,
    );
    _instance = service;
    return service;
  }

  /// Registers a pre-built instance. Tests use it to inject a fake Firestore.
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

  /// Resolves the Firebase options from the first available source:
  /// `--dart-define` flags (CI / per-flavor builds) then the generated
  /// `firebase_options.dart`.
  static FirebaseOptions _resolveOptions() {
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
    } on UnsupportedError catch (error) {
      throw StateError(
        'No Firebase configuration found for this platform.\n\n'
        'To run ConnectMe you need a Firebase project:\n'
        '1. Run `flutterfire configure` to generate firebase_options.dart, OR\n'
        '2. Supply all --dart-define=FIREBASE_* flags at build/run time:\n'
        '   --dart-define=FIREBASE_API_KEY=...\n'
        '   --dart-define=FIREBASE_APP_ID=...\n'
        '   --dart-define=FIREBASE_MESSAGING_SENDER_ID=...\n'
        '   --dart-define=FIREBASE_PROJECT_ID=...\n'
        '   --dart-define=FIREBASE_AUTH_DOMAIN=...\n'
        '   --dart-define=FIREBASE_STORAGE_BUCKET=...\n\n'
        'Platform reported: $error',
      );
    }
  }
}
