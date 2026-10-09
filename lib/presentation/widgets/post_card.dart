import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/time_formatter.dart';
import '../../domain/entities/post.dart';
import 'user_avatar.dart';

/// A single post in the community feed.
///
/// Faithful to the Figma "home" frame: a 10 dp rounded white card with a
/// 50 dp header (30 dp avatar + author name + relative timestamp), the body
/// text and a 44 dp action footer (like + comment counters).
class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    this.onLike,
    this.onDelete,
    this.isOwnPost = false,
    super.key,
  });

  final Post post;

  /// Invoked when the like button is tapped.
  final VoidCallback? onLike;

  /// Invoked from the overflow menu (only for the author's own posts).
  final VoidCallback? onDelete;

  /// `true` when the signed-in member wrote this post.
  final bool isOwnPost;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PostHeader(post: post, isOwnPost: isOwnPost, onDelete: onDelete),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm + 2,
              AppSpacing.xxs,
              AppSpacing.sm + 2,
              AppSpacing.sm,
            ),
            child: Text(post.content, style: AppTypography.body),
          ),
          _PostFooter(post: post, onLike: onLike),
        ],
      ),
    );
  }
}

/// Author row: avatar, name and relative timestamp.
class _PostHeader extends StatelessWidget {
  const _PostHeader({
    required this.post,
    required this.isOwnPost,
    required this.onDelete,
  });

  final Post post;
  final bool isOwnPost;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 10,
      ),
      color: AppColors.white,
      child: Row(
        children: <Widget>[
          UserAvatar(
            fullName: post.authorName,
            photoUrl: post.authorPhotoUrl,
            size: 30,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              post.authorName,
              style: AppTypography.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isOwnPost && onDelete != null)
            _DeleteButton(onDelete: onDelete!)
          else
            Text(
              TimeFormatter.relative(post.createdAt),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Overflow affordance replacing the timestamp on the author's own posts.
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onDelete,
      visualDensity: VisualDensity.compact,
      tooltip: 'Delete post',
      icon: const Icon(
        Icons.delete_outline_rounded,
        size: 20,
        color: AppColors.textTertiary,
      ),
    );
  }
}

/// Action row: like toggle on the left, counters on the right.
class _PostFooter extends StatelessWidget {
  const _PostFooter({required this.post, required this.onLike});

  final Post post;
  final VoidCallback? onLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.white,
      child: Row(
        children: <Widget>[
          _ActionButton(
            icon: post.isLikedByCurrentUser
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            iconColor: post.isLikedByCurrentUser
                ? AppColors.error
                : AppColors.textSecondary,
            semanticLabel: post.isLikedByCurrentUser
                ? 'Unlike this post'
                : 'Like this post',
            onPressed: onLike,
          ),
          const Spacer(),
          _Counter(
            icon: Icons.chat_bubble_outline_rounded,
            count: post.commentCount,
          ),
          const SizedBox(width: AppSpacing.md),
          _Counter(icon: Icons.favorite_border_rounded, count: post.likeCount),
        ],
      ),
    );
  }
}

/// Square icon button with an accessible label.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.semanticLabel,
    this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: SizedBox.square(
          dimension: 32,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

/// Icon + number pair, e.g. the comment counter of the Figma footer.
class _Counter extends StatelessWidget {
  const _Counter({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$count', style: AppTypography.caption),
      ],
    );
  }
}
