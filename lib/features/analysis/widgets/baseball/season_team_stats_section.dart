import 'package:flutter/material.dart';

import '../../../../core/models/baseball_premium_data.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../shared/widgets/baseball/premium/gauge_card.dart';

/// Season-long AVG / OPS / ERA / WHIP comparison gauges.
class SeasonTeamStatsSection extends StatelessWidget {
  const SeasonTeamStatsSection({
    super.key,
    required this.seasonStats,
  });

  final SeasonTeamStatsData seasonStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Season Team Stats',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
              Row(
                children: [
                  Expanded(
                    child: GaugeCard(
                      label: 'AVG',
                      awayValue: seasonStats.avg.awayValue,
                      homeValue: seasonStats.avg.homeValue,
                      awayRatio: seasonStats.avg.awayRatio,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GaugeCard(
                      label: 'OPS',
                      awayValue: seasonStats.ops.awayValue,
                      homeValue: seasonStats.ops.homeValue,
                      awayRatio: seasonStats.ops.awayRatio,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: GaugeCard(
                      label: 'ERA',
                      awayValue: seasonStats.era.awayValue,
                      homeValue: seasonStats.era.homeValue,
                      awayRatio: seasonStats.era.awayRatio,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GaugeCard(
                      label: 'WHIP',
                      awayValue: seasonStats.whip.awayValue,
                      homeValue: seasonStats.whip.homeValue,
                      awayRatio: seasonStats.whip.awayRatio,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
