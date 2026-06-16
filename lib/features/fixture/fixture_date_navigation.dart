import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/shared/widgets/navigation/date_tab_bar.dart';

class FixtureDateNavigation extends StatelessWidget {
  const FixtureDateNavigation({
    required this.scrollController,
    required this.chipDates,
    required this.selectedDateStr,
    required this.todayDay,
    required this.weekdayLabels,
    required this.todayLabel,
    required this.onDateTap,
    super.key,
  });

  final ScrollController scrollController;
  final List<DateTime> chipDates;
  final String selectedDateStr;
  final DateTime todayDay;
  final List<String> weekdayLabels;
  final String todayLabel;
  final ValueChanged<int> onDateTap;

  static final _md = DateFormat('M.dd');

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final dates = [
      for (final date in chipDates)
        DateTabItem(
          dayLabel: _isSameDay(date, todayDay)
              ? todayLabel
              : weekdayLabels[date.weekday - 1],
          dateLabel: _md.format(date),
          isToday: _isSameDay(date, todayDay),
        ),
    ];

    final selectedIndex = chipDates.indexWhere(
      (date) => fixtureDateString(date) == selectedDateStr,
    );

    return DateTabBar(
      scrollController: scrollController,
      dates: dates,
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDateSelected: onDateTap,
    );
  }
}
