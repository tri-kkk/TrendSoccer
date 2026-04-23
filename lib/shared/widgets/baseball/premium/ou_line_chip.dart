import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';

/// Highlights the active over/under line (e.g. `"Line 8"`).
class OuLineChip extends StatelessWidget {
  const OuLineChip({
    super.key,
    required this.line,
  });

  final String line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 158, 11, 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      alignment: Alignment.center,
      child: Text(
        line,
        textAlign: TextAlign.center,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.warningAmber500,
        ),
      ),
    );
  }
}
