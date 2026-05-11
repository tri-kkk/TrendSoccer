import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/menu/plan_card.dart';
import 'package:trendsoccer/shared/widgets/menu/plan_option.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  PlanOptionType _selectedPlan = PlanOptionType.threeMonth;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: const TsAppBar(
        location: TsAppBarLocation.backTitle,
        title: '구독',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Get Full Access\nTo The AI Assistant',
              style: TsType.headingH1.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: TsSpacing.sm),
            Text(
              '프리미엄 구독으로 모든 기능을 이용하세요',
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: TsSpacing.xl),
            PlanCard(
              type: PlanCardType.free,
              benefits: const [
                PlanBenefitItem(text: '경기 시작 2시간 전 분석 오픈'),
                PlanBenefitItem(text: '기본 분석 데이터'),
                PlanBenefitItem(text: '실시간 스코어'),
                PlanBenefitItem(text: '광고 포함', isIncluded: false),
              ],
            ),
            const SizedBox(height: TsSpacing.xl),
            PlanCard(
              type: PlanCardType.premium,
              benefits: const [
                PlanBenefitItem(text: '경기 시작 24시간 전 우선 접근'),
                PlanBenefitItem(text: 'PREMIUM PICK 무제한'),
                PlanBenefitItem(text: '야구 AI Analysis'),
                PlanBenefitItem(text: '야구 조합'),
                PlanBenefitItem(text: '광고 없음'),
              ],
            ),
            const SizedBox(height: TsSpacing.sm),
            Text(
              '구독 상품 선택',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: TsSpacing.md),
            PlanOption(
              type: PlanOptionType.threeMonth,
              isSelected: _selectedPlan == PlanOptionType.threeMonth,
              onTap: () => setState(() => _selectedPlan = PlanOptionType.threeMonth),
            ),
            const SizedBox(height: TsSpacing.sm),
            PlanOption(
              type: PlanOptionType.oneMonth,
              isSelected: _selectedPlan == PlanOptionType.oneMonth,
              onTap: () => setState(() => _selectedPlan = PlanOptionType.oneMonth),
            ),
            const SizedBox(height: TsSpacing.xl),
            TsButton(
              label: 'Start Premium →',
              variant: TsButtonVariant.primary,
              onPressed: null,
            ),
            const SizedBox(height: TsSpacing.xl),
          ],
        ),
      ),
    );
  }
}
