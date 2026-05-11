import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';

/// 오늘의 추천 조합 — Trend / Combo entry (Figma 963:12446).
class TodayComboCard extends StatelessWidget {
  const TodayComboCard({
    this.comboCount = '20',
    this.accuracy = '50%',
    this.avgOdds = '4.29',
    this.onCTATap,
    super.key,
  });

  final String comboCount;
  final String accuracy;
  final String avgOdds;
  final VoidCallback? onCTATap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: semantic.interactivePrimary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '오늘의 추천 조합',
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LeagueIconBox(
                bgColor: Color(0x0FEF4444),
                borderColor: Color(0x1AEF4444),
                leagueId: 'kbo',
                leagueName: 'KBO',
              ),
              SizedBox(width: TsSpacing.md),
              _LeagueIconBox(
                bgColor: Color(0x0F00C2FF),
                borderColor: Color(0x1A00C2FF),
                leagueId: 'mlb',
                leagueName: 'MLB',
              ),
              SizedBox(width: TsSpacing.md),
              _LeagueIconBox(
                bgColor: Color(0x0FF59E0B),
                borderColor: Color(0x1AF59E0B),
                leagueId: 'npb',
                leagueName: 'NPB',
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '오늘의 AI 조합을 확인하세요.',
                style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TsSpacing.xs),
              Text(
                '매일 3대 리그 AI 분석 조합 제공',
                style: TsType.labelSRegular.copyWith(
                  color: semantic.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Container(height: 1, width: double.infinity, color: semantic.borderSubtle),
          const SizedBox(height: TsSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: semantic.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '조합 수',
                        style: TsType.labelSRegular.copyWith(
                          color: semantic.textTertiary,
                        ),
                      ),
                      const SizedBox(height: TsSpacing.xs),
                      Text(
                        comboCount,
                        style: TsType.headingH2.copyWith(
                          color: semantic.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: semantic.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '정합도',
                        style: TsType.labelSRegular.copyWith(
                          color: semantic.textTertiary,
                        ),
                      ),
                      const SizedBox(height: TsSpacing.xs),
                      Text(
                        accuracy,
                        style: TsType.headingH2.copyWith(
                          color: semantic.interactivePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: semantic.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '평균 배당',
                        style: TsType.labelSRegular.copyWith(
                          color: semantic.textTertiary,
                        ),
                      ),
                      const SizedBox(height: TsSpacing.xs),
                      Text(
                        avgOdds,
                        style: TsType.headingH2.copyWith(
                          color: TsColors.systemWarning500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Container(height: 1, width: double.infinity, color: semantic.borderSubtle),
          const SizedBox(height: TsSpacing.lg),
          TsButton(
            label: '오늘의 조합 확인하기 →',
            variant: TsButtonVariant.primary,
            onPressed: onCTATap,
          ),
        ],
      ),
    );
  }
}

class _LeagueIconBox extends StatelessWidget {
  const _LeagueIconBox({
    required this.bgColor,
    required this.borderColor,
    required this.leagueId,
    required this.leagueName,
  });

  final Color bgColor;
  final Color borderColor;
  final String leagueId;
  final String leagueName;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TsLeagueIcon(leagueId: leagueId, size: 32),
          const SizedBox(height: TsSpacing.xs),
          Text(
            leagueName,
            style: TsType.labelSBold.copyWith(color: semantic.textPrimary),
          ),
        ],
      ),
    );
  }
}
