import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user.dart';
import 'user_avatar.dart';

/// Dark, curved banner + ringed avatar, matching the Figma profile frame.
///
/// The banner keeps the design's signature **concave bottom edge** (a shallow
/// arc cut with [CurvedBannerClipper]) and the 80 dp avatar sits exactly on that
/// edge with its 4 dp white ring, exactly like the design frame.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, this.bannerHeight = 220, super.key});

  final User user;

  /// Height of the dark banner, including the curved part.
  final double bannerHeight;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double avatarSize = width < 380 ? 72 : 80;

    return SizedBox(
      height: bannerHeight + avatarSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // --- Banner --------------------------------------------------------
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: bannerHeight,
            child: ClipPath(
              clipper: CurvedBannerClipper(),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFF1B1033),
                      Color(0xFF3A2A6B),
                      Color(0xFF123A5C),
                    ],
                  ),
                ),
                // Diagonal accent stripes, as in the design banner.
                child: CustomPaint(
                  painter: _DiagonalStripesPainter(),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // --- Handle --------------------------------------------------------
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.paddingOf(context).top + 14,
            child: Center(
              child: Text(
                user.handle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // --- Avatar, centred on the banner edge ----------------------------
          Positioned(
            left: 0,
            right: 0,
            top: bannerHeight - avatarSize / 2,
            child: Center(
              child: UserAvatar(
                fullName: user.fullName,
                photoUrl: user.photoUrl,
                size: avatarSize,
                borderWidth: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuts a shallow concave arc out of the bottom of the banner.
class CurvedBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height)
      // A quadratic arc bending upwards in the middle of the banner.
      ..quadraticBezierTo(
        size.width / 2,
        size.height - size.width * 0.22,
        size.width,
        size.height,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) =>
      oldClipper is! CurvedBannerClipper;
}

/// Paints the translucent diagonal bands of the design banner.
class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    const double bandWidth = 46;
    for (
      double x = -size.height;
      x < size.width + size.height;
      x += bandWidth
    ) {
      canvas.save();
      canvas.translate(x, 0);
      canvas.rotate(0.5);
      canvas.drawRect(
        Rect.fromLTWH(0, -size.height, bandWidth / 3, size.height * 3),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalStripesPainter oldDelegate) => false;
}
