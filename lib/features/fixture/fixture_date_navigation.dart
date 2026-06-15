import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/shared/widgets/fixture/date_nav_chip.dart';

class FixtureDateNavigation extends StatelessWidget {
  const FixtureDateNavigation({
    required this.scrollController,
    required this.chipDates,
    required this.selectedDateStr,
    required this.isLiveFilter,
    required this.todayDay,
    required this.weekdayLabels,
    required this.todayLabel,
    required this.onLiveTap,
    required this.onDateTap,
    this.chipGap = 8,
    super.key,
  });

  final ScrollController scrollController;
  final List<DateTime> chipDates;
  final String selectedDateStr;
  final bool isLiveFilter;
  final DateTime todayDay;
  final List<String> weekdayLabels;
  final String todayLabel;
  final VoidCallback onLiveTap;
  final ValueChanged<int> onDateTap;
  final double chipGap;

  static final _md = DateFormat('M.dd');

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DateNavChip(
              type: DateNavChipType.live,
              isActive: isLiveFilter,
              onTap: onLiveTap,
            ),
            SizedBox(width: chipGap),
            for (var i = 0; i < chipDates.length; i++) ...[
              if (i > 0) SizedBox(width: chipGap),
              DateNavChip(
                type: _isSameDay(chipDates[i], todayDay)
                    ? DateNavChipType.today
                    : DateNavChipType.date,
                dayLabel: _isSameDay(chipDates[i], todayDay)
                    ? todayLabel
                    : weekdayLabels[chipDates[i].weekday - 1],
                dateLabel: _md.format(chipDates[i]),
                isActive: !isLiveFilter &&
                    selectedDateStr == fixtureDateString(chipDates[i]),
                onTap: () => onDateTap(i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
