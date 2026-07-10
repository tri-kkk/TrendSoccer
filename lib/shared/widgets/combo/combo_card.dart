import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/analysis_text_formatter.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_match_row.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_status_badge.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_type_badge.dart';

class ComboAiSection {
  const ComboAiSection({
    required this.label,
    required this.content,
    required this.type,
  });

  final String label;
  final String content;
  final String type;
}

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
  final int? homeScore;
  final int? awayScore;
}

class ComboCard extends StatelessWidget {
  const ComboCard({
    required this.leagueId,
    required this.comboCount,
    required this.comboType,
    required this.status,
    required this.matches,
    required this.aiSections,
    required this.totalOdds,
    required this.confidence,
    super.key,
  });

  final String leagueId;
  final int comboCount;
  final ComboType comboType;
  final ComboStatus status;
  final List<ComboMatchRowData> matches;
  final List<ComboAiSection> aiSections;
  final String totalOdds;
  final String confidence;

  Widget _divider(TsSemanticColors semantic) {
    return Container(
      height: 1,
      color: semantic.borderSubtle,
    );
  }

  Widget _footerColumn({
    required TsSemanticColors semantic,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              label,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: TsSpacing.xxs),
          SizedBox(
            width: double.infinity,
            child: Text(
              value,
              style: TsType.bodyLBold.copyWith(color: valueColor),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSectionBox(ComboAiSection section, TsSemanticColors colors) {
    late final Color bgColor;
    Color? borderColor;
    late final Color labelColor;

    switch (section.type) {
      case 'summary':
        bgColor = TsColors.brandPrimary500.withValues(alpha: 0.1);
        borderColor = TsColors.brandPrimary500.withValues(alpha: 0.3);
        labelColor = colors.interactivePrimary;
      case 'warning':
        bgColor = TsColors.systemWarning500.withValues(alpha: 0.1);
        borderColor = TsColors.systemWarning500.withValues(alpha: 0.15);
        labelColor = TsColors.systemWarning500;
      default:
        bgColor = colors.surfaceContainer;
        borderColor = null;
        labelColor = colors.textSecondary;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
        borderRadius: BorderRadius.circular(TsSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[${section.label}]',
            style: TsType.bodyMBold.copyWith(color: labelColor),
          ),
          const SizedBox(height: TsSpacing.xs),
          Text(
            formatComboAnalysisText(section.content),
            style: TsType.bodyMRegular.copyWith(
              color: colors.textPrimary,
              height: 18 / 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceBase,
        borderRadius: BorderRadius.circular(TsSpacing.md),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: TsSpacing.sm,
                        vertical: TsSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: semantic.surfaceContainer,
                        borderRadius: BorderRadius.circular(TsSpacing.sm),
                      ),
                      child: Text(
                        leagueId.toUpperCase(),
                        style: TsType.labelSBold.copyWith(
                          color: semantic.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Flexible(
                      child: Text(
                        l10n.comboFoldCount(comboCount),
                        style: TsType.bodyMBold.copyWith(
                          color: semantic.textPrimary,
                        ),
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
          _divider(semantic),
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
          _divider(semantic),
          if (aiSections.isNotEmpty) ...[
            const SizedBox(height: TsSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < aiSections.length; i++) ...[
                  if (i > 0) const SizedBox(height: TsSpacing.sm),
                  _buildAiSectionBox(aiSections[i], semantic),
                ],
              ],
            ),
            const SizedBox(height: TsSpacing.lg),
            _divider(semantic),
          ],
          const SizedBox(height: TsSpacing.lg),
          Row(
            children: [
              _footerColumn(
                semantic: semantic,
                label: l10n.comboTotalOdds,
                value: totalOdds,
                valueColor: semantic.interactivePrimary,
              ),
              _footerColumn(
                semantic: semantic,
                label: l10n.comboReliability,
                value: confidence,
                valueColor: semantic.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Opacity(
            opacity: 0.5,
            child: Text(
              l10n.comboAiDisclaimer,
              style: TsType.labelSRegular.copyWith(color: semantic.textDisabled),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
