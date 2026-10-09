import 'package:flutter/material.dart';

/// Layout buckets derived from the shortest side of the viewport.
enum SizeBucket {
  /// Phone in portrait (< 600 dp).
  compact,

  /// Large phone in landscape or small tablet (600-904 dp).
  medium,

  /// Tablet (>= 905 dp).
  expanded;

  bool get isCompact => this == SizeBucket.compact;

  bool get isExpanded => this == SizeBucket.expanded;
}

/// Responsive helpers built on top of `MediaQuery`.
///
/// Requirement: "the UI must be fully responsive using MediaQuery". Rather than
/// sprinkling magic numbers, every screen asks this helper for its horizontal
/// margin, its content max width and its column count, so a phone, a foldable
/// and a tablet all get a sensible layout.
abstract final class Responsive {
  /// Classifies [context] using `MediaQuery`.
  static SizeBucket bucketOf(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double width = size.width < size.height ? size.width : size.height;
    if (width >= 905) {
      return SizeBucket.expanded;
    }
    if (width >= 600) {
      return SizeBucket.medium;
    }
    return SizeBucket.compact;
  }

  /// Horizontal screen margin: 20 dp on phones, scaled up on larger screens.
  static double horizontalMargin(BuildContext context) {
    return switch (bucketOf(context)) {
      SizeBucket.compact => 20,
      SizeBucket.medium => 28,
      SizeBucket.expanded => 40,
    };
  }

  /// Content is centred and never grows wider than this value so the feed
  /// stays readable on a 10" tablet.
  static double maxContentWidth(BuildContext context) {
    return switch (bucketOf(context)) {
      SizeBucket.compact => double.infinity,
      SizeBucket.medium => 640,
      SizeBucket.expanded => 760,
    };
  }

  /// Number of columns used by a responsive grid.
  static int gridColumns(BuildContext context) {
    return switch (bucketOf(context)) {
      SizeBucket.compact => 2,
      SizeBucket.medium => 3,
      SizeBucket.expanded => 4,
    };
  }

  /// Font scale multiplier that keeps the huge Figma headline readable without
  /// overflowing on very small phones.
  static double heroFontScale(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width < 340) {
      return 0.78;
    }
    if (width < 380) {
      return 0.9;
    }
    return 1;
  }

  /// Wraps [child] in a centred, width-constrained box.
  static Widget constrainContent(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth(context)),
          child: child,
        ),
      ),
    );
  }
}
