import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Dark header collage of the login / sign-up screens.
///
/// Faithful to the Figma frame: a 2x2 grey/photo mosaic flattened by an opaque
/// `#212121` rectangle, plus a 10 % black veil and a 180°-rotated photo that
/// bleeds in from the bottom edge. Since the design's real photos are not part
/// of the kit export, the tiles are drawn with the brand-tinted gradients, which
/// reproduces the same dark, textured banner.
class AuthHeaderCollage extends StatelessWidget {
  const AuthHeaderCollage({this.height = 312, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Grey photo mosaic.
            Row(
              children: <Widget>[
                Expanded(child: _tile(const Color(0xFFC4C4C4), 0.0)),
                Expanded(child: _tile(const Color(0xFF909090), -0.35)),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(child: _tile(const Color(0xFF212121), 0.25)),
                Expanded(child: _tile(const Color(0xFF5F5F5F), -0.15)),
              ],
            ),
            // Opaque dark rectangle flattening the mosaic.
            Positioned.fill(child: Container(color: AppColors.headerDark)),
            // Rotated photo bleeding in from the bottom edge.
            Positioned(
              left: 0,
              right: 0,
              bottom: -height * 0.36,
              height: height * 0.5,
              child: Opacity(
                opacity: 0.4,
                child: Transform.rotate(
                  angle: 3.14,
                  child: _tile(AppColors.primaryDark, 0.1),
                ),
              ),
            ),
            // 10 % black veil.
            Positioned.fill(
              child: Container(
                color: AppColors.headerDark.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(Color color, double angle) {
    return Transform.rotate(
      angle: angle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              color,
              Color.lerp(color, AppColors.primaryDark, 0.5)!,
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
