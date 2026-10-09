package com.connectme_app

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * Entry point of the ConnectMe Android app.
 *
 * `FlutterFragmentActivity` is required because `local_auth` presents the
 * biometric prompt as a fragment transaction; the default `FlutterActivity`
 * would crash with "FlutterFragmentActivity required".
 */
class MainActivity : FlutterFragmentActivity()