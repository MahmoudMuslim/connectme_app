import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Shimmering placeholder card shown while the feed loads.
///
/// Using a skeleton instead of a bare spinner keeps the layout stable and
/// mirrors the Figma card geometry (10 dp radius, 50 dp header).
class PostCardSkeleton extends StatefulWidget {
  const PostCardSkeleton({super.key});

  @override
  State<PostCardSkeleton> createState() => _PostCardSkeletonState();
}

class _PostCardSkeletonState extends State<PostCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double opacity = 0.35 + (_controller.value * 0.35);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _Block(
                    width: 30,
                    height: 30,
                    opacity: opacity,
                    circular: true,
                  ),
                  const SizedBox(width: 10),
                  _Block(width: 130, height: 12, opacity: opacity),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _Block(width: double.infinity, height: 12, opacity: opacity),
              const SizedBox(height: AppSpacing.xs),
              _Block(width: 220, height: 12, opacity: opacity),
            ],
          );
        },
      ),
    );
  }
}

/// A single grey placeholder block.
class _Block extends StatelessWidget {
  const _Block({
    required this.width,
    required this.height,
    required this.opacity,
    this.circular = false,
  });

  final double width;
  final double height;
  final double opacity;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: opacity),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(AppRadii.chip),
      ),
    );
  }
}

/// Wraps a list of [PostCardSkeleton]s.
class PostListSkeleton extends StatelessWidget {
  const PostListSkeleton({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) =>
          const PostCardSkeleton(),
    );
  }
}
