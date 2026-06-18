import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

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

class DateTabBar extends StatefulWidget {
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
  static const double tabWidth = 80;

  @override
  State<DateTabBar> createState() => _DateTabBarState();
}

class _DateTabBarState extends State<DateTabBar> {
  ScrollController? _ownedScrollController;

  ScrollController? get _effectiveScrollController =>
      widget.fillWidth ? null : (widget.scrollController ?? _ownedScrollController);

  @override
  void initState() {
    super.initState();
    if (!widget.fillWidth && widget.scrollController == null) {
      _ownedScrollController = ScrollController();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedTab());
  }

  @override
  void didUpdateWidget(covariant DateTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedTab());
    }
  }

  @override
  void dispose() {
    _ownedScrollController?.dispose();
    super.dispose();
  }

  void _scrollToSelectedTab() {
    final controller = _effectiveScrollController;
    if (controller == null || !controller.hasClients) return;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final offset = widget.selectedIndex * DateTabBar.tabWidth;
    final targetOffset =
        (offset - screenWidth / 2 + DateTabBar.tabWidth / 2)
            .clamp(0.0, controller.position.maxScrollExtent);

    controller.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final background = widget.backgroundColor ?? semantic.surfaceRaised;

    final tabs = [
      for (var i = 0; i < widget.dates.length; i++)
        _DateTab(
          item: widget.dates[i],
          isSelected: i == widget.selectedIndex,
          semantic: semantic,
          expanded: widget.fillWidth,
          onTap: () => widget.onDateSelected(i),
        ),
    ];

    return ColoredBox(
      color: background,
      child: SizedBox(
        height: DateTabBar.barHeight,
        child: widget.fillWidth
            ? Row(children: [for (final tab in tabs) Expanded(child: tab)])
            : SingleChildScrollView(
                controller: _effectiveScrollController,
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        SizedBox(
                          width: DateTabBar.tabWidth,
                          child: tabs[i],
                        ),
                    ],
                  ),
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
        width: expanded ? null : double.infinity,
        height: DateTabBar.barHeight,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.xs),
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
            const SizedBox(height: TsSpacing.xxs),
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
