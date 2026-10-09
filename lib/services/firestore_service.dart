import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
///
/// The class also owns the Firebase bootstrap. When no credentials were supplied
/// with `--dart-define`, [isReady] stays `false` and the repository factory
/// transparently selects the local cache data source, so the published beta
/// build never crashes on a missing configuration.
class FirestoreService {
  FirestoreService._({
    required this.firestore,
    required this.unavailableReason,
  });

  /// The one and only instance.
  static FirestoreService? _instance;

  /// Firestore handle, `null` when Firebase could not be started.
  final FirebaseFirestore? firestore;

  /// Why Firestore is unavailable (surfaced in the debug banner and the logs).
  final String unavailableReason;

  /// The shared instance, bootstrapping Firebase on first access.
  static FirestoreService get instance => _instance ??= _bootstrap();

  /// Forces the on-device cache, bypassing Firebase entirely.
  ///
  /// The widget tests call this so `flutter test` never touches a platform
  /// channel or the network, whatever Firebase configuration the repository
  /// happens to contain.
  @visibleForTesting
  static void useDemoMode() {
    _instance = FirestoreService._(
      firestore: null,
      unavailableReason: 'Demo mode forced by the widget test binding.',
    );
  }

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

  /// `true` when Firebase started successfully and Firestore can be used.
  bool get isReady => firestore != null;

  /// `true` when the app runs against the local cache because Firebase is
  /// unavailable (fresh clone without `--dart-define` credentials).
  bool get isDemoMode => firestore == null;

  /// Root reference of the `posts` collection.
  CollectionReference<Map<String, dynamic>> get postsCollection =>
      firestore!.collection(AppConstants.postsCollection);

  /// Root reference of the `users` collection.
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore!.collection(AppConstants.usersCollection);

  /// Root reference of the `donations` collection.
  CollectionReference<Map<String, dynamic>> get donationsCollection =>
      firestore!.collection(AppConstants.donationsCollection);

  static FirestoreService _bootstrap() {
    if (AppConfig.forceDemoMode) {
      return FirestoreService._(
        firestore: null,
        unavailableReason: 'FORCE_DEMO_MODE was enabled at build time.',
      );
    }

    // Three-tier configuration, in priority order:
    //   1. `--dart-define=FIREBASE_*` values (handy for CI and per-flavor builds).
    //   2. `lib/firebase_options.dart` produced by `flutterfire configure`.
    //   3. No configuration at all -> the app runs against the on-device cache.
    final FirebaseOptions? options = _resolveFirebaseOptions();
    if (options == null) {
      return FirestoreService._(
        firestore: null,
        unavailableReason:
            'No Firebase credentials supplied. Rebuild with '
            '--dart-define=FIREBASE_PROJECT_ID=... to enable the cloud backend.',
      );
    }

    try {
      if (Firebase.apps.isEmpty) {
        Firebase.initializeApp(options: options);
      }
      return FirestoreService._(
        firestore: FirebaseFirestore.instance,
        unavailableReason: '',
      );
    } on FirebaseException catch (error) {
      return FirestoreService._(
        firestore: null,
        unavailableReason:
            'Firebase rejected the supplied credentials (${error.code}).',
      );
    } on Object catch (error) {
      return FirestoreService._(
        firestore: null,
        unavailableReason: 'Firebase could not be started ($error).',
      );
    }
  }

  /// Builds the [FirebaseOptions] from `--dart-define` when every mandatory
  /// value is present, otherwise falls back to the generated
  /// `firebase_options.dart`, otherwise returns `null` (demo mode).
  static FirebaseOptions? _resolveFirebaseOptions() {
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
      // A desktop target without a generated configuration: stay offline.
      return null;
    } on Error {
      return null;
    }
  }
}
