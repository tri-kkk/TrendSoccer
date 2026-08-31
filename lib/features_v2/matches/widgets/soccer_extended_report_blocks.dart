import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/soccer_h2h_analysis_parsed.dart';
import 'package:trendsoccer/core/models/soccer_team_stats_parsed.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_h2h_summary.dart';
import 'package:trendsoccer/design_system/widgets/ts_insight_text.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_stack_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_stat_compare_row.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class SoccerExtendedReportBlocks extends ConsumerWidget {
  const SoccerExtendedReportBlocks({
    required this.header,
    required this.params,
    super.key,
  });

  final MatchHeaderData header;
  final SoccerAnalysisParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeTeamStatsParsedProvider(params));
    final awayAsync = ref.watch(awayTeamStatsParsedProvider(params));
    final h2hAsync = ref.watch(soccerH2HAnalysisParsedProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScoringTrendsBlock(
          homeAsync: homeAsync,
          awayAsync: awayAsync,
          onRetry: () => _retryTeamStats(ref),
        ),
        const SizedBox(height: TsSpacing.lg),
        _StrengthsWeaknessesBlock(
          header: header,
          homeAsync: homeAsync,
          awayAsync: awayAsync,
          onRetry: () => _retryTeamStats(ref),
        ),
        const SizedBox(height: TsSpacing.lg),
        _HeadToHeadBlock(
          header: header,
          h2hAsync: h2hAsync,
          onRetry: () => ref.invalidate(soccerH2HAnalysisProvider(params)),
        ),
        const SizedBox(height: TsSpacing.lg),
        _RecentFormBlock(
          homeAsync: homeAsync,
          awayAsync: awayAsync,
          onRetry: () => _retryTeamStats(ref),
        ),
      ],
    );
  }

  void _retryTeamStats(WidgetRef ref) {
    ref.invalidate(homeTeamStatsProvider(params));
    ref.invalidate(awayTeamStatsProvider(params));
  }
}

class _ScoringTrendsBlock extends StatelessWidget {
  const _ScoringTrendsBlock({
    required this.homeAsync,
    required this.awayAsync,
    required this.onRetry,
  });

  final AsyncValue<SoccerTeamStatsParsed> homeAsync;
  final AsyncValue<SoccerTeamStatsParsed> awayAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ExtendedReportBlockCard(
      title: l10n.soccerMarketIndicators,
      child: _combineTeamStats(
        homeAsync: homeAsync,
        awayAsync: awayAsync,
        onRetry: onRetry,
        hasData: (home, away) => home.hasMarketData || away.hasMarketData,
        builder: (home, away) {
          final rows = [
            (
              l10n.soccerStatOver25,
              home.markets.over25Rate,
              away.markets.over25Rate,
            ),
            (
              l10n.soccerMarketBtts,
              home.markets.bttsRate,
              away.markets.bttsRate,
            ),
            (
              l10n.soccerMarketCs,
              home.markets.cleanSheetRate,
              away.markets.cleanSheetRate,
            ),
            (
              l10n.soccerMarketFts,
              home.markets.scorelessRate,
              away.markets.scorelessRate,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: TsSpacing.md),
                _RateCompareRow(
                  statLabel: rows[i].$1,
                  homeValue: rows[i].$2,
                  awayValue: rows[i].$3,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StrengthsWeaknessesBlock extends StatelessWidget {
  const _StrengthsWeaknessesBlock({
    required this.header,
    required this.homeAsync,
    required this.awayAsync,
    required this.onRetry,
  });

  final MatchHeaderData header;
  final AsyncValue<SoccerTeamStatsParsed> homeAsync;
  final AsyncValue<SoccerTeamStatsParsed> awayAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final homeLabel = localizedTeamName(
      context,
      header.homeTeam,
      header.homeTeamKo,
    );
    final awayLabel = localizedTeamName(
      context,
      header.awayTeam,
      header.awayTeamKo,
    );

    return _ExtendedReportBlockCard(
      title: l10n.soccerStatTeamInsights,
      child: _combineTeamStats(
        homeAsync: homeAsync,
        awayAsync: awayAsync,
        onRetry: onRetry,
        hasData: (home, away) => home.hasInsightData || away.hasInsightData,
        emptyBuilder: () => TsEmptyState(
          title: l10n.soccerStatTeamInsights,
          description:
              'No strengths or weaknesses reported for either team in this match.',
        ),
        builder: (home, away) {
          final entries = mergeTeamInsights(home: home, away: away);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0) const SizedBox(height: TsSpacing.md),
                TsInsightText(
                  text:
                      '${entries[i].isHomeTeam ? homeLabel : awayLabel}: ${entries[i].text}',
                  tone: entries[i].isStrength
                      ? TsInsightTone.strength
                      : TsInsightTone.weakness,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HeadToHeadBlock extends StatelessWidget {
  const _HeadToHeadBlock({
    required this.header,
    required this.h2hAsync,
    required this.onRetry,
  });

  final MatchHeaderData header;
  final AsyncValue<SoccerH2HAnalysisParsed> h2hAsync;
  final VoidCallback onRetry;

  static const _recentMeetingCount = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ExtendedReportBlockCard(
      title: l10n.soccerH2h,
      child: h2hAsync.when(
        loading: () => const _ExtendedReportBlockSkeleton(),
        error: (_, _) => _ExtendedReportBlockFailure(onRetry: onRetry),
        data: (parsed) {
          if (!parsed.hasData) {
            return _ExtendedReportBlockFailure(onRetry: onRetry);
          }

          final overall = parsed.overall;
          final meetings = parsed.recentMatches
              .take(_recentMeetingCount)
              .map(
                (match) => TsH2HMeeting(
                  dateLabel: _formatH2HDate(match.date),
                  homeTeamLabel: match.homeTeam,
                  awayTeamLabel: match.awayTeam,
                  scoreLabel: match.scoreLabel,
                ),
              )
              .toList();

          return TsH2HSummary(
            line: TsStackLine.threeWay,
            homeValueLabel: '${overall.homeWins ?? 0}',
            drawValueLabel: '${overall.draws ?? 0}',
            awayValueLabel: '${overall.awayWins ?? 0}',
            homeFraction: overall.homeFraction,
            drawFraction: overall.drawFraction,
            awayFraction: overall.awayFraction,
            homeLabel: l10n.labelHomeShort,
            drawLabel: l10n.soccerDraw,
            awayLabel: l10n.labelAwayShort,
            detailTitleLabel: l10n.soccerH2hRecent,
            homeEmblemUrl: header.homeTeamLogo,
            awayEmblemUrl: header.awayTeamLogo,
            meetings: meetings,
          );
        },
      ),
    );
  }
}

class _RecentFormBlock extends StatelessWidget {
  const _RecentFormBlock({
    required this.homeAsync,
    required this.awayAsync,
    required this.onRetry,
  });

  final AsyncValue<SoccerTeamStatsParsed> homeAsync;
  final AsyncValue<SoccerTeamStatsParsed> awayAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ExtendedReportBlockCard(
      title: l10n.soccerRecentForm,
      child: _combineTeamStats(
        homeAsync: homeAsync,
        awayAsync: awayAsync,
        onRetry: onRetry,
        hasData: (home, away) => home.hasFormData || away.hasFormData,
        builder: (home, away) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RateCompareRow(
                statLabel: l10n.soccerRecent10,
                homeValue: home.last10.winRateFraction,
                awayValue: away.last10.winRateFraction,
                homeDisplay: _formatRecord(
                  home.last10.wins,
                  home.last10.draws,
                  home.last10.losses,
                ),
                awayDisplay: _formatRecord(
                  away.last10.wins,
                  away.last10.draws,
                  away.last10.losses,
                ),
              ),
              const SizedBox(height: TsSpacing.md),
              _RateCompareRow(
                statLabel: l10n.soccerStatWinRate,
                homeValue: home.homeStats.winRateFraction,
                awayValue: away.awayStats.winRateFraction,
                homeDisplay: _formatVenueRecord(home.homeStats),
                awayDisplay: _formatVenueRecord(away.awayStats),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RateCompareRow extends StatelessWidget {
  const _RateCompareRow({
    required this.statLabel,
    required this.homeValue,
    required this.awayValue,
    this.homeDisplay,
    this.awayDisplay,
  });

  final String statLabel;
  final double? homeValue;
  final double? awayValue;
  final String? homeDisplay;
  final String? awayDisplay;

  @override
  Widget build(BuildContext context) {
    final homeLabel = homeDisplay ?? _formatRatePercent(homeValue);
    final awayLabel = awayDisplay ?? _formatRatePercent(awayValue);
    final homeFraction = _compareFraction(homeValue, awayValue, true);
    final awayFraction = _compareFraction(homeValue, awayValue, false);

    var homeEmphasized = false;
    var awayEmphasized = false;
    if (homeValue != null &&
        awayValue != null &&
        homeLabel != '-' &&
        awayLabel != '-') {
      if (homeValue! > awayValue!) {
        homeEmphasized = true;
      } else if (awayValue! > homeValue!) {
        awayEmphasized = true;
      }
    }

    return TsStatCompareRow(
      statLabel: statLabel,
      homeLabel: homeLabel,
      awayLabel: awayLabel,
      homeFraction: homeFraction,
      awayFraction: awayFraction,
      homeEmphasized: homeEmphasized,
      awayEmphasized: awayEmphasized,
    );
  }
}

Widget _combineTeamStats({
  required AsyncValue<SoccerTeamStatsParsed> homeAsync,
  required AsyncValue<SoccerTeamStatsParsed> awayAsync,
  required VoidCallback onRetry,
  required bool Function(SoccerTeamStatsParsed home, SoccerTeamStatsParsed away)
      hasData,
  required Widget Function(
    SoccerTeamStatsParsed home,
    SoccerTeamStatsParsed away,
  ) builder,
  Widget Function()? emptyBuilder,
}) {
  if (homeAsync.isLoading || awayAsync.isLoading) {
    return const _ExtendedReportBlockSkeleton();
  }

  if (homeAsync.hasError && awayAsync.hasError) {
    return _ExtendedReportBlockFailure(onRetry: onRetry);
  }

  final home = homeAsync.value ?? SoccerTeamStatsParsed.empty;
  final away = awayAsync.value ?? SoccerTeamStatsParsed.empty;

  if (!hasData(home, away)) {
    if (emptyBuilder != null) {
      return emptyBuilder();
    }
    return _ExtendedReportBlockFailure(onRetry: onRetry);
  }

  return builder(home, away);
}

class _ExtendedReportBlockCard extends StatelessWidget {
  const _ExtendedReportBlockCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsSectionHeader(title: title),
          const SizedBox(height: TsSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ExtendedReportBlockSkeleton extends StatelessWidget {
  const _ExtendedReportBlockSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TsSkeletonBlock(TsSkeletonType.block),
      ],
    );
  }
}

class _ExtendedReportBlockFailure extends StatelessWidget {
  const _ExtendedReportBlockFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return TsEmptyState(
      type: TsEmptyType.failure,
      title: 'Could not load',
      description: 'This section is unavailable right now.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

String _formatRatePercent(double? value) {
  if (value == null) return '-';
  final percent = value <= 1 ? value * 100 : value;
  return '${percent.round()}%';
}

double _compareFraction(double? home, double? away, bool forHome) {
  if (home == null || away == null) return 0.5;
  final total = home + away;
  if (total <= 0) return 0.5;
  return ((forHome ? home : away) / total).clamp(0.0, 1.0);
}

String _formatRecord(int? wins, int? draws, int? losses) {
  if (wins == null && draws == null && losses == null) return '-';
  return '${wins ?? 0}-${draws ?? 0}-${losses ?? 0}';
}

String _formatVenueRecord(SoccerTeamVenueStatsParsed stats) {
  final rate = stats.winRate;
  if (rate != null) {
    return rate > 0 ? '$rate%' : '-';
  }
  return _formatRecord(stats.wins, stats.draws, stats.losses);
}

String _formatH2HDate(String raw) {
  if (raw.isEmpty) return '-';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return DateFormat('yyyy.MM.dd').format(parsed.toLocal());
}
