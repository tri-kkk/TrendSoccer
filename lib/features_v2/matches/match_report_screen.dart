import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/utils/baseball_status.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/core/utils/league_supports_analysis.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/core/utils/match_date_formatter.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_hero.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/matches/widgets/baseball_ai_match_analysis_report_block.dart';
import 'package:trendsoccer/features_v2/matches/widgets/baseball_pitcher_analysis_report_block.dart';
import 'package:trendsoccer/features_v2/matches/widgets/baseball_extended_report_blocks.dart';
import 'package:trendsoccer/features_v2/matches/widgets/baseball_h2h_report_block.dart';
import 'package:trendsoccer/features_v2/matches/widgets/baseball_starting_pitchers_report_block.dart';
import 'package:trendsoccer/features_v2/matches/widgets/baseball_report_lock_policy.dart';
import 'package:trendsoccer/features_v2/matches/widgets/soccer_predict_report_blocks.dart';
import 'package:trendsoccer/features_v2/matches/widgets/soccer_report_lock_policy.dart';

// #106 — flip to true once the backend gate is lifted
const _guestFactBlocksUnlocked = false;

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
    if (params != null) {
      final auth = ref.read(authProvider);
      final lockPolicy = SoccerReportLockPolicy.resolve(
        l10n: context.l10n,
        isGuest: auth.isGuest,
        hasFullAccess: auth.hasFullAccess,
        guestFactBlocksUnlocked: _guestFactBlocksUnlocked,
        onGuestTap: () => context.push('/login'),
        onSubscribeTap: () => context.push('/menu/subscribe'),
      );

      final inFlight = _refreshInFlight;
      if (inFlight != null) {
        return inFlight;
      }

      final future = _guardedRetry(
        () => refreshSoccerMatchReport(
          ref,
          params,
          fetchPrediction: lockPolicy.shouldFetchPrediction,
          fetchTeamStats: lockPolicy.shouldFetchTeamStats,
          fetchH2h: lockPolicy.shouldFetchH2h,
        ),
      );
      _refreshInFlight = future;
      try {
        await future;
      } finally {
        if (identical(_refreshInFlight, future)) {
          _refreshInFlight = null;
        }
      }
      return;
    }

    if (widget.sport != 'baseball') return;
    final matchId = int.tryParse(widget.matchId);
    final header = widget.initialHeader;
    if (matchId == null || header == null) return;
    if (!_baseballLeagueSupportsReport(header.leagueCode)) return;

    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _guardedRetry(
      () => _refreshBaseballMatchReport(matchId, header),
    );
    _refreshInFlight = future;
    try {
      await future;
    } finally {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<void> _refreshBaseballMatchReport(
    int matchId,
    MatchHeaderData header,
  ) async {
    final league = _normalizeBaseballLeagueCode(header.leagueCode ?? '');
    final cachedDetail = ref.read(baseballMatchDetailProvider(matchId)).value;

    BaseballPitcherStatsParams? asianParams;
    if (league == 'KBO' || league == 'NPB') {
      if (cachedDetail != null && cachedDetail.isNotEmpty) {
        asianParams = _baseballAsianPitcherStatsParams(cachedDetail, league);
      }
    }

    final homeTeamId = header.homeTeamId ??
        _baseballTeamIdFromDetail(cachedDetail, isHome: true);
    final awayTeamId = header.awayTeamId ??
        _baseballTeamIdFromDetail(cachedDetail, isHome: false);
    BaseballH2HParams? h2hParams;
    if (homeTeamId != null && awayTeamId != null) {
      h2hParams = (homeTeamId: homeTeamId, awayTeamId: awayTeamId);
    }

    ref.invalidate(baseballMatchDetailProvider(matchId));
    ref.invalidate(baseballPredictProvider(matchId));
    ref.invalidate(baseballPitcherAnalysisProvider(matchId));
    if (league == 'MLB') {
      ref.invalidate(mlbPitcherStatsProvider(matchId));
      ref.invalidate(mlbPitcherStatsPrevProvider(matchId));
    }
    if (asianParams != null &&
        (asianParams.homePitcher.isNotEmpty ||
            asianParams.awayPitcher.isNotEmpty)) {
      ref.invalidate(baseballPitcherStatsProvider(asianParams));
    }
    if (h2hParams != null) {
      ref.invalidate(baseballH2HProvider(h2hParams));
    }

    try {
      final waits = <Future<void>>[
        ref.read(baseballMatchDetailProvider(matchId).future),
        ref.read(baseballPredictProvider(matchId).future),
        ref.read(baseballPitcherAnalysisProvider(matchId).future),
      ];
      if (league == 'MLB') {
        waits.add(ref.read(mlbPitcherStatsProvider(matchId).future));
        waits.add(ref.read(mlbPitcherStatsPrevProvider(matchId).future));
      }
      if (asianParams != null &&
          (asianParams.homePitcher.isNotEmpty ||
              asianParams.awayPitcher.isNotEmpty)) {
        waits.add(ref.read(baseballPitcherStatsProvider(asianParams).future));
      }
      if (h2hParams != null) {
        waits.add(ref.read(baseballH2HProvider(h2hParams).future));
      }
      await Future.wait(waits);

      final detail = ref.read(baseballMatchDetailProvider(matchId)).value;
      if (detail == null || detail.isEmpty) return;

      final secondaryWaits = <Future<void>>[];

      if (h2hParams == null) {
        final resolvedHomeTeamId = header.homeTeamId ??
            _baseballTeamIdFromDetail(detail, isHome: true);
        final resolvedAwayTeamId = header.awayTeamId ??
            _baseballTeamIdFromDetail(detail, isHome: false);
        if (resolvedHomeTeamId != null && resolvedAwayTeamId != null) {
          final resolvedH2hParams = (
            homeTeamId: resolvedHomeTeamId,
            awayTeamId: resolvedAwayTeamId,
          );
          ref.invalidate(baseballH2HProvider(resolvedH2hParams));
          secondaryWaits.add(
            ref.read(baseballH2HProvider(resolvedH2hParams).future),
          );
        }
      }

      if ((league == 'KBO' || league == 'NPB') && asianParams == null) {
        final resolvedAsianParams =
            _baseballAsianPitcherStatsParams(detail, league);
        if (resolvedAsianParams != null &&
            (resolvedAsianParams.homePitcher.isNotEmpty ||
                resolvedAsianParams.awayPitcher.isNotEmpty)) {
          ref.invalidate(baseballPitcherStatsProvider(resolvedAsianParams));
          secondaryWaits.add(
            ref.read(baseballPitcherStatsProvider(resolvedAsianParams).future),
          );
        }
      }

      if (secondaryWaits.isNotEmpty) {
        await Future.wait(secondaryWaits);
      }
    } on Object {
      // RefreshIndicator must complete normally; failure UI comes from provider state.
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
    SoccerReportLockPolicy lockPolicy,
  ) {
    return [
      if (lockPolicy.shouldFetchPrediction)
        ref.watch(soccerPredictionProvider(params)),
      if (lockPolicy.shouldFetchTeamStats) ...[
        ref.watch(homeTeamStatsProvider(params)),
        ref.watch(awayTeamStatsProvider(params)),
      ],
      if (lockPolicy.shouldFetchH2h)
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
    if (sections.isEmpty) return false;
    if (soccerReportHasTotalTransportFailure(sections)) return true;
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
    final aggregated = soccerReportTransportFailureError(sections);
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

  void _listenForTransportFailureError(
    SoccerAnalysisParams params,
    List<AsyncValue<dynamic>> sections,
  ) {
    final next = soccerReportTransportFailureError(sections);
    if (next != null && next != _cachedTransportFailureError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (next != _cachedTransportFailureError) {
          setState(() => _cachedTransportFailureError = next);
        }
      });
    }
  }

  Widget _buildSoccerReportBlocks(
    WidgetRef ref,
    SoccerAnalysisParams params,
    SoccerReportLockPolicy lockPolicy,
  ) {
    return SoccerPredictReportBlocks(
      header: widget.initialHeader!,
      lockPolicy: lockPolicy,
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
    SoccerReportLockPolicy lockPolicy,
    Object? error,
  ) {
    return _SoccerReportTransportFailure(
      error: error,
      retry: _retryButton(
        () => refreshSoccerMatchReport(
          ref,
          params,
          fetchPrediction: lockPolicy.shouldFetchPrediction,
          fetchTeamStats: lockPolicy.shouldFetchTeamStats,
          fetchH2h: lockPolicy.shouldFetchH2h,
        ),
      ),
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
    final l10n = context.l10n;
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final numericMatchId = int.tryParse(widget.matchId);
    final params = _soccerParams;
    final bottomPadding =
        TsSpacing.xl + MediaQuery.viewPaddingOf(context).bottom;
    final soccerParams = params;
    final hasSoccerBlocks = widget.sport == 'soccer' &&
        widget.initialHeader != null &&
        soccerParams != null;
    final hasBaseballPitchersBlock = widget.sport == 'baseball' &&
        widget.initialHeader != null &&
        _baseballLeagueSupportsReport(widget.initialHeader!.leagueCode);
    final auth = ref.watch(authProvider);
    final lockPolicy = hasSoccerBlocks
        ? SoccerReportLockPolicy.resolve(
            l10n: l10n,
            isGuest: auth.isGuest,
            hasFullAccess: auth.hasFullAccess,
            guestFactBlocksUnlocked: _guestFactBlocksUnlocked,
            onGuestTap: () => context.push('/login'),
            onSubscribeTap: () => context.push('/menu/subscribe'),
          )
        : null;
    if (hasSoccerBlocks) {
      _listenForTransportFailureError(
        soccerParams,
        _reportSections(ref, soccerParams, lockPolicy!),
      );
    }
    final reportSections = hasSoccerBlocks
        ? _reportSections(ref, soccerParams, lockPolicy!)
        : <AsyncValue<dynamic>>[];
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
                    lockPolicy!,
                    transportFailureError,
                  ),
                ),
              )
            else
              _buildSoccerReportBlocks(ref, soccerParams, lockPolicy!),
          ],
          if (hasBaseballPitchersBlock) ...[
            const SizedBox(height: TsSpacing.lg),
            ..._buildBaseballReportBlocks(
              context,
              header: widget.initialHeader!,
              auth: auth,
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: l10n.matchReportTitle,
        onBack: () => context.pop(),
      ),
      body: params == null
          ? RefreshIndicator(
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

  bool _baseballLeagueSupportsReport(String? leagueCode) =>
      leagueSupportsAnalysis('baseball', leagueCode);

  List<Widget> _buildBaseballReportBlocks(
    BuildContext context, {
    required MatchHeaderData header,
    required SupabaseAuthProvider auth,
  }) {
    final lockPolicy = BaseballReportLockPolicy.resolve(
      l10n: context.l10n,
      isGuest: auth.isGuest,
      hasFullAccess: auth.hasFullAccess,
      onGuestTap: () => context.push('/login'),
      onSubscribeTap: () => context.push('/menu/subscribe'),
    );

    return [
      BaseballAiMatchAnalysisReportBlock(
        header: header,
        lockPolicy: lockPolicy,
      ),
      const SizedBox(height: TsSpacing.lg),
      BaseballStartingPitchersReportBlock(header: header),
      const SizedBox(height: TsSpacing.lg),
      BaseballPitcherAnalysisReportBlock(header: header),
      const SizedBox(height: TsSpacing.lg),
      BaseballTeamProductionReportBlock(
        header: header,
        lockPolicy: lockPolicy,
      ),
      const SizedBox(height: TsSpacing.lg),
      BaseballSeasonTeamStatsReportBlock(
        header: header,
        lockPolicy: lockPolicy,
      ),
      const SizedBox(height: TsSpacing.lg),
      BaseballRecentFormReportBlock(
        header: header,
        lockPolicy: lockPolicy,
      ),
      const SizedBox(height: TsSpacing.lg),
      BaseballHeadToHeadReportBlock(header: header),
      const SizedBox(height: TsSpacing.lg),
      BaseballScoringAnalysisReportBlock(header: header),
    ];
  }

  Widget _buildUnsupportedBaseballReport(BuildContext context) {
    final l10n = context.l10n;
    return TsEmptyState(
      type: TsEmptyType.noData,
      title: l10n.matchReportTitle,
      description: l10n.analysisEmpty,
    );
  }

  MatchHeaderData? _resolveBaseballHeader(
    Map<String, dynamic> detail,
    int matchId,
  ) {
    MatchHeaderData? header = widget.initialHeader;
    if (detail.isNotEmpty) {
      final apiHeader = MatchHeaderData.fromBaseballMatchDetail(
        detail,
        matchId: matchId,
      );
      header = (header ?? apiHeader).mergeWith(apiHeader);
    }
    return header;
  }

  Widget _buildBaseballReportContent(WidgetRef ref, int matchId) {
    final detailAsync = ref.watch(baseballMatchDetailProvider(matchId));

    return detailAsync.when(
      data: (detail) {
        final header = _resolveBaseballHeader(detail, matchId);
        if (header == null) {
          return const _MatchHeroSkeleton();
        }
        if (!_baseballLeagueSupportsReport(header.leagueCode)) {
          return _buildUnsupportedBaseballReport(context);
        }
        return _MatchReportHero(header: header, sport: widget.sport);
      },
      loading: () {
        final initialHeader = widget.initialHeader;
        if (initialHeader != null &&
            !_baseballLeagueSupportsReport(initialHeader.leagueCode)) {
          return _buildUnsupportedBaseballReport(context);
        }
        if (initialHeader != null) {
          return _MatchReportHero(
            header: initialHeader,
            sport: widget.sport,
          );
        }
        return const _MatchHeroSkeleton();
      },
      error: (_, _) {
        final initialHeader = widget.initialHeader;
        if (initialHeader != null &&
            !_baseballLeagueSupportsReport(initialHeader.leagueCode)) {
          return _buildUnsupportedBaseballReport(context);
        }
        if (initialHeader != null) {
          return _MatchReportHero(
            header: initialHeader,
            sport: widget.sport,
          );
        }
        return const _MatchHeroSkeleton();
      },
    );
  }

  Widget _buildHero(WidgetRef ref, int? numericMatchId) {
    if (widget.sport == 'baseball' && numericMatchId != null) {
      return _buildBaseballReportContent(ref, numericMatchId);
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
    final l10n = context.l10n;
    return TsEmptyState(
      type: TsEmptyType.failure,
      title: l10n.matchReportBlockLoadError,
      description: resolveApiError(context, error),
      actionLabel: retry.inProgress ? l10n.retryInProgress : l10n.retry,
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
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final labels = _heroCenterLabels(
      header,
      l10n: l10n,
      sport: sport,
      locale: locale,
    );

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
  required AppLocalizations l10n,
  required String sport,
  required String locale,
}) {
  final status = header.matchStatus;
  if (status == 'live' || status == 'finished') {
    final home = header.homeScore;
    final away = header.awayScore;
    final center = home != null && away != null ? '$home - $away' : null;
    final sub = switch (status) {
      'finished' => l10n.fixtureStatusFinal,
      'live' =>
        sport == 'baseball'
            ? _baseballLiveStatusLabel(header.rawStatus, l10n: l10n)
            : (header.rawStatus?.trim().isNotEmpty == true
                  ? header.rawStatus!.trim().toUpperCase()
                  : l10n.fixtureLive),
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

String _baseballLiveStatusLabel(
  String? rawStatus, {
  required AppLocalizations l10n,
}) {
  final code = rawStatus?.trim().toUpperCase() ?? '';
  if (code.isEmpty) return l10n.fixtureLive;
  if (BaseballStatus.isLive(code)) return code;
  return l10n.fixtureLive;
}

String _normalizeBaseballLeagueCode(String? league) {
  final upper = (league ?? '').trim().toUpperCase();
  if (upper.contains('MLB') || upper.contains('MAJOR')) return 'MLB';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('KBO') || upper.contains('KOREA')) return 'KBO';
  return upper;
}

int? _baseballTeamIdFromDetail(
  Map<String, dynamic>? detail, {
  required bool isHome,
}) {
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

Map<String, dynamic> _unwrapBaseballMatchDetail(Map<String, dynamic> detail) {
  final match = detail['match'];
  if (match is Map<String, dynamic>) return match;
  if (match is Map) return Map<String, dynamic>.from(match);
  return detail;
}

String? _readBaseballDetailString(
  Map<String, dynamic> map,
  List<String> keys,
) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

BaseballPitcherStatsParams? _baseballAsianPitcherStatsParams(
  Map<String, dynamic> detail,
  String leagueCode,
) {
  final match = _unwrapBaseballMatchDetail(detail);
  final league = _normalizeBaseballLeagueCode(leagueCode);
  if (league != 'KBO' && league != 'NPB') return null;

  final homeSide = match['home'];
  final awaySide = match['away'];
  final homeSideMap = homeSide is Map
      ? Map<String, dynamic>.from(homeSide)
      : <String, dynamic>{};
  final awaySideMap = awaySide is Map
      ? Map<String, dynamic>.from(awaySide)
      : <String, dynamic>{};

  final homePitcher = baseballAsianLeagueApiLookupName(
    _readBaseballDetailString(match, const ['homePitcher', 'home_pitcher']) ??
        _readBaseballDetailString(homeSideMap, const ['pitcher', 'name']),
    _readBaseballDetailString(match, const ['homePitcherKo', 'home_pitcher_ko']),
  );
  final awayPitcher = baseballAsianLeagueApiLookupName(
    _readBaseballDetailString(match, const ['awayPitcher', 'away_pitcher']) ??
        _readBaseballDetailString(awaySideMap, const ['pitcher', 'name']),
    _readBaseballDetailString(match, const ['awayPitcherKo', 'away_pitcher_ko']),
  );
  final homeTeam = baseballAsianLeagueApiLookupTeam(
    _readBaseballDetailString(match, const ['homeTeam', 'home_team']) ??
        _readBaseballDetailString(homeSideMap, const ['team', 'name']),
    _readBaseballDetailString(match, const ['homeTeamKo', 'home_team_ko']) ??
        _readBaseballDetailString(homeSideMap, const ['teamKo', 'team_ko']),
  );
  final awayTeam = baseballAsianLeagueApiLookupTeam(
    _readBaseballDetailString(match, const ['awayTeam', 'away_team']) ??
        _readBaseballDetailString(awaySideMap, const ['team', 'name']),
    _readBaseballDetailString(match, const ['awayTeamKo', 'away_team_ko']) ??
        _readBaseballDetailString(awaySideMap, const ['teamKo', 'team_ko']),
  );

  return (
    league: league.toLowerCase(),
    homePitcher: homePitcher,
    awayPitcher: awayPitcher,
    homeTeam: homeTeam,
    awayTeam: awayTeam,
  );
}
