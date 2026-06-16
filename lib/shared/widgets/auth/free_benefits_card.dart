import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/auth/benefit_text.dart';

class FreeBenefitsCard extends StatelessWidget {
  const FreeBenefitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceBase,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Free Benefits',
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.md),
          BenefitText(text: l10n.signupFreeBenefit1),
          const SizedBox(height: TsSpacing.md),
          BenefitText(text: l10n.signupFreeBenefit2),
          const SizedBox(height: TsSpacing.md),
          BenefitText(text: l10n.signupFreeBenefit3),
        ],
      ),
    );
  }
}
