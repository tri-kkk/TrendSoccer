import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Head-to-head win marker: [isHome] `true` = home win (red), `false` = away
/// win (green). Always shows `"W"`.
class H2hBadge extends StatelessWidget {
  const H2hBadge({
    super.key,
    required this.isHome,
  });

  /// `true` for a home-team win (red); `false` for an away-team win (green).
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isHome
        ? const Color.fromRGBO(239, 68, 68, 0.2)
        : const Color.fromRGBO(31, 154, 122, 0.2);
    final textColor =
        isHome ? AppColors.pickRed500 : AppColors.primary500;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        'W',
        style: AppTypography.labelSmall.copyWith(color: textColor),
      ),
    );
  }
}
