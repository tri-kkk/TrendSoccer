import 'package:flutter/material.dart';

import '../../../../core/models/baseball_premium_data.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../shared/widgets/baseball/premium/confidence_chip.dart';
import '../../../../shared/widgets/baseball/premium/win_rate_box.dart';

/// Win rate split plus confidence for premium baseball.
class WinRateSection extends StatelessWidget {
  const WinRateSection({
    super.key,
    required this.winRate,
  });

  final WinRateData winRate;

  @override
  Widget build(BuildContext context) {
    final confidenceLabelStyle = AppTypography.labelLarge.copyWith(
      color: AppColors.textSecondary,
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
                'Win Rate',
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
                    child: WinRateBox(
                      team: 'Team',
                      stats: winRate.awayWinPercent,
                      isAway: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: WinRateBox(
                      team: 'Team',
                      stats: winRate.homeWinPercent,
                      isAway: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Confidence',
                    style: confidenceLabelStyle,
                  ),
                  ConfidenceChip(level: winRate.confidence),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
