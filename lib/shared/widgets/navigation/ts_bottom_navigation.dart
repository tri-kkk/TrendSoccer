import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class TsBottomNavigation extends StatelessWidget {
  const TsBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<String> _labels = [
    'Trend',
    'Analysis',
    'Fixture',
    'Premium',
    'Menu',
  ];

  static const List<IconData> _icons = [
    Icons.trending_up,
    Icons.insert_chart_outlined,
    Icons.calendar_today,
    Icons.workspace_premium,
    Icons.menu,
  ];

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Container(
      height: 80,
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
              icon: _icons[index],
              label: _labels[index],
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
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
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
              Icon(icon, size: 24, color: color),
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
