import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// One totals line with over / under odds and optional baseline highlight.
class LineRow extends StatelessWidget {
  const LineRow({
    super.key,
    required this.line,
    required this.isBaseLine,
    required this.overOdds,
    required this.underOdds,
  });

  /// Line value (e.g. `'7.5'`, `'8'`).
  final String line;

  /// When `true`, shows a compact `"Line"` badge next to the number.
  final bool isBaseLine;

  final String overOdds;
  final String underOdds;

  @override
  Widget build(BuildContext context) {
    final lineStyle = AppTypography.labelLarge.copyWith(
      color: AppColors.textPrimary,
    );
    final oddsBase = AppTypography.titleSmall;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: lineStyle,
                ),
              ),
              if (isBaseLine) ...[
                const SizedBox(width: AppSpacing.xs),
                const _LineBadge(),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Center(
            child: Text(
              overOdds,
              style: oddsBase.copyWith(color: AppColors.errorRed500),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Center(
            child: Text(
              underOdds,
              style: oddsBase.copyWith(color: AppColors.primary500),
            ),
          ),
        ),
      ],
    );
  }
}

class _LineBadge extends StatelessWidget {
  const _LineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 158, 11, 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        'Line',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.warningAmber500,
        ),
      ),
    );
  }
}
