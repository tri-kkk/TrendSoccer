import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';

class TodayComboCard extends StatelessWidget {
  const TodayComboCard({
    required this.comboCount,
    required this.accuracy,
    required this.avgOdds,
    this.onTap,
    super.key,
  });

  final int comboCount;
  final String accuracy;
  final String avgOdds;
  final VoidCallback? onTap;

  static const List<({String leagueId, String label, Color borderColor, Color backgroundColor})>
      _leagues = [
    (
      leagueId: 'kbo',
      label: 'KBO',
      borderColor: Color.fromRGBO(239, 68, 68, 0.1),
      backgroundColor: Color.fromRGBO(239, 68, 68, 0.06),
    ),
    (
      leagueId: 'mlb',
      label: 'MLB',
      borderColor: Color.fromRGBO(0, 194, 255, 0.1),
      backgroundColor: Color.fromRGBO(0, 194, 255, 0.06),
    ),
    (
      leagueId: 'npb',
      label: 'NPB',
      borderColor: Color.fromRGBO(245, 158, 11, 0.1),
      backgroundColor: Color.fromRGBO(245, 158, 11, 0.06),
    ),
  ];

  Widget _leagueBadge({
    required BuildContext context,
    required String leagueId,
    required String label,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
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
            label,
            style: TsType.labelSBold.copyWith(color: semantic.textPrimary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '오늘의 추천 조합',
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _leagues.length; i++) ...[
                if (i > 0) const SizedBox(width: TsSpacing.md),
                _leagueBadge(
                  context: context,
                  leagueId: _leagues[i].leagueId,
                  label: _leagues[i].label,
                  borderColor: _leagues[i].borderColor,
                  backgroundColor: _leagues[i].backgroundColor,
                ),
              ],
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
          Container(
            height: 1,
            color: semantic.borderSubtle,
          ),
          const SizedBox(height: TsSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(TsSpacing.md),
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
                        '$comboCount',
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
                  padding: const EdgeInsets.all(TsSpacing.md),
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
                  padding: const EdgeInsets.all(TsSpacing.md),
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
          Container(
            height: 1,
            color: semantic.borderSubtle,
          ),
          const SizedBox(height: TsSpacing.lg),
          TsButton(
            label: '오늘의 조합 확인하기 →',
            variant: TsButtonVariant.primary,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
