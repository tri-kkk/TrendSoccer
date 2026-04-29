import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import 'benefit_text.dart';

class FreeBenefitsCard extends StatelessWidget {
  const FreeBenefitsCard({super.key});

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
            'Free Benefits',
            style: AppTypography.enLabelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const BenefitText(
            text: 'Analysis card unlocked 2 hours before kickoff',
            type: BenefitType.free,
          ),
          const SizedBox(height: AppSpacing.xl),
          const BenefitText(
            text: 'Basic match analysis and statistics',
            type: BenefitType.free,
          ),
          const SizedBox(height: AppSpacing.xl),
          const BenefitText(
            text: 'Real-time scores and match schedules',
            type: BenefitType.free,
          ),
        ],
      ),
    );
  }
}
