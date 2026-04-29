import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

class TrialBanner extends StatelessWidget {
  const TrialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary500.withValues(alpha: 0.2),
        border: Border.all(
          color: AppColors.brandPrimary500,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        '48-hour Premium Trial Activated!',
        style: AppTypography.enLabelLarge.copyWith(
          color: AppColors.accent,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
