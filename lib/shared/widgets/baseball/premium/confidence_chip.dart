import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';

/// Confidence level indicator (High / Medium / Low) for premium baseball UI.
class ConfidenceChip extends StatelessWidget {
  const ConfidenceChip({
    super.key,
    required this.level,
  });

  /// `'High'`, `'Medium'`, or `'Low'` (matched case-insensitively).
  final String level;

  Color get _color {
    switch (level.trim().toLowerCase()) {
      case 'high':
        return AppColors.accent;
      case 'medium':
        return AppColors.warningAmber500;
      case 'low':
        return AppColors.errorRed500;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final textStyle = AppTypography.labelLarge.copyWith(
      color: color,
      fontWeight: FontWeight.w500,
    );

    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(level, style: textStyle),
        ],
      ),
    );
  }
}
