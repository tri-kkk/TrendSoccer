import 'package:flutter/material.dart';

import '../../../../core/models/baseball_premium_data.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../shared/widgets/baseball/premium/info_box.dart';

/// Home vs away win rates over a recent window (e.g. last 10 games).
class HomeAwayRecordSection extends StatelessWidget {
  const HomeAwayRecordSection({
    super.key,
    required this.homeAwayRecord,
  });

  final HomeAwayRecord homeAwayRecord;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Home/Away Record',
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
          child: Row(
            children: [
              Expanded(
                child: InfoBox(
                  label: 'Away Win',
                  stats: homeAwayRecord.awayWinPercent,
                  team: 'Away',
                  isAway: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: InfoBox(
                  label: 'Home Win',
                  stats: homeAwayRecord.homeWinPercent,
                  team: 'Home',
                  isAway: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
