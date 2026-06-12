import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/auth/benefit_text.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class WhatsNextCard extends StatelessWidget {
  const WhatsNextCard({
    this.onUpgradeTap,
    super.key,
  });

  final VoidCallback? onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's Next",
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.md),
          BenefitText(
            text: l10n.signupWhatsNextBenefit1,
            isPremium: true,
          ),
          const SizedBox(height: TsSpacing.md),
          BenefitText(
            text: l10n.signupWhatsNextBenefit2,
            isPremium: true,
          ),
          const SizedBox(height: TsSpacing.xs),
          TsButton(
            label: 'Upgrade to Premium →',
            variant: TsButtonVariant.secondary,
            onPressed: onUpgradeTap,
          ),
        ],
      ),
    );
  }
}
