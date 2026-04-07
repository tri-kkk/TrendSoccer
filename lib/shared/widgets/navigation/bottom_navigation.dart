import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/component_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// TrendSoccer bottom navigation bar component.
///
/// Displays five tabs matching the Figma Bottom Navigation design:
/// Trend, Analysis, Fixture, Report, Menu.
///
/// Each tab shows an icon (24px) and a label (Poppins Medium 11px),
/// separated by 4px gap inside a 82×56 hit area.
///
/// ```dart
/// CustomBottomNavigation(
///   currentTab: NavigationTab.trend,
///   onTabChanged: (tab) => setState(() => _tab = tab),
/// )
/// ```
class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  /// Currently active tab.
  final NavigationTab currentTab;

  /// Called when the user taps a tab.
  final ValueChanged<NavigationTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.navBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surfaceBase,
        border: Border(
          top: BorderSide(color: AppColors.textDisabled),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: NavigationTab.values.map((tab) {
          final isActive = tab == currentTab;
          return _TabItem(
            tab: tab,
            isActive: isActive,
            onTap: () => onTabChanged(tab),
          );
        }).toList(),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final NavigationTab tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary500 : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 82,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? tab.activeIcon : tab.icon,
              size: AppSpacing.iconSize,
              color: color,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tab.label,
              style: AppTypography.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
