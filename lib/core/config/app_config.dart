/// Compile-time configuration for the ConnectMe app.
///
/// Every sensitive value is injected with `--dart-define` so that no real key is
/// ever committed to version control:
///
/// ```bash
/// flutter run \
///   --dart-define=GOOGLE_MAPS_API_KEY=AIza... \
///   --dart-define=FIREBASE_API_KEY=AIza... \
///   --dart-define=FIREBASE_APP_ID=1:123:web:abc \
///   --dart-define=FIREBASE_MESSAGING_SENDER_ID=123 \
///   --dart-define=FIREBASE_PROJECT_ID=my-project \
///   --dart-define=FIREBASE_AUTH_DOMAIN=my-project.firebaseapp.com \
///   --dart-define=FIREBASE_STORAGE_BUCKET=my-project.appspot.com
/// ```
///
/// When the Firebase values are absent (the default for a fresh clone) the app
/// transparently boots into **demo mode**: every service keeps the exact same
/// public contract but is backed by local persistence instead of the cloud.
/// This keeps the repository buildable and demo-able for every reviewer while
/// staying production-ready once the real keys are supplied.
class AppConfig {
  const AppConfig._();

  /// Placeholder written in `google-services.json`-less builds.
  static const String emptyValue = '';

  // --- Google Maps -----------------------------------------------------------
  static const String _googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: emptyValue,
  );

  /// API key injected into `AndroidManifest.xml` through a Gradle
  /// `manifestPlaceholder` and read at runtime by [MapScreen] for the web
  /// target.
  static String get googleMapsApiKey => _googleMapsApiKey;

  /// `true` when a real Maps key was supplied.
  static bool get hasGoogleMapsKey => _googleMapsApiKey.isNotEmpty;

  // --- Firebase --------------------------------------------------------------
  static const String _firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: emptyValue,
  );
  static const String _firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: emptyValue,
  );
  static const String _firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: emptyValue,
  );
  static const String _firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: emptyValue,
  );
  static const String _firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: emptyValue,
  );
  static const String _firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: emptyValue,
  );

  static String get firebaseApiKey => _firebaseApiKey;
  static String get firebaseAppId => _firebaseAppId;
  static String get firebaseMessagingSenderId => _firebaseMessagingSenderId;
  static String get firebaseProjectId => _firebaseProjectId;
  static String get firebaseAuthDomain => _firebaseAuthDomain;
  static String get firebaseStorageBucket => _firebaseStorageBucket;

  /// `true` when every mandatory Firebase option has been provided.
  static bool get isFirebaseConfigured =>
      _firebaseApiKey.isNotEmpty &&
      _firebaseAppId.isNotEmpty &&
      _firebaseProjectId.isNotEmpty &&
      _firebaseMessagingSenderId.isNotEmpty;

  // --- Feature switches ------------------------------------------------------

  /// Forces demo mode even when Firebase credentials exist. Useful for
  /// automated tests and for reviewers who want an offline build.
  static const bool forceDemoMode = bool.fromEnvironment(
    'FORCE_DEMO_MODE',
    defaultValue: false,
  );

  /// The application name shown in the app bar / launcher label.
  static const String appName = 'ConnectMe';

  /// Suffix appended to the version name on the release build.
  static const String versionName = '1.0.0';

  /// Build number published through Firebase App Distribution.
  static const String buildNumber = '1';
}
