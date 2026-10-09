import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Circular avatar that falls back to the member's initials.
///
/// Supports both remote URLs and the base64 `data:` URLs produced by
/// `ImagePickerService`, so the profile photo appears immediately after the
/// upload without waiting for a CDN round-trip.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.fullName,
    this.photoUrl,
    this.size = 40,
    this.borderWidth = 0,
    super.key,
  });

  final String fullName;

  /// Remote URL or `data:` URL, `null` when no photo was uploaded.
  final String? photoUrl;

  final double size;

  /// White ring used on the Figma profile header.
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final String? url = (photoUrl == null || photoUrl!.isEmpty)
        ? null
        : photoUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentTint,
        border: borderWidth > 0
            ? Border.all(color: AppColors.white, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? _Initials(fullName: fullName, size: size)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? _) {
                    return _Initials(fullName: fullName, size: size);
                  },
              loadingBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? progress,
                  ) {
                    if (progress == null) {
                      return child;
                    }
                    return _Initials(fullName: fullName, size: size);
                  },
            ),
    );
  }
}

/// Initials placeholder, e.g. `BP` for "Bruno Pham".
class _Initials extends StatelessWidget {
  const _Initials({required this.fullName, required this.size});

  final String fullName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initialsOf(fullName),
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }

  static String _initialsOf(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
