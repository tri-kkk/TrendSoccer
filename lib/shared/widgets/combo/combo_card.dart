import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_match_row.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_status_badge.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_type_badge.dart';

class ComboMatchRowData {
  const ComboMatchRowData({
    required this.homeTeam,
    required this.awayTeam,
    required this.predictTeam,
    required this.predictDirection,
    required this.odds,
    required this.winRate,
    required this.winRateRatio,
    required this.comment,
    this.homeLogoUrl,
    this.awayLogoUrl,
    this.matchResult,
    this.homeScore,
    this.awayScore,
  });

  final String homeTeam;
  final String awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final String predictTeam;
  final String predictDirection;
  final String odds;
  final String winRate;
  final double winRateRatio;
  final String comment;
  final ComboStatus? matchResult;
  final String? homeScore;
  final String? awayScore;
}

class ComboCard extends StatelessWidget {
  const ComboCard({
    required this.leagueId,
    required this.comboCount,
    required this.comboType,
    required this.status,
    required this.matches,
    required this.aiReport,
    required this.totalOdds,
    required this.confidence,
    super.key,
  });

  final String leagueId;
  final int comboCount;
  final ComboType comboType;
  final ComboStatus status;
  final List<ComboMatchRowData> matches;
  final String aiReport;
  final String totalOdds;
  final String confidence;

  static const Color _aiBg = Color(0x1A00DF81);
  static const Color _aiBorder = Color(0x4D00DF81);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: semantic.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        leagueId.toUpperCase(),
                        style: TsType.labelSBold.copyWith(color: semantic.textSecondary),
                      ),
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Flexible(
                      child: Text(
                        '$comboCount COMBO',
                        style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    ComboTypeBadge(type: comboType),
                  ],
                ),
              ),
              ComboStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Divider(height: 1, thickness: 1, color: semantic.borderSubtle),
          const SizedBox(height: TsSpacing.lg),
          for (var i = 0; i < matches.length; i++) ...[
            if (i > 0) const SizedBox(height: TsSpacing.sm),
            ComboMatchRow(
              homeTeam: matches[i].homeTeam,
              awayTeam: matches[i].awayTeam,
              homeLogoUrl: matches[i].homeLogoUrl,
              awayLogoUrl: matches[i].awayLogoUrl,
              predictTeam: matches[i].predictTeam,
              predictDirection: matches[i].predictDirection,
              odds: matches[i].odds,
              winRate: matches[i].winRate,
              winRateRatio: matches[i].winRateRatio,
              comment: matches[i].comment,
              matchResult: matches[i].matchResult,
              homeScore: matches[i].homeScore,
              awayScore: matches[i].awayScore,
            ),
          ],
          const SizedBox(height: TsSpacing.lg),
          Divider(height: 1, thickness: 1, color: semantic.borderSubtle),
          const SizedBox(height: TsSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TsSpacing.md),
            decoration: BoxDecoration(
              color: _aiBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _aiBorder, width: 1),
            ),
            child: Text(
              aiReport,
              style: TsType.bodyMRegular.copyWith(color: semantic.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: TsSpacing.lg),
          Divider(height: 1, thickness: 1, color: semantic.borderSubtle),
          const SizedBox(height: TsSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '총 배당',
                      style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalOdds,
                      style: TsType.bodyLBold.copyWith(color: semantic.interactivePrimary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '신뢰도',
                      style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      confidence,
                      style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Opacity(
            opacity: 0.5,
            child: Text(
              'AI 분석 결과는 참고용이며, 결과를 보장하지 않습니다.',
              style: TsType.labelSRegular.copyWith(color: semantic.textDisabled),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
