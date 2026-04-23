import 'package:flutter/material.dart';

import '../../../../core/models/baseball_premium_data.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../shared/widgets/baseball/premium/ou_line_chip.dart';
import '../../../../shared/widgets/baseball/premium/uo_box.dart';

/// Premium over/under line and split percentages.
class OverUnderSection extends StatelessWidget {
  const OverUnderSection({
    super.key,
    required this.overUnder,
  });

  final OverUnder overUnder;

  bool get _overFavored =>
      overUnder.favoredSide?.toLowerCase() == 'over';

  bool get _underFavored =>
      overUnder.favoredSide?.toLowerCase() == 'under';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Over / Under',
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OuLineChip(line: overUnder.baseLine),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: UoBox(
                      label: 'Over',
                      stats: overUnder.overPercent,
                      isFavored: _overFavored,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: UoBox(
                      label: 'Under',
                      stats: overUnder.underPercent,
                      isFavored: _underFavored,
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
