import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

enum BenefitType { free, premium }

class BenefitText extends StatelessWidget {
  final String text;
  final BenefitType type;

  const BenefitText({
    super.key,
    required this.text,
    this.type = BenefitType.free,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check,
          size: 24,
          color: type == BenefitType.free
              ? AppColors.brandPrimary500
              : AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
