# ConnectMe ProGuard / R8 rules.
#
# The release build enables `isMinifyEnabled` and `isShrinkResources`, so the
# plugin entry points must be preserved explicitly.

# --- Flutter / Dart ---------------------------------------------------------
-dontwarn io.flutter.embedding.**
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# --- Google Maps ------------------------------------------------------------
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.location.** { *; }
-dontwarn com.google.android.gms.**

# --- Firebase ---------------------------------------------------------------
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class io.flutter.plugins.firebase.** { *; }

# --- Kotlin coroutines ------------------------------------------------------
-dontwarn kotlinx.coroutines.**
-keepclassmembers class kotlinx.coroutines.** { volatile <fields>; }