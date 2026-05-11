import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/auth/benefit_text.dart';

class FreeBenefitsCard extends StatelessWidget {
  const FreeBenefitsCard({super.key});

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
            'Free Benefits',
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.md),
          const BenefitText(text: '기본 분석 데이터 확인'),
          const SizedBox(height: TsSpacing.md),
          const BenefitText(text: '실시간 스코어 및 경기 일정'),
          const SizedBox(height: TsSpacing.md),
          const BenefitText(text: '야구 Standard 분석 열람'),
        ],
      ),
    );
  }
}
