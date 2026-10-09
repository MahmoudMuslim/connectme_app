import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Standard snack bar used for every user-facing message.
///
/// Centralising it guarantees a single visual language for success, error and
/// informational feedback across the whole app.
class ConnectMeSnackBar {
  const ConnectMeSnackBar._();

  /// Red banner for a failure.
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      background: AppColors.error,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Green banner for a success.
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      background: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Dark banner for an informational note.
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      background: AppColors.headerDark,
      icon: Icons.info_outline_rounded,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color background,
    required IconData icon,
  }) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (messenger == null) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(AppSpacing.md),
          content: Row(
            children: <Widget>[
              Icon(icon, color: AppColors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
