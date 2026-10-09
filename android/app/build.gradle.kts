import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// --- Release signing --------------------------------------------------------
// Credentials are read from `android/key.properties`, which is git-ignored.
// Create it from `key.properties.example` (see README → "Release signing").
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

// --- Google Maps API key ----------------------------------------------------
// Injected into AndroidManifest.xml as the `${MAPS_API_KEY}` placeholder.
// Supply it with `-PMAPS_API_KEY=AIza...` or from `local.properties`.
val mapsApiKey: String =
    (project.findProperty("MAPS_API_KEY") as String?)
        ?: runCatching {
            val localProperties = Properties()
            rootProject.file("local.properties").inputStream().use {
                localProperties.load(it)
            }
            localProperties.getProperty("MAPS_API_KEY")
        }.getOrNull()
        ?: "YOUR_GOOGLE_MAPS_API_KEY"

android {
    namespace = "com.connectme_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.connectme_app"
        // Firebase Auth, Firestore, local_auth and the Maps SDK all require API 24+.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Falls back to the debug keys when `key.properties` is absent so a
            // reviewer can always produce an installable beta APK.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Google Maps SDK for Android, required by `google_maps_flutter`.
    implementation("com.google.android.gms:play-services-maps:19.2.0")
    implementation("com.google.android.gms:play-services-location:21.3.0")
}