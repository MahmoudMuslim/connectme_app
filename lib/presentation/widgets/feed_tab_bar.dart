import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/post.dart';

/// Segmented control of the feed (`Popular` / `Trending` / `Following`).
///
/// The selected tab uses the `#F1F1FD` pill with a bold `#888BF4` label, the
/// inactive ones a `#BDBDBD` regular label — exactly like the Figma frame.
class FeedTabBar extends StatelessWidget {
  const FeedTabBar({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final FeedFilter selected;
  final ValueChanged<FeedFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm - 2,
        vertical: 6,
      ),
      color: AppColors.white,
      child: Row(
        children: FeedFilter.values.map((FeedFilter filter) {
          final bool isSelected = filter == selected;
          return Expanded(
            child: _FeedTab(
              label: filter.label,
              isSelected: isSelected,
              onTap: () => onChanged(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.tab),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentTint : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.tab),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? AppColors.primaryLight
                  : AppColors.textTertiary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
