import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Corner radii used across the design.
class AppRadii {
  const AppRadii._();

  /// Pill shaped fields and buttons.
  static const double pill = 30;

  /// Post cards, collection tiles and search fields.
  static const double card = 10;

  /// Segmented control.
  static const double tab = 6;

  /// Profile stats pill.
  static const double chip = 6;

  /// Circular icon buttons.
  static const double circle = 40;

  /// Top corners of the login / sign-up bottom sheet.
  static const double sheet = 28;
}

/// Shared spacing steps (base unit 4 dp) so paddings stay consistent.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal margin of every screen (20 dp in the Figma frames).
  static const double screenHorizontal = 20;

  /// Horizontal gap between two bottom-bar glyphs.
  static const double iconGap = 16;
}

/// Single source of truth for the Material [ThemeData].
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      primary: AppColors.primaryDark,
      secondary: AppColors.primaryLight,
      surface: AppColors.white,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.screenBackground,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 15,
        ),
        hintStyle: AppTypography.input.copyWith(color: AppColors.textTertiary),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        border: _pillBorder(),
        enabledBorder: _pillBorder(),
        focusedBorder: _pillBorder(focused: true),
        errorBorder: _pillBorder(error: true),
        focusedErrorBorder: _pillBorder(error: true, focused: true),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.textTertiary,
          shape: const StadiumBorder(),
          textStyle: AppTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.link,
          textStyle: AppTypography.button.copyWith(
            color: AppColors.link,
            letterSpacing: 0.6,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.headerDark,
        contentTextStyle: AppTypography.caption.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _pillBorder({
    bool focused = false,
    bool error = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      borderSide: BorderSide(
        color: error
            ? AppColors.error
            : focused
            ? AppColors.primaryLight
            : Colors.transparent,
        width: focused || error ? 1.4 : 0,
      ),
    );
  }
}
