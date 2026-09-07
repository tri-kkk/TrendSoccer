import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_date_chip.dart';

/// Selected index when the strip ends at today (last chip).
const reportsHistoryDateStripSelectedIndex = 6;

/// Seven dates ending at today: today−6 … today (today is index 6).
List<DateTime> reportsHistoryDateStripDates([DateTime? anchor]) {
  final now = anchor ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return List.generate(
    7,
    (index) => today.subtract(Duration(days: 6 - index)),
  );
}

/// Seven-day date strip for reports Multi-Match — screen supplies dates and labels.
class ReportsDateStrip extends StatelessWidget {
  const ReportsDateStrip({
    required this.dates,
    required this.selectedIndex,
    required this.weekdayLabel,
    required this.isToday,
    required this.onSelected,
    super.key,
  }) : assert(dates.length == 7);

  static const chipGap = TsSpacing.sm;
  static const chipWidth = 47.43;
  static const stripHeight = 56.0;
  static const horizontalPadding = TsSpacing.lg;

  /// Figma frame width: 16 + 380 + 16.
  static const stripWidth =
      horizontalPadding * 2 + chipWidth * 7 + chipGap * 6;

  final List<DateTime> dates;
  final int selectedIndex;
  final String Function(DateTime date) weekdayLabel;
  final bool Function(DateTime date) isToday;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: stripHeight,
      width: stripWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            for (var index = 0; index < dates.length; index++) ...[
              if (index > 0) const SizedBox(width: chipGap),
              SizedBox(
                width: chipWidth,
                child: TsDateChip(
                  weekday: weekdayLabel(dates[index]),
                  day: dates[index].day.toString(),
                  selected: index == selectedIndex,
                  isToday: isToday(dates[index]),
                  onTap: () => onSelected(index),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
