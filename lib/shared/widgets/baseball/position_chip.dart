import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Compact label for baseball side: [Away] or [Home].
class PositionChip extends StatelessWidget {
  const PositionChip({
    super.key,
    required this.position,
  });

  /// Display text; expected values: `'Away'`, `'Home'`.
  final String position;

  bool get _isHome => position == 'Home';

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isHome
        ? const Color.fromRGBO(31, 154, 122, 0.2)
        : const Color.fromRGBO(239, 68, 68, 0.2);
    final textColor =
        _isHome ? AppColors.primary500 : AppColors.pickRed500;

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
        position,
        style: AppTypography.labelSmall.copyWith(color: textColor),
      ),
    );
  }
}
