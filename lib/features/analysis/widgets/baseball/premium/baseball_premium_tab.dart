import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/features/analysis/models/baseball_premium_parser.dart';
import 'package:trendsoccer/features/analysis/models/parser_labels.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/premium/team_stat_gauge_card.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/confidence_chip.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/subscribe_sheet.dart';

class BaseballPremiumTab extends ConsumerStatefulWidget {
  const BaseballPremiumTab({
    required this.matchId,
    super.key,
  });

  final int matchId;

  @override
  ConsumerState<BaseballPremiumTab> createState() => _BaseballPremiumTabState();
}

class _BaseballPremiumTabState extends ConsumerState<BaseballPremiumTab> {
  bool _subscribeSheetShown = false;
  int? _loggedDetailMatchId;
  int? _loggedPredictMatchId;

  @override
  Widget build(BuildContext context) {
    final hasFullAccess = ref.watch(authProvider).hasFullAccess;

    if (!hasFullAccess) {
      if (!_subscribeSheetShown) {
        _subscribeSheetShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showSubscribeSheet(context, SportType.baseball);
        });
      }
      return const KeyedSubtree(
        key: ValueKey<Object>('baseball_report_premium_locked'),
        child: SizedBox.shrink(),
      );
    }

    final detailAsync = ref.watch(baseballMatchDetailProvider(widget.matchId));
    final predictAsync = ref.watch(baseballPredictProvider(widget.matchId));

    if (detailAsync.hasError) {
      return KeyedSubtree(
        key: const ValueKey<Object>('baseball_report_premium_error'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BaseballPremiumTabError(
            onRetry: () {
              ref.invalidate(baseballMatchDetailProvider(widget.matchId));
              ref.invalidate(baseballPredictProvider(widget.matchId));
            },
          ),
        ),
      );
    }

    if (detailAsync.isLoading) {
      return const KeyedSubtree(
        key: ValueKey<Object>('baseball_report_premium_loading'),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: BaseballPremiumTabLoading(),
        ),
      );
    }

    final detailData = detailAsync.value ?? {};
    if (_loggedDetailMatchId != widget.matchId) {
      _loggedDetailMatchId = widget.matchId;
      logBaseballPremiumDetail(detailData);
    }

    final predictData =
        predictAsync.hasValue ? predictAsync.value : null;
    if (predictData != null && _loggedPredictMatchId != widget.matchId) {
      _loggedPredictMatchId = widget.matchId;
      logBaseballPremiumPredict(predictData);
    }

    final parsed = BaseballPremiumParsed.fromResponses(
      matchData: detailData,
      predictData: predictData,
      labels: ParserLabels.from(context.l10n),
    );

    return KeyedSubtree(
      key: const ValueKey<Object>('baseball_report_premium'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AiAnalysisSection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _WinProbabilitySection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _OverUnderSection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _HomeAwayRecordSection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _WinRateSection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _TeamProductionSection(parsed: parsed),
            if (parsed.league != 'NPB' && parsed.league != 'CPBL') ...[
              const SizedBox(height: TsSpacing.lg),
              _SeasonTeamStatsSection(parsed: parsed),
            ],
          ],
        ),
      ),
    );
  }
}

class BaseballPremiumTabLoading extends StatelessWidget {
  const BaseballPremiumTabLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 6; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.lg),
          Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: semantic.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: TsSpacing.sm),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: semantic.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
        const SizedBox(height: TsSpacing.lg),
        Text(
          l10n.baseballAiLoading,
          style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.sm),
        Text(
          l10n.baseballAiLoadingHint,
          style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class BaseballPremiumTabError extends StatelessWidget {
  const BaseballPremiumTabError({
    required this.onRetry,
    super.key,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.baseballAiLoadFailed,
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.lg),
          TsButton(
            label: l10n.retry,
            variant: TsButtonVariant.primary,
            size: TsButtonSize.small,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _AiAnalysisSection extends StatelessWidget {
  const _AiAnalysisSection({required this.parsed});

  final BaseballPremiumParsed parsed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.baseballAiMatchAnalysis,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TsSpacing.sm,
            vertical: TsSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _gradeBackgroundColor(parsed.grade),
            borderRadius: BorderRadius.circular(TsSpacing.md),
          ),
          child: Text(
            parsed.grade,
            style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
          ),
        ),
      ],
    );
  }
}

Color _gradeBackgroundColor(String grade) {
  switch (grade.toUpperCase()) {
    case 'PICK':
      return TsColors.analysisPick500;
    case 'GOOD':
      return TsColors.analysisGood500;
    case 'PASS':
    default:
      return TsColors.analysisPass500;
  }
}

class _WinProbabilitySection extends StatelessWidget {
  const _WinProbabilitySection({required this.parsed});

  final BaseballPremiumParsed parsed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final summaryLines = parsed.summary
        .split('\n\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.baseballWinProbability,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InfoBox(
                      label: localizedTeamName(
                        context,
                        parsed.homeTeam,
                        parsed.homeTeamKo,
                      ),
                      value: parsed.homeWinProb,
                      valueColor: semantic.interactivePrimary,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: _InfoBox(
                      label: localizedTeamName(
                        context,
                        parsed.awayTeam,
                        parsed.awayTeamKo,
                      ),
                      value: parsed.awayWinProb,
                      valueColor: TsColors.error500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < summaryLines.length; i++) ...[
                    if (i > 0) const SizedBox(height: TsSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        summaryLines[i],
                        style: TsType.bodyMRegular.copyWith(
                          color: semantic.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverUnderSection extends StatelessWidget {
  const _OverUnderSection({required this.parsed});

  final BaseballPremiumParsed parsed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final baselineLabel = parsed.overUnderLine == '-' ||
            parsed.overUnderLine == '0' ||
            parsed.overUnderLine.isEmpty
        ? l10n.baseballBaselineDash
        : l10n.baseballBaselineValue(parsed.overUnderLine);
    final hasOuData = parsed.overProb >= 0 && parsed.underProb >= 0;
    final highlightUnder = hasOuData &&
        parsed.underProb > 0 &&
        parsed.overProb > 0 &&
        parsed.underProb > parsed.overProb;
    final overText = hasOuData ? '${parsed.overProb}%' : '-';
    final underText = hasOuData ? '${parsed.underProb}%' : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.baseballOverUnder,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33F59E0B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    baselineLabel,
                    style: TsType.bodyLRegular.copyWith(
                      color: TsColors.systemWarning500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TsSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _UOBox(
                      label: l10n.labelOver,
                      value: overText,
                      isHighlighted: hasOuData && !highlightUnder,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: _UOBox(
                      label: l10n.labelUnder,
                      value: underText,
                      isHighlighted: hasOuData && highlightUnder,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeAwayRecordSection extends StatelessWidget {
  const _HomeAwayRecordSection({required this.parsed});

  final BaseballPremiumParsed parsed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.baseballHomeAwayRecord,
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              l10n.baseballRecent10,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(TsSpacing.sm),
          ),
          child: Row(
            children: [
              Expanded(
                child: _HomeAwayAdvantageBox(
                  teamName: localizedTeamName(
                    context,
                    parsed.homeTeam,
                    parsed.homeTeamKo,
                  ),
                  recordRaw: parsed.homeAdvantageRecord,
                  isHome: true,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: _HomeAwayAdvantageBox(
                  teamName: localizedTeamName(
                    context,
                    parsed.awayTeam,
                    parsed.awayTeamKo,
                  ),
                  recordRaw: parsed.awayAdvantageRecord,
                  isHome: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WinRateSection extends StatelessWidget {
  const _WinRateSection({required this.parsed});

  final BaseballPremiumParsed parsed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.baseballHomeAwayWinRate,
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              l10n.baseballRecent10,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(TsSpacing.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _RecentWinRateBox(
                      teamName: localizedTeamName(
                        context,
                        parsed.homeTeam,
                        parsed.homeTeamKo,
                      ),
                      winRate: parsed.homeRecentWinRate,
                      isHome: true,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: _RecentWinRateBox(
                      teamName: localizedTeamName(
                        context,
                        parsed.awayTeam,
                        parsed.awayTeamKo,
                      ),
                      winRate: parsed.awayRecentWinRate,
                      isHome: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.baseballReliability,
                    style: TsType.bodyLRegular.copyWith(
                      color: semantic.textSecondary,
                    ),
                  ),
                  ConfidenceChip(level: parsed.confidence),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamProductionSection extends StatelessWidget {
  const _TeamProductionSection({required this.parsed});

  final BaseballPremiumParsed parsed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.baseballTeamProductivity,
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              l10n.baseballRecent10,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(TsSpacing.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < parsed.teamProduction.length; i++) ...[
                if (i > 0) const SizedBox(height: TsSpacing.sm),
                _ProductionGaugeCard(item: parsed.teamProduction[i]),
              ],
              const SizedBox(height: TsSpacing.lg),
              Column(
                children: [
                  Text(
                    parsed.teamProductionLine1,
                    style: TsType.bodyMRegular.copyWith(
                      color: semantic.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (parsed.teamProductionLine2.isNotEmpty) ...[
                    const SizedBox(height: TsSpacing.sm),
                    Text(
                      parsed.teamProductionLine2,
                      style: TsType.bodyMRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeasonTeamStatsSection extends StatelessWidget {
  const _SeasonTeamStatsSection({required this.parsed});

  final BaseballPremiumParsed parsed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final isKBO = parsed.league == 'KBO';
    final avgLabel = isKBO ? l10n.baseballTeamBattingAvg : 'AVG';
    final opsLabel = isKBO ? l10n.baseballTeamOps : 'OPS';
    final eraLabel = isKBO ? l10n.baseballTeamEra : 'ERA';
    final whipLabel = isKBO ? l10n.baseballTeamWhip : 'WHIP';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.baseballSeasonStats,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: parsed.hasTeamSeason
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TeamStatGaugeCard(
                            data: _toGaugeData(
                              parsed.seasonTeamStats[0],
                              label: avgLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TeamStatGaugeCard(
                            data: _toGaugeData(
                              parsed.seasonTeamStats[1],
                              label: opsLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TeamStatGaugeCard(
                            data: _toGaugeData(
                              parsed.seasonTeamStats[2],
                              label: eraLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TeamStatGaugeCard(
                            data: _toGaugeData(
                              parsed.seasonTeamStats[3],
                              label: whipLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  l10n.baseballSeasonStatsNoData,
                  style: TsType.bodyMRegular.copyWith(
                    color: semantic.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ],
    );
  }
}

class _HomeAwayAdvantageBox extends StatelessWidget {
  const _HomeAwayAdvantageBox({
    required this.teamName,
    required this.recordRaw,
    required this.isHome,
  });

  final String teamName;
  final String recordRaw;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final isNa = recordRaw.toUpperCase() == 'N/A';
    final percentage = isNa ? '-' : _extractPercentage(recordRaw);
    final winLoss = isNa ? '' : _extractWinLoss(recordRaw);
    final valueColor =
        isHome ? semantic.interactivePrimary : TsColors.error500;

    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(TsSpacing.sm),
      ),
      padding: const EdgeInsets.all(TsSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teamName,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            percentage,
            style: TsType.headingH1.copyWith(color: valueColor),
            textAlign: TextAlign.center,
          ),
          if (winLoss.isNotEmpty) ...[
            const SizedBox(height: TsSpacing.sm),
            Text(
              winLoss,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentWinRateBox extends StatelessWidget {
  const _RecentWinRateBox({
    required this.teamName,
    required this.winRate,
    required this.isHome,
  });

  final String teamName;
  final String winRate;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final valueColor =
        isHome ? semantic.interactivePrimary : TsColors.error500;

    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(TsSpacing.sm),
      ),
      padding: const EdgeInsets.all(TsSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teamName,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            winRate,
            style: TsType.headingH1.copyWith(color: valueColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _extractPercentage(String record) {
  final idx = record.indexOf(' (');
  return idx > 0 ? record.substring(0, idx) : record;
}

String _extractWinLoss(String record) {
  final match = RegExp(r'\((.+)\)').firstMatch(record);
  final raw = match?.group(1) ?? '';
  if (raw.isEmpty) return '';
  return raw.replaceAll('-', ' - ');
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            value,
            style: TsType.headingH1.copyWith(color: valueColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _UOBox extends StatelessWidget {
  const _UOBox({
    required this.label,
    required this.value,
    required this.isHighlighted,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  static const Color _highlightBg = Color(0x3300DF81);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: isHighlighted ? _highlightBg : semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: semantic.interactivePrimary)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            value,
            style: TsType.headingH1.copyWith(
              color: isHighlighted
                  ? semantic.interactivePrimary
                  : semantic.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

GaugeData _toGaugeData(PremiumGaugeItem item, {String? label}) {
  return GaugeData(
    label: label ?? item.label,
    homeValue: item.homeStatLabel,
    awayValue: item.awayStatLabel,
    homeRatio: item.homeRatio,
  );
}

class _ProductionGaugeCard extends StatelessWidget {
  const _ProductionGaugeCard({required this.item});

  final PremiumGaugeItem item;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final hr = item.homeRatio.clamp(0.0, 1.0);
    final homeFlex = (hr * 100).round().clamp(1, 99);
    final awayFlex = ((1.0 - hr) * 100).round().clamp(1, 99);
    final tertiaryStyle =
        TsType.labelSRegular.copyWith(color: semantic.textTertiary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.xs),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(TsSpacing.sm),
      ),
      child: Column(
        children: [
          Text(
            item.label,
            style: tertiaryStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(TsSpacing.sm),
            child: SizedBox(
              height: 8,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    flex: homeFlex,
                    child: Container(color: semantic.interactivePrimary),
                  ),
                  Expanded(
                    flex: awayFlex,
                    child: Container(color: TsColors.error500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TsSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.homeStatLabel, style: tertiaryStyle),
              Text(item.awayStatLabel, style: tertiaryStyle),
            ],
          ),
        ],
      ),
    );
  }
}
