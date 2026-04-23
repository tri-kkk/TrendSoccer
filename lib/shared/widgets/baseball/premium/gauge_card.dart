import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';

/// Horizontal gauge comparing away (red) vs home (teal) for a stat.
class GaugeCard extends StatelessWidget {
  const GaugeCard({
    super.key,
    required this.label,
    required this.awayValue,
    required this.homeValue,
    required this.awayRatio,
  });

  final String label;
  final String awayValue;
  final String homeValue;

  /// Away segment width fraction \([0.0, 1.0]\); remainder is home.
  final double awayRatio;

  @override
  Widget build(BuildContext context) {
    final r = awayRatio.clamp(0.0, 1.0);
    final labelStyle = AppTypography.labelSmall.copyWith(
      color: AppColors.textTertiary,
      fontWeight: FontWeight.w500,
    );
    final valueAwayStyle = AppTypography.labelSmall.copyWith(
      color: AppColors.errorRed500,
      fontWeight: FontWeight.w500,
    );
    final valueHomeStyle = AppTypography.labelSmall.copyWith(
      color: AppColors.primary500,
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: labelStyle,
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: SizedBox(
              height: 8,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppColors.primary500),
                  FractionallySizedBox(
                    widthFactor: r,
                    alignment: Alignment.centerLeft,
                    child: const ColoredBox(color: AppColors.errorRed500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(awayValue, style: valueAwayStyle),
              Text(homeValue, style: valueHomeStyle),
            ],
          ),
        ],
      ),
    );
  }
}
