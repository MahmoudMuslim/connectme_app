import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'gradient_fab.dart';

/// Tabs of the home shell, in the order of the Figma bottom bar
/// (icon · icon · FAB · icon · icon).
enum HomeTab {
  /// Community feed.
  feed(Icons.home_outlined, Icons.home_rounded, 'Feed'),

  /// Community map with member markers.
  map(Icons.map_outlined, Icons.map_rounded, 'Map'),

  /// Donations — kept as a tab so the center FAB keeps its slot.
  donations(
    Icons.volunteer_activism_outlined,
    Icons.volunteer_activism_rounded,
    'Donate',
  ),

  /// Profile, reachable only after a biometric challenge.
  profile(Icons.person_outline_rounded, Icons.person_rounded, 'Profile');

  const HomeTab(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom navigation bar with a centre gradient FAB.
///
/// The layout reproduces the Figma bar exactly: four 24 dp icons with the 60 dp
/// gradient circle floating above the middle slot.
class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    required this.current,
    required this.onTabSelected,
    required this.onFabPressed,
    super.key,
  });

  final HomeTab current;
  final ValueChanged<HomeTab> onTabSelected;

  /// Opens the post composer.
  final VoidCallback onFabPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              // The centre gradient action button (rendered FIRST so icons stay clickable).
              Positioned(top: -22, child: GradientFab(onPressed: onFabPressed)),
              // Two icons on the left of the FAB.
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _NavIcon(
                      tab: HomeTab.feed,
                      isSelected: current == HomeTab.feed,
                      onTap: () => onTabSelected(HomeTab.feed),
                    ),
                    const SizedBox(width: AppSpacing.iconGap),
                    _NavIcon(
                      tab: HomeTab.map,
                      isSelected: current == HomeTab.map,
                      onTap: () => onTabSelected(HomeTab.map),
                    ),
                  ],
                ),
              ),
              // Two icons on the right of the FAB.
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _NavIcon(
                      tab: HomeTab.donations,
                      isSelected: current == HomeTab.donations,
                      onTap: () => onTabSelected(HomeTab.donations),
                    ),
                    const SizedBox(width: AppSpacing.iconGap),
                    _NavIcon(
                      tab: HomeTab.profile,
                      isSelected: current == HomeTab.profile,
                      onTap: () => onTabSelected(HomeTab.profile),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single tappable bottom-bar glyph.
class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final HomeTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 48,
          height: 44,
          child: Icon(
            isSelected ? tab.selectedIcon : tab.icon,
            size: 24,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
