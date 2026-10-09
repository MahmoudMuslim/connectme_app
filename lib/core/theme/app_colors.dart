import 'package:flutter/material.dart';

/// Colour palette extracted 1:1 from the Figma "Social App — Free UI Kit"
/// export found in `figma/`. Every widget in the app must reference a token
/// from this class instead of hard-coding a hex value.
class AppColors {
  const AppColors._();

  // --- Brand -----------------------------------------------------------------
  /// Dark end of the brand gradient (`#5151C6`).
  static const Color primaryDark = Color(0xFF5151C6);

  /// Light end of the brand gradient (`#888BF4`).
  static const Color primaryLight = Color(0xFF888BF4);

  /// Anchor colour used for links such as "SIGN UP" / "FORGOT PASSWORD".
  static const Color link = Color(0xFF5252C7);

  /// Background of the selected segmented tab.
  static const Color accentTint = Color(0xFFF1F1FD);

  /// Background of the social sign-in circles.
  static const Color socialButton = Color(0xFFE3E3FC);

  /// The signature gradient: light bottom-right -> dark top-left.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment(1, 1),
    end: Alignment(-0, 0),
    colors: <Color>[primaryLight, primaryDark],
  );

  /// Vertical gradient used by the splash screen (dark bottom -> light top).
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment(0.5, 1),
    end: Alignment(0.5, 0),
    colors: <Color>[primaryDark, primaryLight],
  );

  // --- Surfaces --------------------------------------------------------------
  /// Page background of the feed, the map sheet and the profile screen.
  static const Color screenBackground = Color(0xFFF5F6F8);

  /// Fill of every pill shaped text field.
  static const Color fieldFill = Color(0xFFF2F4F6);

  static const Color white = Colors.white;

  /// Dark veil used behind the login / sign-up header collage.
  static const Color headerDark = Color(0xFF212121);

  /// 50 % black scrim placed above the profile header banner.
  static const Color headerScrim = Color(0x7F212121);

  /// Scrim placed above the profile collection tiles.
  static const Color tileScrim = Color(0x7F333333);

  static const Color divider = Color(0xFFEBEDF0);

  // --- Typography ------------------------------------------------------------
  /// Primary text (display names, stat values).
  static const Color textPrimary = Color(0xFF242424);

  /// Secondary text (counters, captions).
  static const Color textSecondary = Color(0xFF828282);

  /// Tertiary text (placeholders, timestamps, inactive tabs).
  static const Color textTertiary = Color(0xFFBDBDBD);

  /// Muted indigo used for the profile location line.
  static const Color textMuted = Color(0xFF8F8FA6);

  // --- Status ----------------------------------------------------------------
  static const Color error = Color(0xFFE04F5F);
  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFF0A202);
}
