import 'package:flutter/material.dart';

import '../../../../core/models/baseball_premium_data.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../shared/widgets/baseball/premium/info_box.dart';

/// Premium win probability tiles plus narrative.
class WinProbabilitySection extends StatelessWidget {
  const WinProbabilitySection({
    super.key,
    required this.winProbability,
  });

  final WinProbability winProbability;

  @override
  Widget build(BuildContext context) {
    final descriptionStyle = AppTypography.bodySmall.copyWith(
      color: AppColors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Win Probability',
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
              Row(
                children: [
                  Expanded(
                    child: InfoBox(
                      label: 'Win %',
                      stats: winProbability.awayWinPercent,
                      team: 'Away',
                      isAway: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InfoBox(
                      label: 'Win %',
                      stats: winProbability.homeWinPercent,
                      team: 'Home',
                      isAway: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                winProbability.description,
                textAlign: TextAlign.center,
                style: descriptionStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
