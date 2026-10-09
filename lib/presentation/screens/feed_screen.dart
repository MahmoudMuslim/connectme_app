import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/user.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/post/post_cubit.dart';
import '../blocs/post/post_state.dart';
import '../widgets/connectme_snack_bar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/post_card_skeleton.dart';
import '../widgets/profile_gate.dart';

/// Community feed.
///
/// Requirement 2: "Display a scrollable feed of community posts fetched in real
/// time from Cloud Firestore." The screen also carries the profile icon in the
/// app bar, which triggers the biometric gate (requirement 3).
class FeedScreen extends StatefulWidget {
  const FeedScreen({required this.onOpenProfile, super.key});

  /// Called after the biometric challenge succeeded.
  final VoidCallback onOpenProfile;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _searchController = TextEditingController();

  User get _currentUser => ProfileGate.currentUser(context);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _FeedAppBar(onOpenProfile: _openProfile),
        _SearchRow(
          searchController: _searchController,
          onSearchChanged: context.read<PostCubit>().changeSearchQuery,
          onSearchCleared: context.read<PostCubit>().clearSearch,
        ),
        BlocBuilder<PostCubit, PostState>(
          buildWhen: (PostState previous, PostState current) =>
              previous.filter != current.filter,
          builder: (BuildContext context, PostState state) {
            return FeedTabBar(
              selected: state.filter,
              onChanged: context.read<PostCubit>().changeFilter,
            );
          },
        ),
        const Divider(height: 1),
        Expanded(child: _buildFeed()),
      ],
    );
  }

  Widget _buildFeed() {
    return BlocConsumer<PostCubit, PostState>(
      listenWhen: (PostState previous, PostState current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (BuildContext context, PostState state) {
        ConnectMeSnackBar.showError(context, state.errorMessage!);
        context.read<PostCubit>().clearError();
      },
      builder: (BuildContext context, PostState state) {
        return switch (state.status) {
          PostStatus.loading => const PostListSkeleton(),
          PostStatus.error => ErrorView(
            message: state.errorMessage ?? 'The feed is unavailable.',
            onRetry: () => context.read<PostCubit>().listen(
              currentUserId: _currentUser.id,
            ),
          ),
          PostStatus.loaded =>
            state.posts.isEmpty
                ? EmptyStateView(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No posts yet',
                    message:
                        'Be the first member of your circle to say something.',
                    actionLabel: 'Refresh',
                    onAction: context.read<PostCubit>().refresh,
                  )
                : _PostList(state: state),
        };
      },
    );
  }

  /// Runs the biometric challenge, then asks the shell to reveal the profile.
  Future<void> _openProfile() async {
    final bool authenticated = await ProfileGate.authenticate(context);
    if (authenticated && mounted) {
      widget.onOpenProfile();
    }
  }
}

/// White top bar: title on the left, biometric profile icon on the right.
class _FeedAppBar extends StatelessWidget {
  const _FeedAppBar({required this.onOpenProfile});

  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final double margin = Responsive.horizontalMargin(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(margin, AppSpacing.sm, margin - 8, 0),
      color: AppColors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'ConnectMe',
              style: AppTypography.sectionTitle.copyWith(fontSize: 20),
            ),
          ),
          ProfileGateButton(onPressed: onOpenProfile),
        ],
      ),
    );
  }
}

/// Search pill + filter chip, exactly like the Figma row.
class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchCleared,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;

  @override
  Widget build(BuildContext context) {
    final double margin = Responsive.horizontalMargin(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        margin,
        AppSpacing.sm,
        margin,
        AppSpacing.sm,
      ),
      color: AppColors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SearchPill(
              controller: searchController,
              onChanged: onSearchChanged,
              onCleared: onSearchCleared,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const _FilterChip(),
        ],
      ),
    );
  }
}

/// Rounded `#F2F4F6` search field of the Figma row.
class _SearchPill extends StatelessWidget {
  const _SearchPill({
    required this.controller,
    required this.onChanged,
    required this.onCleared,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search community posts',
                hintStyle: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                          onCleared();
                        },
                        tooltip: 'Clear search',
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 40 dp rounded filter button of the Figma row.
///
/// Opens a bottom sheet with the same filter options as the tab bar.
class _FilterChip extends StatelessWidget {
  const _FilterChip();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Feed filters',
      child: InkWell(
        onTap: () => _showFilterSheet(context),
        borderRadius: BorderRadius.circular(20),
        child: Tooltip(
          message: 'Filter feed',
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.screenBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final PostCubit cubit = context.read<PostCubit>();
    final FeedFilter selected = cubit.state.filter;

    await showModalBottomSheet<FeedFilter>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: <Widget>[
                  Text('Filter feed', style: AppTypography.sectionTitle),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...FeedFilter.values.map((FeedFilter filter) {
              final bool isSelected = filter == selected;
              return ListTile(
                dense: true,
                title: Text(filter.label, style: AppTypography.body),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: AppColors.primaryDark, size: 20)
                    : null,
                onTap: () {
                  cubit.changeFilter(filter);
                  Navigator.of(sheetContext).pop();
                },
                selected: isSelected,
                selectedTileColor: AppColors.accentTint.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Scrollable list of `PostCard`s with pull-to-refresh.
class _PostList extends StatelessWidget {
  const _PostList({required this.state});

  final PostState state;

  @override
  Widget build(BuildContext context) {
    final String currentUserId = context.read<AuthCubit>().state.user?.id ?? '';

    return RefreshIndicator(
      onRefresh: context.read<PostCubit>().refresh,
      color: AppColors.primaryDark,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          // Leaves room for the floating bottom bar + gradient FAB.
          96,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.posts.length,
        itemBuilder: (BuildContext context, int index) {
          final Post post = state.posts[index];
          return PostCard(
            post: post,
            isOwnPost: post.authorId == currentUserId,
            onLike: () => context.read<PostCubit>().toggleLike(post),
            onDelete: post.authorId == currentUserId
                ? () => _confirmDelete(context, post.id)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String postId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete this post?'),
        content: const Text('This cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await context.read<PostCubit>().remove(postId);
  }
}
