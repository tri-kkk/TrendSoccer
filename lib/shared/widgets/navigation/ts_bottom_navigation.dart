import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';

class TsBottomNavigation extends StatelessWidget {
  const TsBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  /// Fixed outer height of the tab bar (matches [Container] below).
  static const double barHeight = 80;

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<String> _iconAssets = [
    TsAssets.iconTrend,
    TsAssets.iconAnalysis,
    TsAssets.iconFixture,
    TsAssets.iconPremium,
    TsAssets.iconMenu,
  ];

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final labels = [
      context.l10n.tabTrend,
      context.l10n.tabAnalysis,
      context.l10n.tabFixture,
      context.l10n.tabPremium,
      context.l10n.tabMenu,
    ];

    return Container(
      height: barHeight,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        border: Border(
          top: BorderSide(color: semantic.textDisabled, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: _NavTabItem(
              iconAsset: _iconAssets[index],
              label: labels[index],
              selected: index == currentIndex,
              onTap: () => onTap(index),
            ),
          );
        }),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.iconAsset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final color =
        selected ? semantic.interactivePrimary : semantic.textTertiary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: TsSpacing.xs),
              Text(
                label,
                style: TsType.labelXsBold.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
