import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/utils/baseball_status.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/core/utils/match_date_formatter.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_hero.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/matches/widgets/soccer_predict_report_blocks.dart';

class MatchReportScreen extends ConsumerStatefulWidget {
  const MatchReportScreen({
    required this.sport,
    required this.matchId,
    this.initialHeader,
    super.key,
  });

  final String sport;
  final String matchId;
  final MatchHeaderData? initialHeader;

  @override
  ConsumerState<MatchReportScreen> createState() => _MatchReportScreenState();
}

class _MatchReportScreenState extends ConsumerState<MatchReportScreen> {
  bool _retryInProgress = false;
  Future<void>? _refreshInFlight;
  Object? _cachedTransportFailureError;

  SoccerAnalysisParams? get _soccerParams {
    final header = widget.initialHeader;
    if (widget.sport != 'soccer' || header == null) return null;
    return SoccerAnalysisParams.fromHeader(header);
  }

  Future<void> _guardedRetry(Future<void> Function() work) async {
    if (_retryInProgress) return;
    setState(() => _retryInProgress = true);
    try {
      await work();
    } finally {
      if (mounted) {
        setState(() => _retryInProgress = false);
      }
    }
  }

  Future<void> _onPullToRefresh() async {
    final params = _soccerParams;
    if (params == null) return;

    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _guardedRetry(() => refreshSoccerMatchReport(ref, params));
    _refreshInFlight = future;
    try {
      await future;
    } finally {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    }
  }

  MatchReportRetryButton _retryButton(Future<void> Function() work) {
    return MatchReportRetryButton(
      inProgress: _retryInProgress,
      onPressed: () => unawaited(_guardedRetry(work)),
    );
  }

  List<AsyncValue<dynamic>> _reportSections(
    WidgetRef ref,
    SoccerAnalysisParams params,
  ) {
    return [
      ref.watch(soccerPredictionProvider(params)),
      ref.watch(homeTeamStatsProvider(params)),
      ref.watch(awayTeamStatsProvider(params)),
      ref.watch(soccerH2HAnalysisProvider(params)),
    ];
  }

  bool _reportHasAnySectionData(List<AsyncValue<dynamic>> sections) {
    return sections.any((section) => section.hasValue);
  }

  bool _reportHasPartialNonTransportFailure(List<AsyncValue<dynamic>> sections) {
    final hasData = _reportHasAnySectionData(sections);
    final hasNonTransportError = sections.any(
      (section) => section.hasError && !isTransportFailure(section.error),
    );
    if (hasNonTransportError) return true;
    return hasData && sections.any((section) => section.hasError);
  }

  /// True while sections are still resolving, but every settled section is a
  /// transport failure and at least one has failed — not a blank first load.
  bool _isEmergingTotalTransportFailure(List<AsyncValue<dynamic>> sections) {
    final hasTransportError = sections.any(
      (section) => section.hasError && isTransportFailure(section.error),
    );
    if (!hasTransportError) return false;

    return sections.every(
      (section) =>
          section.isLoading ||
          (section.hasError && isTransportFailure(section.error)),
    );
  }

  bool _allSectionsSettled(List<AsyncValue<dynamic>> sections) {
    return sections.every((section) => !section.isLoading);
  }

  /// True while a full-report retry is still resolving after a total outage.
  ///
  /// Holds when more sections are loading than have data, so per-block retries
  /// (one loading, several with data) do not trigger the screen-level layout.
  bool _isRecoveringFromTotalOutage(List<AsyncValue<dynamic>> sections) {
    if (!_retryInProgress) return false;
    if (_allSectionsSettled(sections)) return false;
    if (_reportHasPartialNonTransportFailure(sections)) return false;

    final loadingCount = sections.where((section) => section.isLoading).length;
    final dataCount = sections.where((section) => section.hasValue).length;
    return loadingCount >= dataCount;
  }

  /// Shared entry + recovery rule for the screen-level transport failure layout.
  bool _showScreenLevelFailure(
    WidgetRef ref,
    SoccerAnalysisParams params,
    List<AsyncValue<dynamic>> sections,
  ) {
    if (ref.watch(soccerReportScreenFailureProvider(params))) {
      return true;
    }
    if (_reportHasPartialNonTransportFailure(sections)) return false;
    if (_isEmergingTotalTransportFailure(sections)) return true;
    if (_isRecoveringFromTotalOutage(sections)) return true;
    return false;
  }

  Object? _transportFailureError(
    WidgetRef ref,
    SoccerAnalysisParams params,
    List<AsyncValue<dynamic>> sections,
  ) {
    final aggregated =
        ref.watch(soccerReportTransportFailureErrorProvider(params));
    if (aggregated != null) {
      return aggregated;
    }

    for (final section in sections) {
      if (section.hasError && isTransportFailure(section.error)) {
        return section.error;
      }
    }

    return _cachedTransportFailureError;
  }

  void _listenForTransportFailureError(SoccerAnalysisParams params) {
    ref.listen<Object?>(
      soccerReportTransportFailureErrorProvider(params),
      (_, next) {
        if (next != null && next != _cachedTransportFailureError) {
          setState(() => _cachedTransportFailureError = next);
        }
      },
    );
    ref.listen<bool>(
      soccerReportScreenFailureProvider(params),
      (_, showsFailure) {
        if (!showsFailure && !_retryInProgress && _cachedTransportFailureError != null) {
          setState(() => _cachedTransportFailureError = null);
        }
      },
    );
  }

  Widget _buildSoccerReportBlocks(WidgetRef ref, SoccerAnalysisParams params) {
    return SoccerPredictReportBlocks(
      header: widget.initialHeader!,
      predictionRetry: _retryButton(
        () => refreshPrediction(ref, params),
      ),
      teamStatsRetry: _retryButton(
        () => refreshTeamStatsProviders(ref, params),
      ),
      h2hRetry: _retryButton(
        () => refreshH2HAnalysis(ref, params),
      ),
    );
  }

  Widget _buildSoccerReportTransportFailure(
    SoccerAnalysisParams params,
    Object? error,
  ) {
    return _SoccerReportTransportFailure(
      error: error,
      retry: _retryButton(() => refreshSoccerMatchReport(ref, params)),
    );
  }

  double _minScrollContentHeight(BuildContext context, double scrollBottomPadding) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        kToolbarHeight -
        TsSpacing.lg -
        scrollBottomPadding;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final numericMatchId = int.tryParse(widget.matchId);
    final params = _soccerParams;
    final bottomPadding =
        TsSpacing.xl + MediaQuery.viewPaddingOf(context).bottom;
    final soccerParams = params;
    final hasSoccerBlocks = widget.sport == 'soccer' &&
        widget.initialHeader != null &&
        soccerParams != null;
    if (hasSoccerBlocks) {
      _listenForTransportFailureError(soccerParams);
    }
    final reportSections =
        hasSoccerBlocks ? _reportSections(ref, soccerParams) : <AsyncValue<dynamic>>[];
    final showScreenLevelFailure = hasSoccerBlocks &&
        _showScreenLevelFailure(ref, soccerParams, reportSections);
    final transportFailureError = hasSoccerBlocks
        ? _transportFailureError(ref, soccerParams, reportSections)
        : null;
    final scrollContentMinHeight =
        _minScrollContentHeight(context, bottomPadding);

    final content = ConstrainedBox(
      constraints: showScreenLevelFailure
          ? BoxConstraints(
              minHeight: scrollContentMinHeight,
              maxHeight: scrollContentMinHeight,
            )
          : BoxConstraints(minHeight: scrollContentMinHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHero(ref, numericMatchId),
          if (hasSoccerBlocks) ...[
            const SizedBox(height: TsSpacing.lg),
            if (showScreenLevelFailure)
              Expanded(
                child: Center(
                  child: _buildSoccerReportTransportFailure(
                    soccerParams,
                    transportFailureError,
                  ),
                ),
              )
            else
              _buildSoccerReportBlocks(ref, soccerParams),
          ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: 'Match Report',
        onBack: () => context.pop(),
      ),
      body: params == null
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                TsSpacing.lg,
                TsSpacing.lg,
                TsSpacing.lg,
                bottomPadding,
              ),
              child: content,
            )
          : RefreshIndicator(
              onRefresh: _onPullToRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  TsSpacing.lg,
                  TsSpacing.lg,
                  TsSpacing.lg,
                  bottomPadding,
                ),
                child: content,
              ),
            ),
    );
  }

  Widget _buildHero(WidgetRef ref, int? numericMatchId) {
    if (widget.sport == 'baseball' && numericMatchId != null) {
      final detailAsync = ref.watch(
        baseballMatchDetailProvider(numericMatchId),
      );
      return detailAsync.when(
        data: (detail) {
          MatchHeaderData? header = widget.initialHeader;
          if (detail.isNotEmpty) {
            final apiHeader = MatchHeaderData.fromBaseballMatchDetail(
              detail,
              matchId: numericMatchId,
            );
            header = (header ?? apiHeader).mergeWith(apiHeader);
          }
          if (header == null) {
            return const _MatchHeroSkeleton();
          }
          return _MatchReportHero(header: header, sport: widget.sport);
        },
        loading: () {
          if (widget.initialHeader != null) {
            return _MatchReportHero(
              header: widget.initialHeader!,
              sport: widget.sport,
            );
          }
          return const _MatchHeroSkeleton();
        },
        error: (_, _) {
          if (widget.initialHeader != null) {
            return _MatchReportHero(
              header: widget.initialHeader!,
              sport: widget.sport,
            );
          }
          return const _MatchHeroSkeleton();
        },
      );
    }

    if (widget.initialHeader != null) {
      return _MatchReportHero(header: widget.initialHeader!, sport: widget.sport);
    }
    return const _MatchHeroSkeleton();
  }
}

class _SoccerReportTransportFailure extends StatelessWidget {
  const _SoccerReportTransportFailure({
    required this.error,
    required this.retry,
  });

  final Object? error;
  final MatchReportRetryButton retry;

  @override
  Widget build(BuildContext context) {
    return TsEmptyState(
      type: TsEmptyType.failure,
      title: 'Could not load',
      description: resolveApiError(context, error),
      actionLabel: retry.label,
      onAction: retry.action,
    );
  }
}

class _MatchReportHero extends StatelessWidget {
  const _MatchReportHero({required this.header, required this.sport});

  final MatchHeaderData header;
  final String sport;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final labels = _heroCenterLabels(header, sport: sport, locale: locale);

    return TsMatchHero(
      leagueId: header.resolvedLeagueIconId,
      homeTeam: localizedTeamName(context, header.homeTeam, header.homeTeamKo),
      awayTeam: localizedTeamName(context, header.awayTeam, header.awayTeamKo),
      homeEmblemUrl: header.homeTeamLogo,
      awayEmblemUrl: header.awayTeamLogo,
      centerLabel: labels.$1,
      subLabel: labels.$2,
    );
  }
}

class _MatchHeroSkeleton extends StatelessWidget {
  const _MatchHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: TsSpacing.xl,
        horizontal: TsSpacing.md,
      ),
      decoration: BoxDecoration(color: c.surface, borderRadius: TsRadius.md),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsSkeletonBlock(TsSkeletonType.circle, width: 32),
          SizedBox(height: TsSpacing.lg),
          TsSkeletonBlock(TsSkeletonType.block),
        ],
      ),
    );
  }
}

(String? centerLabel, String? subLabel) _heroCenterLabels(
  MatchHeaderData header, {
  required String sport,
  required String locale,
}) {
  final status = header.matchStatus;
  if (status == 'live' || status == 'finished') {
    final home = header.homeScore;
    final away = header.awayScore;
    final center = home != null && away != null ? '$home - $away' : null;
    final sub = switch (status) {
      'finished' => 'FT',
      'live' =>
        sport == 'baseball'
            ? _baseballLiveStatusLabel(header.rawStatus)
            : (header.rawStatus?.trim().isNotEmpty == true
                  ? header.rawStatus!.trim().toUpperCase()
                  : 'LIVE'),
      _ => null,
    };
    return (center, sub);
  }

  final timestamp = header.matchTimestamp;
  if (timestamp != null) {
    final local = timestamp.toLocal();
    final center = DateFormat('HH:mm').format(local);
    final sub = _heroDateLabel(locale, local);
    return (center, sub);
  }

  if (header.matchTime.isNotEmpty) {
    return (
      header.matchTime,
      header.matchDate.isNotEmpty ? header.matchDate : null,
    );
  }

  return (null, null);
}

String _heroDateLabel(String locale, DateTime local) {
  if (isKoreanLocaleCode(locale)) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[local.weekday - 1];
    return '${local.month}월 ${local.day}일 $weekday요일';
  }
  final month = DateFormat('MMM', 'en').format(local);
  final weekday = DateFormat('EEE', 'en').format(local);
  return '$month ${local.day} ($weekday)';
}

String _baseballLiveStatusLabel(String? rawStatus) {
  final code = rawStatus?.trim().toUpperCase() ?? '';
  if (code.isEmpty) return 'LIVE';
  if (BaseballStatus.isLive(code)) return code;
  return 'LIVE';
}
