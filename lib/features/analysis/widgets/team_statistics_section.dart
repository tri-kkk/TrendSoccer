import 'package:flutter/material.dart';

import '../../../core/models/soccer_match_report.dart';
import '../../../shared/widgets/report/report_section_card.dart';
import '../../../shared/widgets/report/split_gauge_bar.dart';

class TeamStatisticsSection extends StatelessWidget {
  const TeamStatisticsSection({
    super.key,
    required this.stats,
    required this.isBlurred,
    required this.blurText,
  });

  final List<TeamStat> stats;
  final bool isBlurred;
  final String blurText;

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Team Statistics',
      isBlurred: isBlurred,
      blurText: blurText,
      child: Column(
        children: List.generate(stats.length, (i) {
          final s = stats[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < stats.length - 1 ? 8 : 0),
            child: SplitGaugeBar(
              homeValue: s.homeValue,
              awayValue: s.awayValue,
              homeLabel: '${(s.homeValue * 100).round()}%',
              awayLabel: '${(s.awayValue * 100).round()}%',
              centerLabel: s.label,
            ),
          );
        }),
      ),
    );
  }
}
