import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';

/// Team win-rate tile (away = red, home = brand teal).
class WinRateBox extends StatelessWidget {
  const WinRateBox({
    super.key,
    required this.team,
    required this.stats,
    required this.isAway,
  });

  final String team;
  final String stats;

  /// `true` → [AppColors.errorRed500] for [stats]; `false` → [AppColors.primary500].
  final bool isAway;

  @override
  Widget build(BuildContext context) {
    final teamStyle = AppTypography.labelSmall.copyWith(
      color: AppColors.textTertiary,
    );
    final statsStyle = AppTypography.headlineSmall.copyWith(
      fontWeight: FontWeight.w700,
      color: isAway ? AppColors.errorRed500 : AppColors.primary500,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            team,
            textAlign: TextAlign.center,
            style: teamStyle,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            stats,
            textAlign: TextAlign.center,
            style: statsStyle,
          ),
        ],
      ),
    );
  }
}
