import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Season year pill; [isActive] highlights the current season.
class SeasonChip extends StatelessWidget {
  const SeasonChip({
    super.key,
    required this.year,
    required this.isActive,
  });

  /// Season label (e.g. `'2026'`, `'2025'`).
  final String year;

  /// `true` when this is the current season.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isActive ? AppColors.primary500 : AppColors.surfaceContainer;
    final textColor =
        isActive ? AppColors.surfaceBase : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        year,
        style: AppTypography.labelSmall.copyWith(color: textColor),
      ),
    );
  }
}
