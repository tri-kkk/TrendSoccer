import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Full-width comment line with positive / negative styling.
class CommentChip extends StatelessWidget {
  const CommentChip({
    super.key,
    required this.text,
    required this.isPositive,
  });

  /// Comment body.
  final String text;

  /// `true` for positive (teal); `false` for negative (red).
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPositive
        ? const Color.fromRGBO(31, 154, 122, 0.2)
        : const Color.fromRGBO(239, 68, 68, 0.2);
    final textColor =
        isPositive ? AppColors.primary500 : AppColors.pickRed500;

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          text,
          style: AppTypography.labelSmall.copyWith(color: textColor),
        ),
      ),
    );
  }
}
