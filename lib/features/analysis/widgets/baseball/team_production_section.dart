import 'package:flutter/material.dart';

import '../../../../core/models/baseball_premium_data.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../shared/widgets/baseball/premium/gauge_card.dart';

/// Runs / allowed / hits gauges plus summary for premium baseball.
class TeamProductionSection extends StatelessWidget {
  const TeamProductionSection({
    super.key,
    required this.teamProduction,
  });

  final TeamProductionData teamProduction;

  @override
  Widget build(BuildContext context) {
    final summaryStyle = AppTypography.bodySmall.copyWith(
      color: AppColors.accent,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Team Production',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              'Last 10G',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
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
                      label: 'Runs',
                      awayValue: teamProduction.runs.awayValue,
                      homeValue: teamProduction.runs.homeValue,
                      awayRatio: teamProduction.runs.awayRatio,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GaugeCard(
                      label: 'Allowed',
                      awayValue: teamProduction.allowed.awayValue,
                      homeValue: teamProduction.allowed.homeValue,
                      awayRatio: teamProduction.allowed.awayRatio,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GaugeCard(
                      label: 'Hits',
                      awayValue: teamProduction.hits.awayValue,
                      homeValue: teamProduction.hits.homeValue,
                      awayRatio: teamProduction.hits.awayRatio,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  teamProduction.summary,
                  textAlign: TextAlign.center,
                  style: summaryStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
