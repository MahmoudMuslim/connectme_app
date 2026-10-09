pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    // The `com.google.gms.google-services` plugin is intentionally **not**
    // applied: ConnectMe boots Firebase through explicit `FirebaseOptions`
    // built from `--dart-define` values (see `lib/core/config/app_config.dart`),
    // which keeps credentials out of the repository and lets the app fall back
    // to the on-device cache when they are absent.
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
