import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/baseball_h2h_parsed.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/core/utils/h2h_meeting_normalizer.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_h2h_summary.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_stack_bar.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class BaseballHeadToHeadReportBlock extends ConsumerStatefulWidget {
  const BaseballHeadToHeadReportBlock({
    required this.header,
    super.key,
  });

  final MatchHeaderData header;

  @override
  ConsumerState<BaseballHeadToHeadReportBlock> createState() =>
      _BaseballHeadToHeadReportBlockState();
}

class _BaseballHeadToHeadReportBlockState
    extends ConsumerState<BaseballHeadToHeadReportBlock> {
  static const _derivedSubtitleMeetingCount = 5;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = _normalizeLeagueCode(widget.header.leagueCode ?? '');
    if (league != 'MLB' && league != 'KBO' && league != 'NPB') {
      return const SizedBox.shrink();
    }

    final detailAsync =
        ref.watch(baseballMatchDetailProvider(widget.header.matchId));
    final homeTeamId = widget.header.homeTeamId ??
        _teamIdFromDetail(detailAsync.value, isHome: true);
    final awayTeamId = widget.header.awayTeamId ??
        _teamIdFromDetail(detailAsync.value, isHome: false);

    if (homeTeamId == null || awayTeamId == null) {
      if (detailAsync.isLoading) {
        return _BaseballH2HReportBlockCard(
          title: l10n.soccerH2h,
          icon: TsIcons.groups,
          child: const _BaseballH2HReportBlockSkeleton(),
        );
      }
      return _BaseballH2HReportBlockCard(
        title: l10n.soccerH2h,
        icon: TsIcons.groups,
        child: _BaseballH2HReportBlockEmpty(
          title: l10n.soccerH2h,
          description: l10n.analysisNoResult,
        ),
      );
    }

    final h2hParams = (homeTeamId: homeTeamId, awayTeamId: awayTeamId);
    final h2hAsync = ref.watch(baseballH2HProvider(h2hParams));
    final retry = MatchReportRetryButton(
      inProgress: _retryInProgress,
      onPressed: () => unawaited(
        _guardedRetry(
          () async => ref.invalidate(baseballH2HProvider(h2hParams)),
        ),
      ),
    );

    return h2hAsync.when(
      loading: () => _BaseballH2HReportBlockCard(
        title: l10n.soccerH2h,
        icon: TsIcons.groups,
        child: const _BaseballH2HReportBlockSkeleton(),
      ),
      error: (error, _) => _BaseballH2HReportBlockCard(
        title: l10n.soccerH2h,
        icon: TsIcons.groups,
        child: _BaseballH2HReportBlockFailure(
          retry: retry,
          description: resolveApiError(context, error),
        ),
      ),
      data: (raw) {
        final parsed = parseBaseballH2H(raw);
        if (parsed.recentMatches.isEmpty && !parsed.overall.hasData) {
          return _BaseballH2HReportBlockCard(
            title: l10n.soccerH2h,
            icon: TsIcons.groups,
            child: _BaseballH2HReportBlockEmpty(
              title: l10n.soccerH2h,
              description: l10n.analysisNoResult,
            ),
          );
        }

        final counts = _resolveH2HCounts(parsed);
        final sum = counts.homeWins + counts.draws + counts.awayWins;
        if (sum <= 0) {
          return _BaseballH2HReportBlockCard(
            title: l10n.soccerH2h,
            icon: TsIcons.groups,
            child: _BaseballH2HReportBlockEmpty(
              title: l10n.soccerH2h,
              description: l10n.analysisNoResult,
            ),
          );
        }

        final subtitle = counts.derivedFromMeetings &&
                parsed.recentMatches.length ==
                    _derivedSubtitleMeetingCount
            ? l10n.baseballH2hLastFive
            : null;

        final fixtureNames = h2hFixtureNameSets(widget.header);
        final meetings = parsed.recentMatches
            .map(
              (match) {
                final normalized = normalizeH2HMeetingToFixture(
                  fixtureHomeNames: fixtureNames.home,
                  fixtureAwayNames: fixtureNames.away,
                  meetingHomeEn: match.homeTeam ?? '',
                  meetingHomeKo: match.homeTeamKo,
                  meetingAwayEn: match.awayTeam ?? '',
                  meetingAwayKo: match.awayTeamKo,
                  homeScore: match.homeScore,
                  awayScore: match.awayScore,
                  rawScoreLabel: match.score,
                );
                return TsH2HMeeting(
                  dateLabel: _formatH2HDate(match.date ?? ''),
                  homeTeamLabel: localizedTeamName(
                    context,
                    normalized.homeTeamEn,
                    normalized.homeTeamKo,
                  ),
                  awayTeamLabel: localizedTeamName(
                    context,
                    normalized.awayTeamEn,
                    normalized.awayTeamKo,
                  ),
                  scoreLabel: normalized.scoreLabel,
                );
              },
            )
            .toList();

        final showDraw = counts.draws > 0;

        return _BaseballH2HReportBlockCard(
          title: l10n.soccerH2h,
          icon: TsIcons.groups,
          subtitle: subtitle,
          child: TsH2HSummary(
            line: showDraw ? TsStackLine.threeWay : TsStackLine.twoWay,
            homeValueLabel: '${counts.homeWins}',
            drawValueLabel: showDraw ? '${counts.draws}' : null,
            awayValueLabel: '${counts.awayWins}',
            homeFraction: counts.homeWins / sum,
            drawFraction: showDraw ? counts.draws / sum : 0,
            awayFraction: counts.awayWins / sum,
            homeLabel: l10n.labelWin,
            drawLabel: showDraw ? l10n.labelDraw : null,
            awayLabel: l10n.labelWin,
            detailTitleLabel: l10n.soccerH2hRecent,
            homeEmblemUrl: widget.header.homeTeamLogo,
            awayEmblemUrl: widget.header.awayTeamLogo,
            meetings: meetings,
          ),
        );
      },
    );
  }
}

class _H2HCounts {
  const _H2HCounts({
    required this.derivedFromMeetings,
    required this.homeWins,
    required this.draws,
    required this.awayWins,
  });

  final bool derivedFromMeetings;
  final int homeWins;
  final int draws;
  final int awayWins;
}

_H2HCounts _resolveH2HCounts(BaseballH2HAnalysisParsed parsed) {
  final overall = parsed.overall;
  if (overall.hasData) {
    return _H2HCounts(
      derivedFromMeetings: false,
      homeWins: overall.homeWins ?? 0,
      draws: overall.draws ?? 0,
      awayWins: overall.awayWins ?? 0,
    );
  }

  var homeWins = 0;
  var draws = 0;
  var awayWins = 0;
  for (final match in parsed.recentMatches) {
    final winner = match.winner ?? _winnerFromScores(match);
    switch (winner) {
      case BaseballH2HWinner.home:
        homeWins++;
      case BaseballH2HWinner.draw:
        draws++;
      case BaseballH2HWinner.away:
        awayWins++;
      case null:
        break;
    }
  }

  return _H2HCounts(
    derivedFromMeetings: true,
    homeWins: homeWins,
    draws: draws,
    awayWins: awayWins,
  );
}

BaseballH2HWinner? _winnerFromScores(BaseballH2HMatchParsed match) {
  final homeScore = match.homeScore;
  final awayScore = match.awayScore;
  if (homeScore == null || awayScore == null) return null;
  if (homeScore > awayScore) return BaseballH2HWinner.home;
  if (awayScore > homeScore) return BaseballH2HWinner.away;
  if (homeScore == awayScore) return BaseballH2HWinner.draw;
  return null;
}

String _formatH2HDate(String raw) {
  if (raw.isEmpty) return '-';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return DateFormat('yyyy.MM.dd').format(parsed.toLocal());
}

int? _teamIdFromDetail(Map<String, dynamic>? detail, {required bool isHome}) {
  if (detail == null || detail.isEmpty) return null;

  final match = detail['match'];
  final Map<String, dynamic> matchMap;
  if (match is Map<String, dynamic>) {
    matchMap = match;
  } else if (match is Map) {
    matchMap = Map<String, dynamic>.from(match);
  } else {
    matchMap = detail;
  }

  final prefix = isHome ? 'home' : 'away';
  final flatKey = isHome ? 'homeTeamId' : 'awayTeamId';
  final flatSnakeKey = isHome ? 'home_team_id' : 'away_team_id';
  final flatId = (matchMap[flatKey] as num?)?.toInt() ??
      (matchMap[flatSnakeKey] as num?)?.toInt();
  if (flatId != null) return flatId;

  final side = matchMap[prefix];
  if (side is Map) {
    return (side['id'] as num?)?.toInt();
  }
  return null;
}

String _normalizeLeagueCode(String? league) {
  final upper = (league ?? '').trim().toUpperCase();
  if (upper.contains('MLB') || upper.contains('MAJOR')) return 'MLB';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('KBO') || upper.contains('KOREA')) return 'KBO';
  return upper;
}

class _BaseballH2HReportBlockCard extends StatelessWidget {
  const _BaseballH2HReportBlockCard({
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

class _BaseballH2HReportBlockSkeleton extends StatelessWidget {
  const _BaseballH2HReportBlockSkeleton();

  @override
  Widget build(BuildContext context) {
    return const TsSkeletonBlock(TsSkeletonType.block);
  }
}

class _BaseballH2HReportBlockFailure extends StatelessWidget {
  const _BaseballH2HReportBlockFailure({
    required this.retry,
    required this.description,
  });

  final MatchReportRetryButton retry;
  final String description;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TsEmptyState(
      type: TsEmptyType.failure,
      title: l10n.reportBlockLoadError,
      description: description,
      actionLabel: retry.inProgress ? l10n.retryInProgress : l10n.retry,
      onAction: retry.action,
    );
  }
}

class _BaseballH2HReportBlockEmpty extends StatelessWidget {
  const _BaseballH2HReportBlockEmpty({
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
