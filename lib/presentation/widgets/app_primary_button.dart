import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';

/// Outlined counterpart of [AppPrimaryButton].
///
/// Mirrors the Figma "Message" pill: white fill, brand border, brand label.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.4),
          shape: const StadiumBorder(),
          textStyle: AppTypography.button.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 18, color: AppColors.primaryDark),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label.toUpperCase()),
          ],
        ),
      ),
    );
  }
}

/// Gradient pill button used across the app.
///
/// Matches the Figma `LOG IN` / `SIGN UP` container: 52 dp tall, fully rounded,
/// with the signature `#888BF4 -> #5151C6` gradient and an uppercase label.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  /// Button caption, rendered uppercase like the design.
  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  /// Shows a spinner and blocks taps.
  final bool isLoading;

  /// Optional leading glyph.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: enabled ? 1 : 0.6,
          child: Container(
            height: 52,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              gradient: enabled ? AppColors.brandGradient : null,
              color: enabled ? null : AppColors.textTertiary,
              shape: const StadiumBorder(),
            ),
            child: isLoading
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (icon != null) ...<Widget>[
                        Icon(icon, color: AppColors.white, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(label.toUpperCase(), style: AppTypography.button),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
