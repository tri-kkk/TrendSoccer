import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/baseball_pitcher_stats_parsed.dart';
import 'package:trendsoccer/core/models/baseball_predict_v2_parsed.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_stat_compare_row.dart';
import 'package:trendsoccer/features_v2/matches/widgets/baseball_report_gauge_helpers.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class BaseballExtendedReportBlocks extends StatelessWidget {
  const BaseballExtendedReportBlocks({
    required this.header,
    super.key,
  });

  final MatchHeaderData header;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseballTeamProductionReportBlock(header: header),
        const SizedBox(height: TsSpacing.lg),
        BaseballSeasonTeamStatsReportBlock(header: header),
        const SizedBox(height: TsSpacing.lg),
        BaseballRecentFormReportBlock(header: header),
        const SizedBox(height: TsSpacing.lg),
        BaseballScoringAnalysisReportBlock(header: header),
      ],
    );
  }
}

class BaseballTeamProductionReportBlock extends ConsumerStatefulWidget {
  const BaseballTeamProductionReportBlock({
    required this.header,
    super.key,
  });

  final MatchHeaderData header;

  @override
  ConsumerState<BaseballTeamProductionReportBlock> createState() =>
      _BaseballTeamProductionReportBlockState();
}

class _BaseballTeamProductionReportBlockState
    extends ConsumerState<BaseballTeamProductionReportBlock> {
  bool _retryInProgress = false;

  Future<void> _guardedRetry(Future<void> Function() work) async {
    if (_retryInProgress) return;
    setState(() => _retryInProgress = true);
    try {
      await work();
    } finally {
      if (mounted) setState(() => _retryInProgress = false);
    }
  }

  MatchReportRetryButton _retryButton() {
    return MatchReportRetryButton(
      inProgress: _retryInProgress,
      onPressed: () => unawaited(
        _guardedRetry(
          () async => ref.invalidate(
            baseballPredictProvider(widget.header.matchId),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = _normalizeLeagueCode(widget.header.leagueCode ?? '');
    if (league != 'MLB' && league != 'KBO' && league != 'NPB') {
      return const SizedBox.shrink();
    }

    final predictAsync =
        ref.watch(baseballPredictProvider(widget.header.matchId));
    final retry = _retryButton();

    return _BaseballReportBlockCard(
      title: l10n.baseballTeamProductivity,
      icon: TsIcons.analytics,
      subtitle: l10n.baseballRecent10,
      child: predictAsync.when(
        loading: () => const _BaseballReportBlockSkeleton(),
        error: (error, _) => _BaseballReportBlockFailure(
          retry: retry,
          description: resolveApiError(context, error),
        ),
        data: (predict) {
          final detail =
              ref.read(baseballMatchDetailProvider(widget.header.matchId)).value;
          if (predict.isEmpty) {
            return _emptyHeldOrNoResult(
              l10n: l10n,
              league: league,
              detail: detail,
              title: l10n.baseballTeamProductivity,
            );
          }

          final parsed = parseBaseballPredictV2(predict, matchDetail: detail);
          if (!_hasTeamProductionData(parsed)) {
            return _BaseballReportBlockEmpty(
              title: l10n.baseballTeamProductivity,
              description: l10n.baseballTeamProductivityComment,
            );
          }

          return _TeamProductionContent(parsed: parsed, l10n: l10n);
        },
      ),
    );
  }
}

class _TeamProductionContent extends StatelessWidget {
  const _TeamProductionContent({
    required this.parsed,
    required this.l10n,
  });

  final BaseballPredictV2Parsed parsed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final home = parsed.teamProduction.home;
    final away = parsed.teamProduction.away;

    final rows = <_BaseballCompareRowData>[
      _BaseballCompareRowData(
        statLabel: l10n.baseballStatRunsScored,
        homeValue: home.scored,
        awayValue: away.scored,
        lowerIsBetter: false,
        format: formatBaseballProductionValue,
      ),
      _BaseballCompareRowData(
        statLabel: l10n.baseballStatRunsAllowed,
        homeValue: home.conceded,
        awayValue: away.conceded,
        lowerIsBetter: true,
        format: formatBaseballProductionValue,
      ),
      _BaseballCompareRowData(
        statLabel: l10n.baseballStatHits,
        homeValue: home.hits,
        awayValue: away.hits,
        lowerIsBetter: false,
        format: formatBaseballProductionValue,
      ),
    ];

    return _BaseballCompareRowList(rows: rows);
  }
}

class BaseballSeasonTeamStatsReportBlock extends ConsumerStatefulWidget {
  const BaseballSeasonTeamStatsReportBlock({
    required this.header,
    super.key,
  });

  final MatchHeaderData header;

  @override
  ConsumerState<BaseballSeasonTeamStatsReportBlock> createState() =>
      _BaseballSeasonTeamStatsReportBlockState();
}

class _BaseballSeasonTeamStatsReportBlockState
    extends ConsumerState<BaseballSeasonTeamStatsReportBlock> {
  bool _retryInProgress = false;

  Future<void> _guardedRetry(Future<void> Function() work) async {
    if (_retryInProgress) return;
    setState(() => _retryInProgress = true);
    try {
      await work();
    } finally {
      if (mounted) setState(() => _retryInProgress = false);
    }
  }

  MatchReportRetryButton _retryButton() {
    return MatchReportRetryButton(
      inProgress: _retryInProgress,
      onPressed: () => unawaited(
        _guardedRetry(
          () async => ref.invalidate(
            baseballPredictProvider(widget.header.matchId),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = _normalizeLeagueCode(widget.header.leagueCode ?? '');
    if (league != 'MLB' && league != 'KBO' && league != 'NPB') {
      return const SizedBox.shrink();
    }
    if (league == 'NPB') {
      return const SizedBox.shrink();
    }

    final predictAsync =
        ref.watch(baseballPredictProvider(widget.header.matchId));
    final retry = _retryButton();

    return _BaseballReportBlockCard(
      title: l10n.baseballSeasonStats,
      icon: TsIcons.leaderboard,
      child: predictAsync.when(
        loading: () => const _BaseballReportBlockSkeleton(),
        error: (error, _) => _BaseballReportBlockFailure(
          retry: retry,
          description: resolveApiError(context, error),
        ),
        data: (predict) {
          final detail =
              ref.read(baseballMatchDetailProvider(widget.header.matchId)).value;
          if (predict.isEmpty) {
            return _emptyHeldOrNoResult(
              l10n: l10n,
              league: league,
              detail: detail,
              title: l10n.baseballSeasonStats,
            );
          }

          final parsed = parseBaseballPredictV2(predict, matchDetail: detail);
          if (!_hasSeasonTeamStatsData(parsed)) {
            return _BaseballReportBlockEmpty(
              title: l10n.baseballSeasonStats,
              description: l10n.baseballSeasonStatsNoData,
            );
          }

          return _SeasonTeamStatsContent(parsed: parsed);
        },
      ),
    );
  }
}

class _SeasonTeamStatsContent extends StatelessWidget {
  const _SeasonTeamStatsContent({required this.parsed});

  final BaseballPredictV2Parsed parsed;

  @override
  Widget build(BuildContext context) {
    final home = parsed.seasonTeamStats.home;
    final away = parsed.seasonTeamStats.away;

    final rows = <_BaseballCompareRowData>[
      _BaseballCompareRowData(
        statLabel: 'AVG',
        homeValue: home?.avg,
        awayValue: away?.avg,
        lowerIsBetter: false,
        format: (value) => formatBaseballSeasonDecimal(value, decimals: 3),
      ),
      _BaseballCompareRowData(
        statLabel: 'OPS',
        homeValue: home?.ops,
        awayValue: away?.ops,
        lowerIsBetter: false,
        format: (value) => formatBaseballSeasonDecimal(value, decimals: 3),
      ),
      _BaseballCompareRowData(
        statLabel: 'ERA',
        homeValue: home?.era,
        awayValue: away?.era,
        lowerIsBetter: true,
        format: (value) => formatBaseballSeasonDecimal(value, decimals: 2),
      ),
      _BaseballCompareRowData(
        statLabel: 'WHIP',
        homeValue: home?.whip,
        awayValue: away?.whip,
        lowerIsBetter: true,
        format: (value) => formatBaseballSeasonDecimal(value, decimals: 2),
      ),
    ];

    return _BaseballCompareRowList(rows: rows);
  }
}

class BaseballRecentFormReportBlock extends ConsumerStatefulWidget {
  const BaseballRecentFormReportBlock({
    required this.header,
    super.key,
  });

  final MatchHeaderData header;

  @override
  ConsumerState<BaseballRecentFormReportBlock> createState() =>
      _BaseballRecentFormReportBlockState();
}

class _BaseballRecentFormReportBlockState
    extends ConsumerState<BaseballRecentFormReportBlock> {
  bool _retryInProgress = false;

  Future<void> _guardedRetry(Future<void> Function() work) async {
    if (_retryInProgress) return;
    setState(() => _retryInProgress = true);
    try {
      await work();
    } finally {
      if (mounted) setState(() => _retryInProgress = false);
    }
  }

  MatchReportRetryButton _retryButton() {
    return MatchReportRetryButton(
      inProgress: _retryInProgress,
      onPressed: () => unawaited(
        _guardedRetry(
          () async => ref.invalidate(
            baseballPredictProvider(widget.header.matchId),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = _normalizeLeagueCode(widget.header.leagueCode ?? '');
    if (league != 'MLB' && league != 'KBO' && league != 'NPB') {
      return const SizedBox.shrink();
    }

    final predictAsync =
        ref.watch(baseballPredictProvider(widget.header.matchId));
    final retry = _retryButton();

    return predictAsync.when(
      loading: () => _BaseballReportBlockCard(
        title: 'Recent form',
        icon: TsIcons.trendingUp,
        subtitle: _recentFormSubtitle(l10n, null),
        child: const _BaseballReportBlockSkeleton(),
      ),
      error: (error, _) => _BaseballReportBlockCard(
        title: 'Recent form',
        icon: TsIcons.trendingUp,
        subtitle: _recentFormSubtitle(l10n, null),
        child: _BaseballReportBlockFailure(
          retry: retry,
          description: resolveApiError(context, error),
        ),
      ),
      data: (predict) {
        final detail =
            ref.read(baseballMatchDetailProvider(widget.header.matchId)).value;

        if (predict.isEmpty) {
          return _BaseballReportBlockCard(
            title: 'Recent form',
            icon: TsIcons.trendingUp,
            subtitle: _recentFormSubtitle(l10n, null),
            child: _emptyHeldOrNoResult(
              l10n: l10n,
              league: league,
              detail: detail,
              title: 'Recent form',
            ),
          );
        }

        final parsed = parseBaseballPredictV2(predict, matchDetail: detail);

        return _BaseballReportBlockCard(
          title: 'Recent form',
          icon: TsIcons.trendingUp,
          subtitle: _recentFormSubtitle(l10n, parsed.confidence),
          child: !_hasRecentFormData(parsed)
              ? _BaseballReportBlockEmpty(
                  title: 'Recent form',
                  description: l10n.analysisNoResult,
                )
              : _RecentFormContent(parsed: parsed, l10n: l10n),
        );
      },
    );
  }
}

class _RecentFormContent extends StatelessWidget {
  const _RecentFormContent({
    required this.parsed,
    required this.l10n,
  });

  final BaseballPredictV2Parsed parsed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final homeWinRate = parseBaseballPercentValue(parsed.homeRecentWinRate);
    final awayWinRate = parseBaseballPercentValue(parsed.awayRecentWinRate);
    final homeRecordRate =
        parseBaseballPercentValue(parsed.homeAdvantageRecord);
    final awayRecordRate =
        parseBaseballPercentValue(parsed.awayAdvantageRecord);

    final rows = <_BaseballCompareRowData>[
      _BaseballCompareRowData(
        statLabel: 'Win rate',
        homeValue: homeWinRate,
        awayValue: awayWinRate,
        lowerIsBetter: false,
        homeDisplay: _formatRecentFormLabel(parsed.homeRecentWinRate),
        awayDisplay: _formatRecentFormLabel(parsed.awayRecentWinRate),
        format: formatBaseballProductionValue,
      ),
      _BaseballCompareRowData(
        statLabel: l10n.baseballHomeAwayRecord,
        homeValue: homeRecordRate,
        awayValue: awayRecordRate,
        lowerIsBetter: false,
        homeDisplay: _formatRecordLabel(parsed.homeAdvantageRecord),
        awayDisplay: _formatRecordLabel(parsed.awayAdvantageRecord),
        format: formatBaseballProductionValue,
      ),
    ];

    return _BaseballCompareRowList(rows: rows);
  }
}

class BaseballScoringAnalysisReportBlock extends ConsumerStatefulWidget {
  const BaseballScoringAnalysisReportBlock({
    required this.header,
    super.key,
  });

  final MatchHeaderData header;

  @override
  ConsumerState<BaseballScoringAnalysisReportBlock> createState() =>
      _BaseballScoringAnalysisReportBlockState();
}

class _BaseballScoringAnalysisReportBlockState
    extends ConsumerState<BaseballScoringAnalysisReportBlock> {
  bool _retryInProgress = false;

  Future<void> _guardedRetry(Future<void> Function() work) async {
    if (_retryInProgress) return;
    setState(() => _retryInProgress = true);
    try {
      await work();
    } finally {
      if (mounted) setState(() => _retryInProgress = false);
    }
  }

  MatchReportRetryButton _retryButton() {
    return MatchReportRetryButton(
      inProgress: _retryInProgress,
      onPressed: () => unawaited(
        _guardedRetry(
          () async => ref.invalidate(
            baseballPredictProvider(widget.header.matchId),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = _normalizeLeagueCode(widget.header.leagueCode ?? '');
    if (league != 'MLB' && league != 'KBO' && league != 'NPB') {
      return const SizedBox.shrink();
    }

    final detail =
        ref.read(baseballMatchDetailProvider(widget.header.matchId)).value;
    final lineFromDetail = _overUnderLineFromDetail(detail);
    if (detail != null &&
        detail.isNotEmpty &&
        !_hasUsableOverUnderLine(lineFromDetail)) {
      return const SizedBox.shrink();
    }

    final predictAsync =
        ref.watch(baseballPredictProvider(widget.header.matchId));
    final retry = _retryButton();

    return predictAsync.when(
      loading: () {
        if (!_hasUsableOverUnderLine(lineFromDetail)) {
          return const SizedBox.shrink();
        }
        return _BaseballReportBlockCard(
          title: l10n.baseballOverUnder,
          icon: TsIcons.newspaper,
          subtitle: _scoringAnalysisSubtitle(lineFromDetail!),
          child: const _BaseballReportBlockSkeleton(),
        );
      },
      error: (error, _) {
        if (!_hasUsableOverUnderLine(lineFromDetail)) {
          return const SizedBox.shrink();
        }
        return _BaseballReportBlockCard(
          title: l10n.baseballOverUnder,
          icon: TsIcons.newspaper,
          subtitle: _scoringAnalysisSubtitle(lineFromDetail!),
          child: _BaseballReportBlockFailure(
            retry: retry,
            description: resolveApiError(context, error),
          ),
        );
      },
      data: (predict) {
        final parsed = parseBaseballPredictV2(predict, matchDetail: detail);
        if (!_hasUsableOverUnderLine(parsed.overUnderLine)) {
          return const SizedBox.shrink();
        }

        if (predict.isEmpty) {
          return _BaseballReportBlockCard(
            title: l10n.baseballOverUnder,
            icon: TsIcons.newspaper,
            subtitle: _scoringAnalysisSubtitle(parsed.overUnderLine!),
            child: _emptyHeldOrNoResult(
              l10n: l10n,
              league: league,
              detail: detail,
              title: l10n.baseballOverUnder,
            ),
          );
        }

        return _BaseballReportBlockCard(
          title: l10n.baseballOverUnder,
          icon: TsIcons.newspaper,
          subtitle: _scoringAnalysisSubtitle(parsed.overUnderLine!),
          child: !_hasScoringAnalysisData(parsed)
              ? _BaseballReportBlockEmpty(
                  title: l10n.baseballOverUnder,
                  description: l10n.analysisNoResult,
                )
              : _ScoringAnalysisContent(parsed: parsed, l10n: l10n),
        );
      },
    );
  }
}

class _ScoringAnalysisContent extends StatelessWidget {
  const _ScoringAnalysisContent({
    required this.parsed,
    required this.l10n,
  });

  final BaseballPredictV2Parsed parsed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final over = parsed.overProb!;
    final under = parsed.underProb!;
    final overFraction = baseballRatioForValues(over, under, lowerIsBetter: false);
    final underFraction = 1 - overFraction;
    final overLabel = formatBaseballProbabilityLabel(over);
    final underLabel = formatBaseballProbabilityLabel(under);

    var overEmphasized = false;
    var underEmphasized = false;
    if (over > under) {
      overEmphasized = true;
    } else if (under > over) {
      underEmphasized = true;
    }

    return TsStatCompareRow(
      statLabel: '${l10n.labelOver} / ${l10n.labelUnder}',
      homeLabel: overLabel,
      awayLabel: underLabel,
      homeFraction: overFraction,
      awayFraction: underFraction,
      homeEmphasized: overEmphasized,
      awayEmphasized: underEmphasized,
    );
  }
}

class _BaseballCompareRowData {
  const _BaseballCompareRowData({
    required this.statLabel,
    required this.homeValue,
    required this.awayValue,
    required this.lowerIsBetter,
    required this.format,
    this.homeDisplay,
    this.awayDisplay,
  });

  final String statLabel;
  final double? homeValue;
  final double? awayValue;
  final bool lowerIsBetter;
  final String Function(double?) format;
  final String? homeDisplay;
  final String? awayDisplay;
}

class _BaseballCompareRowList extends StatelessWidget {
  const _BaseballCompareRowList({required this.rows});

  final List<_BaseballCompareRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.md),
          _BaseballCompareRow(row: rows[i]),
        ],
      ],
    );
  }
}

class _BaseballCompareRow extends StatelessWidget {
  const _BaseballCompareRow({required this.row});

  final _BaseballCompareRowData row;

  @override
  Widget build(BuildContext context) {
    final homeLabel = row.homeDisplay ?? row.format(row.homeValue);
    final awayLabel = row.awayDisplay ?? row.format(row.awayValue);
    final homeFraction = baseballRatioForNullableValues(
      row.homeValue,
      row.awayValue,
      lowerIsBetter: row.lowerIsBetter,
    );
    final awayFraction = 1 - homeFraction;

    var homeEmphasized = false;
    var awayEmphasized = false;
    if (row.homeValue != null &&
        row.awayValue != null &&
        homeLabel != '-' &&
        awayLabel != '-') {
      final homeBetter = row.lowerIsBetter
          ? row.homeValue! < row.awayValue!
          : row.homeValue! > row.awayValue!;
      final awayBetter = row.lowerIsBetter
          ? row.awayValue! < row.homeValue!
          : row.awayValue! > row.homeValue!;
      homeEmphasized = homeBetter;
      awayEmphasized = awayBetter;
    }

    return TsStatCompareRow(
      statLabel: row.statLabel,
      homeLabel: homeLabel,
      awayLabel: awayLabel,
      homeFraction: homeFraction,
      awayFraction: awayFraction,
      homeEmphasized: homeEmphasized,
      awayEmphasized: awayEmphasized,
    );
  }
}

bool _hasTeamProductionData(BaseballPredictV2Parsed parsed) {
  for (final side in [parsed.teamProduction.home, parsed.teamProduction.away]) {
    for (final value in [side.scored, side.conceded, side.hits]) {
      if ((value ?? 0) > 0) return true;
    }
  }
  return false;
}

bool _hasSeasonTeamStatsData(BaseballPredictV2Parsed parsed) {
  for (final side in [parsed.seasonTeamStats.home, parsed.seasonTeamStats.away]) {
    if (side == null) continue;
    for (final value in [side.avg, side.ops, side.era, side.whip]) {
      if (value != null) return true;
    }
  }
  return false;
}

bool _hasRecentFormData(BaseballPredictV2Parsed parsed) {
  return _hasDisplayValue(parsed.homeRecentWinRate) ||
      _hasDisplayValue(parsed.awayRecentWinRate) ||
      _hasDisplayValue(parsed.homeAdvantageRecord) ||
      _hasDisplayValue(parsed.awayAdvantageRecord);
}

bool _hasScoringAnalysisData(BaseballPredictV2Parsed parsed) {
  final over = parsed.overProb;
  final under = parsed.underProb;
  return over != null && under != null && over > 0 && under > 0;
}

bool _hasDisplayValue(String? value) {
  if (value == null) return false;
  final trimmed = value.trim();
  return trimmed.isNotEmpty && trimmed.toUpperCase() != 'N/A';
}

String _recentFormSubtitle(AppLocalizations l10n, String? confidence) {
  final base = l10n.baseballRecent10;
  if (confidence == null || confidence.trim().isEmpty) {
    return base;
  }
  return '$base · ${l10n.baseballReliability} ${confidence.trim().toUpperCase()}';
}

String? _overUnderLineFromDetail(Map<String, dynamic>? detail) {
  if (detail == null || detail.isEmpty) return null;
  return parseBaseballPredictV2({}, matchDetail: detail).overUnderLine;
}

bool _hasUsableOverUnderLine(String? line) {
  if (line == null || line.trim().isEmpty || line.trim() == '0') {
    return false;
  }
  return true;
}

String _scoringAnalysisSubtitle(String line) {
  return 'Total line ${line.trim()}';
}

String _formatRecentFormLabel(String? raw) {
  if (!_hasDisplayValue(raw)) return '-';
  final trimmed = raw!.trim();
  if (trimmed.contains('%')) return trimmed;
  final parsed = double.tryParse(trimmed);
  if (parsed == null) return trimmed;
  if (parsed == parsed.roundToDouble()) {
    return '${parsed.round()}%';
  }
  return '${parsed.toStringAsFixed(1)}%';
}

String _formatRecordLabel(String? raw) {
  if (!_hasDisplayValue(raw)) return '-';
  return raw!.trim();
}

Widget _emptyHeldOrNoResult({
  required AppLocalizations l10n,
  required String league,
  required Map<String, dynamic>? detail,
  required String title,
}) {
  return _BaseballReportBlockEmpty(
    title: title,
    description: baseballMatchHasUndecidedStarter(
      matchDetail: detail,
      leagueCode: league,
    )
        ? l10n.baseballAnalysisHeldUntilStarters
        : l10n.analysisNoResult,
  );
}

String _normalizeLeagueCode(String? league) {
  final upper = (league ?? '').trim().toUpperCase();
  if (upper.contains('MLB') || upper.contains('MAJOR')) return 'MLB';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('KBO') || upper.contains('KOREA')) return 'KBO';
  return upper;
}

class _BaseballReportBlockCard extends StatelessWidget {
  const _BaseballReportBlockCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  final String title;
  final TsIconSpec icon;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsSectionHeader(
            title: title,
            icon: icon,
            subtitle: subtitle,
          ),
          const SizedBox(height: TsSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _BaseballReportBlockSkeleton extends StatelessWidget {
  const _BaseballReportBlockSkeleton();

  @override
  Widget build(BuildContext context) {
    return const TsSkeletonBlock(TsSkeletonType.block);
  }
}

class _BaseballReportBlockFailure extends StatelessWidget {
  const _BaseballReportBlockFailure({
    required this.retry,
    required this.description,
  });

  final MatchReportRetryButton retry;
  final String description;

  @override
  Widget build(BuildContext context) {
    return TsEmptyState(
      type: TsEmptyType.failure,
      title: 'Could not load',
      description: description,
      actionLabel: retry.label,
      onAction: retry.action,
    );
  }
}

class _BaseballReportBlockEmpty extends StatelessWidget {
  const _BaseballReportBlockEmpty({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return TsEmptyState(
      title: title,
      description: description,
    );
  }
}
