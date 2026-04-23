import 'package:flutter/material.dart';

import '../../../../core/models/baseball_match_report.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../shared/widgets/baseball/h2h_matchup_row.dart';

/// Head-to-head history list (e.g. last five matchups).
class BaseballH2hSection extends StatelessWidget {
  const BaseballH2hSection({super.key, required this.records});

  final List<H2HRecord> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'H2H',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < records.length; i++) ...[
                H2hMatchupRow(
                  date: records[i].date,
                  awayTeam: records[i].awayTeam,
                  homeTeam: records[i].homeTeam,
                  awayScore: records[i].awayScore,
                  homeScore: records[i].homeScore,
                  winner: records[i].winner,
                ),
                if (i < records.length - 1) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
