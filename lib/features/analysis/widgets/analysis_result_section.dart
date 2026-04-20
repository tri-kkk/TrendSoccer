import 'package:flutter/material.dart';

import '../../../core/models/soccer_match_report.dart';
import '../../../shared/widgets/badge/custom_badge.dart';
import '../../../shared/widgets/report/info_cell.dart';
import '../../../shared/widgets/report/report_section_card.dart';

class AnalysisResultSection extends StatelessWidget {
  const AnalysisResultSection({
    super.key,
    required this.report,
    required this.isBlurred,
    required this.blurText,
  });

  final SoccerMatchReport report;
  final bool isBlurred;
  final String blurText;

  BadgeType _badgeType(PickGrade grade) => switch (grade) {
        PickGrade.pick => BadgeType.pick,
        PickGrade.good => BadgeType.good,
        PickGrade.pass => BadgeType.pass,
      };

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      title: 'Analysis Result',
      isBlurred: isBlurred,
      blurText: blurText,
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: InfoCell(
                    label: 'Predict',
                    value: report.predict,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InfoCell(
                    label: 'Win %',
                    value: '${report.winPercent}%',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InfoCell(
                    label: 'Power Diff.',
                    value: '${report.powerDiff} pts',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: InfoCell(
                    label: 'Matches',
                    value: '${report.matchCount}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InfoCell(
                    label: 'Pattern',
                    value: report.pattern,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InfoCell(
                    label: 'Recommend',
                    valueWidget: CustomBadge(
                      type: _badgeType(report.recommendGrade),
                      label: report.recommendGrade.name.toUpperCase(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
