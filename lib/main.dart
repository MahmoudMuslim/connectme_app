import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-first design, matching the 375 x 812 Figma frames. Tablets keep a
  // landscape-friendly layout because every screen is built with `MediaQuery`.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar so the dark login / sign-up header bleeds behind it.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Build the dependency graph before the first frame.
  await registerDependencies();

  debugPrint('[ConnectMe] Connected to Cloud Firestore.');
  debugPrint('[ConnectMe] ${AppConfig.appName} ${AppConfig.versionName}');

  runApp(const ConnectMeApp());
}