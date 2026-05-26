import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/baseball_premium_parser.dart';
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

    final isLoading = detailAsync.isLoading || predictAsync.isLoading;

    if (detailAsync.hasError || predictAsync.hasError) {
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

    if (isLoading) {
      return const KeyedSubtree(
        key: ValueKey<Object>('baseball_report_premium_loading'),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: BaseballPremiumTabLoading(),
        ),
      );
    }

    final predictData = predictAsync.value;
    if (predictData != null && _loggedPredictMatchId != widget.matchId) {
      _loggedPredictMatchId = widget.matchId;
      logBaseballPremiumPredict(predictData);
    }

    final parsed = parseBaseballPremium(
      detail: detailAsync.value ?? {},
      predict: predictData ?? {},
    );

    return KeyedSubtree(
      key: const ValueKey<Object>('baseball_report_premium'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WinProbabilitySection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _OverUnderSection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _HomeAwayRecordSection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _WinRateSection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _TeamProductionSection(parsed: parsed),
            const SizedBox(height: TsSpacing.lg),
            _SeasonTeamStatsSection(parsed: parsed),
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
          '프리미엄 분석 로딩 중...',
          style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.sm),
        Text(
          '최초 분석 시 10–30초 정도 소요될 수 있습니다.',
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '프리미엄 분석을 불러오지 못했습니다.',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.lg),
          TsButton(
            label: '다시 시도',
            variant: TsButtonVariant.primary,
            size: TsButtonSize.small,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _WinProbabilitySection extends StatelessWidget {
  const _WinProbabilitySection({required this.parsed});

  final BaseballPremiumParsed parsed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '승리 확률',
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
                      label: '원정',
                      value: parsed.awayWinProb,
                      valueColor: TsColors.systemError500,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: _InfoBox(
                      label: '홈',
                      value: parsed.homeWinProb,
                      valueColor: semantic.interactivePrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              Text(
                parsed.summary,
                style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                textAlign: TextAlign.center,
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
    final highlightUnder = parsed.highlightUnder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오버&언더',
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
                    '기준선 ${parsed.overUnderLine}',
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
                      label: '오버',
                      value: parsed.overOdds,
                      isHighlighted: !highlightUnder,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: _UOBox(
                      label: '언더',
                      value: parsed.underOdds,
                      isHighlighted: highlightUnder,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '홈&원정 성적',
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              '최근 10경기',
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: '원정',
                  value: parsed.awayRecentForm,
                  valueColor: TsColors.systemError500,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: _InfoBox(
                  label: '홈',
                  value: parsed.homeRecentForm,
                  valueColor: semantic.interactivePrimary,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '최근 10경기 승률',
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              '최근 10경기',
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InfoBox(
                      label: '원정',
                      value: parsed.awayRecentForm,
                      teamName: parsed.awayTeam,
                      valueColor: TsColors.systemError500,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: _InfoBox(
                      label: '홈',
                      value: parsed.homeRecentForm,
                      teamName: parsed.homeTeam,
                      valueColor: semantic.interactivePrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '신뢰도',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '팀 생산성',
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              '최근 10경기',
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < parsed.teamProduction.length; i++) ...[
                if (i > 0) const SizedBox(height: TsSpacing.sm),
                _ProductionGaugeCard(item: parsed.teamProduction[i]),
              ],
              const SizedBox(height: TsSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: semantic.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  parsed.teamProductionDescription,
                  style: TsType.bodyMRegular.copyWith(
                    color: semantic.interactivePrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시즌 팀 통계',
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
                            data: _toGaugeData(parsed.seasonTeamStats[0]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TeamStatGaugeCard(
                            data: _toGaugeData(parsed.seasonTeamStats[1]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TeamStatGaugeCard(
                            data: _toGaugeData(parsed.seasonTeamStats[2]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TeamStatGaugeCard(
                            data: _toGaugeData(parsed.seasonTeamStats[3]),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  '시즌 통계 데이터를 불러올 수 없습니다.',
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

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.label,
    required this.value,
    required this.valueColor,
    this.teamName,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String? teamName;

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
          if (teamName != null) ...[
            const SizedBox(height: TsSpacing.sm),
            Text(
              teamName!,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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

GaugeData _toGaugeData(PremiumGaugeItem item) {
  return GaugeData(
    label: item.label,
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            item.label,
            style: tertiaryStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    flex: homeFlex,
                    child: Container(color: semantic.interactivePrimary),
                  ),
                  Expanded(
                    flex: awayFlex,
                    child: Container(color: TsColors.systemError500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TsSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.homeStatLabel, style: tertiaryStyle),
                Text(item.awayStatLabel, style: tertiaryStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
