import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../buttons/primary_button.dart';
import 'benefit_text.dart';

class WhatsNextCard extends StatelessWidget {
  final VoidCallback onUpgradePressed;

  const WhatsNextCard({
    super.key,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's Next ?",
            style: AppTypography.enLabelLarge.copyWith(
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const BenefitText(
            text: 'Start exploring predictions',
            type: BenefitType.premium,
          ),
          const SizedBox(height: AppSpacing.xl),
          const BenefitText(
            text: 'Upgrade for Premium picks',
            type: BenefitType.premium,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Upgrade to Premium',
            onPressed: onUpgradePressed,
            size: ButtonSize.large,
          ),
        ],
      ),
    );
  }
}
