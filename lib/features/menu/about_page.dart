import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/logo/ts_logo.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = isDark ? TsLogoColor.white : TsLogoColor.black;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: const TsAppBar(
        location: TsAppBarLocation.backTitle,
        title: 'About',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: TsLogo(type: TsLogoType.vertical, color: logoColor),
            ),
            const SizedBox(height: TsSpacing.sm),
            Text(
              '서비스 소개',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: TsSpacing.sm),
            Text(
              'TrendSoccer는 통계 데이터와 AI 알고리즘 기반의 경기 분석 인사이트를 제공하는 스마트 스포츠 컴패니언입니다.',
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: TsSpacing.xl),
            Text(
              'Key Features',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: TsSpacing.sm),
            _FeatureBullets(
              items: const [
                '데이터 기반 경기 분석',
                'AI 알고리즘 PREMIUM PICK',
                '축구 + 야구 멀티 스포츠',
                '실시간 스코어 및 경기 일정',
              ],
            ),
            const SizedBox(height: TsSpacing.xl),
            Text(
              'Contact',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: TsSpacing.sm),
            Text(
              'support@trendsoccer.com',
              style: TsType.bodyLRegular.copyWith(color: semantic.interactivePrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBullets extends StatelessWidget {
  const _FeatureBullets({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: semantic.interactivePrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: Text(
                  items[i],
                  style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
