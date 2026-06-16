import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class DateTabItem {
  const DateTabItem({
    required this.dayLabel,
    required this.dateLabel,
    this.isToday = false,
  });

  final String dayLabel;
  final String dateLabel;
  final bool isToday;
}

class DateTabBar extends StatelessWidget {
  const DateTabBar({
    required this.dates,
    required this.selectedIndex,
    required this.onDateSelected,
    this.scrollController,
    this.backgroundColor,
    this.fillWidth = false,
    super.key,
  });

  final List<DateTabItem> dates;
  final int selectedIndex;
  final ValueChanged<int> onDateSelected;
  final ScrollController? scrollController;
  final Color? backgroundColor;
  final bool fillWidth;

  static const double barHeight = 56;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final background = backgroundColor ?? semantic.surfaceRaised;

    final tabs = [
      for (var i = 0; i < dates.length; i++)
        _DateTab(
          item: dates[i],
          isSelected: i == selectedIndex,
          semantic: semantic,
          expanded: fillWidth,
          onTap: () => onDateSelected(i),
        ),
    ];

    return ColoredBox(
      color: background,
      child: SizedBox(
        height: barHeight,
        child: fillWidth
            ? Row(children: [for (final tab in tabs) Expanded(child: tab)])
            : SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < tabs.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      tabs[i],
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _DateTab extends StatelessWidget {
  const _DateTab({
    required this.item,
    required this.isSelected,
    required this.semantic,
    required this.onTap,
    this.expanded = false,
  });

  final DateTabItem item;
  final bool isSelected;
  final TsSemanticColors semantic;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final dayColor =
        isSelected ? semantic.interactivePrimary : semantic.textTertiary;
    final dateColor =
        isSelected ? semantic.interactivePrimary : semantic.textSecondary;
    final borderColor =
        isSelected ? semantic.interactivePrimary : semantic.textTertiary;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: expanded ? null : const BoxConstraints(minWidth: 80),
        height: DateTabBar.barHeight,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.dayLabel,
              style: TsType.labelSRegular.copyWith(color: dayColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              item.dateLabel,
              style: TsType.bodyLRegular.copyWith(color: dateColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
