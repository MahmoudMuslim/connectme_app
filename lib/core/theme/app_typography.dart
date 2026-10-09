import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography scale transcribed from the Figma kit.
///
/// The kit ships with the commercial families *Proxima Nova* (display) and
/// *Circular Std* (UI). Both are substituted here by **Poppins**, a metric
/// compatible geometric sans-serif that is bundled in `assets/fonts/` so the
/// UI renders identically offline and inside the release APK.
class AppTypography {
  const AppTypography._();

  /// Bundled family name, declared in `pubspec.yaml`.
  static const String fontFamily = 'Poppins';

  /// `WELCOME` — 40 / w700 / letterSpacing 4.
  static const TextStyle hero = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: 4,
    height: 1.1,
    color: AppColors.white,
  );

  /// Profile display name — 20 / w700.
  static const TextStyle displayName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Section / app-bar title — 16 / w700.
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  /// Default body copy — 16 / w400.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Primary button label — 16 / w700 / letterSpacing 0.6.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0.6,
    color: AppColors.white,
  );

  /// Caption, counter, tab label — 14 / w400.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.1,
    color: AppColors.textSecondary,
  );

  /// Uppercase micro label (`FORGOT PASSWORD`, `OR LOG IN BY`) — 14 / w400 / ls 2.
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 2,
    color: AppColors.textSecondary,
  );

  /// Input field text — 16 / w400.
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );
}
