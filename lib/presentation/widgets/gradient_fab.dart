import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Signature 60 dp gradient action button of the Figma design.
///
/// It is deliberately **not** a Material `FloatingActionButton`: the design uses
/// a plain gradient circle, so the shadow / hover behaviour is reimplemented
/// here to stay pixel-faithful.
class GradientFab extends StatelessWidget {
  const GradientFab({
    required this.onPressed,
    this.tooltip = 'Create post',
    super.key,
  });

  /// Opens the post composer.
  final VoidCallback? onPressed;

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Ink(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
