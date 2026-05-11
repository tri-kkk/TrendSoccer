import 'package:flutter/material.dart';

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
          const BenefitText(
            text: '48시간 무료 체험 종료 후 자동 무료 전환',
            isPremium: true,
          ),
          const SizedBox(height: TsSpacing.md),
          const BenefitText(
            text: '프리미엄 구독으로 모든 기능 이용 가능',
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
