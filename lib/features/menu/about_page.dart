import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/back_button.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: AppBar(
        backgroundColor: semantic.surfaceBase,
        elevation: 0,
        leading: TsBackButton(onPressed: () => context.pop()),
        title: Text(
          'About',
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              TsAssets.logoSymbol(Theme.of(context).brightness),
              width: 68,
              height: 120,
            ),
            const SizedBox(height: 8),
            Text(
              'About',
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'TrendSoccer',
              style: TsType.displayHero.copyWith(color: semantic.interactivePrimary),
            ),
            const SizedBox(height: 24),
            Text(
              'Reading the Flow of Football Through Data',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'TrendSoccer는 AI 기반 실시간 분석으로 경기 흐름을 예측합니다. 프리미어리그부터 챔피언스리그까지, 모든 빅매치를 전문가 수준의 인사이트로 경험하세요.',
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: semantic.borderSubtle),
            const SizedBox(height: 24),
            Text(
              '주요 기능',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(semantic, 'AI 기반 분석', '4시즌 방대한 경기 데이터를 기반으로 구축'),
            const SizedBox(height: 8),
            _buildFeatureItem(semantic, '실시간 배당 분석', '배당 무브먼트에 따른 마켓 모니터링'),
            const SizedBox(height: 8),
            _buildFeatureItem(semantic, '글로벌 리그 지원', '주요 6대 리그 종합 데이터 지원'),
            const SizedBox(height: 24),
            Container(height: 1, color: semantic.borderSubtle),
            const SizedBox(height: 24),
            Text(
              '비전',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '축구 팬들이 경기를 더 깊이 이해하고 즐길 수 있도록 돕습니다.',
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: semantic.borderSubtle),
            const SizedBox(height: 24),
            Text(
              '컨택 & 서포트',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.mail_outline, size: 24, color: semantic.textSecondary),
                const SizedBox(width: 16),
                Text(
                  'tikilab2025@gmail.com',
                  style: TsType.bodyLRegular.copyWith(color: semantic.interactivePrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SvgPicture.asset(
                  TsAssets.iconLanguage,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    semantic.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'trendsoccer.com',
                  style: TsType.bodyLRegular.copyWith(color: semantic.interactivePrimary),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(TsSemanticColors semantic, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              TsAssets.iconCheckboxChecked,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                semantic.interactivePrimary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TsType.headingH3.copyWith(color: semantic.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
        ),
      ],
    );
  }
}
