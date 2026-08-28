import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/constants/alarm_preference_keys.dart';
import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/fixture_service.dart';
import 'package:trendsoccer/core/services/notification_service.dart';
import 'package:trendsoccer/core/utils/baseball_status.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/league_supports_analysis.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/core/utils/notification_permission_gate.dart';
import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_chip.dart';
import 'package:trendsoccer/design_system/widgets/ts_date_chip.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/design_system/widgets/ts_toast.dart';

/// Eight-day window: today − 3 … today + 4 (both sports).
const _dateChipCount = 8;
const _todayChipIndex = 3;

/// Soccer polls a lightweight live map overlay.
const _soccerLivePollInterval = Duration(seconds: 30);

/// Baseball re-fetches the full date list; `/api/baseball/matches` revalidates at 60s.
const _baseballLivePollInterval = Duration(seconds: 60);

const _soccerFinishedCacheTtl = Duration(minutes: 5);

LiveMatchData? _liveDataForFixtureMatch(
  FixtureMatch match,
  Map<String, LiveMatchData> liveMap,
) {
  final byMatchId = liveMap[match.matchId.toString()];
  if (byMatchId != null) return byMatchId;
  final apiMatchId = match.apiMatchId;
  if (apiMatchId != null) return liveMap[apiMatchId.toString()];
  return null;
}

bool _isSoccerHalftimeStatus(String? status) {
  if (status == null || status.isEmpty) return false;
  final normalized = status.trim().toUpperCase();
  return normalized == 'HT' || normalized.contains('HALFTIME');
}

String _formatSoccerElapsedTime(
  int elapsed,
  String status, {
  int? elapsedExtra,
}) {
  if (elapsedExtra != null && elapsedExtra > 0) {
    return '$elapsed+$elapsedExtra';
  }

  final normalized = status.trim().toUpperCase();
  if (normalized == '1H' && elapsed > 45) {
    return '45+${elapsed - 45}';
  }
  if (normalized == '2H' && elapsed > 90) {
    return '90+${elapsed - 90}';
  }
  return '$elapsed';
}

String _soccerLiveElapsedText(
  int elapsed,
  String status, {
  int? elapsedExtra,
}) {
  return "${_formatSoccerElapsedTime(elapsed, status, elapsedExtra: elapsedExtra)}'";
}

String _soccerLiveStatusLabel(FixtureMatch match, LiveMatchData? live) {
  if (live != null && _isSoccerHalftimeStatus(live.status)) return 'HT';
  if (_isSoccerHalftimeStatus(match.rawStatus)) return 'HT';

  if (live != null && live.isLive && live.elapsed > 0) {
    return _soccerLiveElapsedText(
      live.elapsed,
      live.status,
      elapsedExtra: live.elapsedExtra,
    );
  }

  return 'LIVE';
}

/// Uppercase inning label for the status column (`TOP 5` / `BOT 7`).
/// ARB keys render `Top 3` / `Bot 3` (issue #78) — not used here.
String _baseballLiveStatusLabel(String rawStatus) {
  final code = BaseballStatus.displayStatus(rawStatus);
  final topMatch = RegExp(r'^(\d+)T$').firstMatch(code);
  if (topMatch != null) return 'TOP ${topMatch.group(1)}';
  final bottomMatch = RegExp(r'^(\d+)B$').firstMatch(code);
  if (bottomMatch != null) return 'BOT ${bottomMatch.group(1)}';
  if (code.isNotEmpty && code != 'LIVE') return code;
  return 'LIVE';
}

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchRowPresentation {
  const _MatchRowPresentation({
    required this.status,
    required this.timeLabel,
  });

  final TsMatchRowStatus status;
  final String timeLabel;
}

class _MatchesScreenState extends ConsumerState<MatchesScreen>
    with WidgetsBindingObserver {
  final Set<String> _collapsedLeagueCodes = {};
  final ScrollController _scrollController = ScrollController();
  final Map<String, List<FixtureMatch>> _baseballDateCache = {};
  final Set<String> _baseballDateLoading = {};
  final Map<String, DateTime> _scoreChangedMatches = {};
  final Map<String, Map<String, dynamic>> _lastKnownSoccerLiveStates = {};
  final Map<String, DateTime> _soccerFinishedCacheAt = {};
  bool _baseballLoadFailed = false;
  Future<void>? _fixtureRefreshInFlight;
  Timer? _livePollingTimer;
  double _dateSwipeDragStartX = 0;
  double _dateSwipeDragEndX = 0;
  final Set<String> _alarmEnabledMatchIds = {};
  int _alarmRefreshGeneration = 0;
  final Set<String> _alarmToggleInFlight = {};

  static const _alarmBatchChunkSize = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureBaseballDateLoaded();
      _syncLivePolling();
    });
    // TODO(data): date strip does not refresh across midnight yet; an
    // AppLifecycle resume hook (as home_screen uses for profile) is where
    // chip dates would be regenerated and selection adjusted.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLivePolling();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncLivePolling();
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopLivePolling();
    }
  }

  String _weekdayLabel(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.E(locale).format(date);
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  List<DateTime> _chipDates() {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    return List.generate(
      _dateChipCount,
      (index) => todayDay.add(Duration(days: index - _todayChipIndex)),
    );
  }

  int _selectedDateIndex(String selectedDateStr, List<DateTime> chipDates) {
    final index = chipDates.indexWhere(
      (date) => fixtureDateString(date) == selectedDateStr,
    );
    return index < 0 ? _todayChipIndex : index;
  }

  bool _preferBundledLeagueIcon(String sport) => sport == 'baseball';

  List<FixtureMatch> _mergedBaseballCache() {
    final byMatchId = <int, FixtureMatch>{};
    final withoutId = <FixtureMatch>[];

    for (final matches in _baseballDateCache.values) {
      for (final match in matches) {
        if (match.matchId != 0) {
          byMatchId[match.matchId] = match;
        } else {
          withoutId.add(match);
        }
      }
    }

    return [...byMatchId.values, ...withoutId]
      ..sort((a, b) => a.matchTimestamp.compareTo(b.matchTimestamp));
  }

  void _publishBaseballCache() {
    ref.read(baseballLazyFixturesProvider.notifier).state =
        _mergedBaseballCache();
    ref.read(baseballLoadedDatesProvider.notifier).state =
        Set<String>.from(_baseballDateCache.keys);
    ref.read(baseballPolledFixturesProvider.notifier).state = null;
  }

  void _publishBaseballLoadingDates() {
    ref.read(baseballDateLoadingDatesProvider.notifier).state =
        Set<String>.from(_baseballDateLoading);
  }

  void _stopLivePolling() {
    _livePollingTimer?.cancel();
    _livePollingTimer = null;
  }

  bool _shouldPollLive() {
    if (!mounted) return false;

    final selectedDate = ref.read(fixtureSelectedDateProvider);
    if (!fixtureIsTodayDate(selectedDate)) return false;

    final matches = ref.read(allFixturesWithLiveProvider).value;
    if (matches == null || matches.isEmpty) return false;

    return matches
        .where((match) => matchIsOnDate(match, selectedDate))
        .any(
          (match) => match.status == 'live' || match.status == 'scheduled',
        );
  }

  void _reevaluateLivePollingGate() {
    if (!mounted) return;
    if (!_shouldPollLive()) {
      _stopLivePolling();
    }
  }

  void _syncLivePolling() {
    if (!mounted) return;
    if (!_shouldPollLive()) {
      _stopLivePolling();
      return;
    }
    _startLivePolling();
  }

  void _startLivePolling() {
    if (!mounted) return;
    _stopLivePolling();
    if (!_shouldPollLive()) return;

    final sport = ref.read(fixtureSelectedSportProvider);
    if (sport == 'soccer') {
      unawaited(_fetchLiveNow());
      _livePollingTimer = Timer.periodic(_soccerLivePollInterval, (_) {
        unawaited(_fetchLiveNow());
      });
    } else if (sport == 'baseball') {
      unawaited(_fetchBaseballNow());
      _livePollingTimer = Timer.periodic(_baseballLivePollInterval, (_) {
        unawaited(_fetchBaseballNow());
      });
    }
  }

  bool _isSoccerFinishedLiveStatus(String status) {
    final raw = status.trim().toUpperCase();
    return raw == 'FT' ||
        raw == 'AET' ||
        raw == 'PEN' ||
        normalizeMatchStatus(raw) == 'finished';
  }

  void _cleanExpiredScoreChanges() {
    final now = DateTime.now();
    _scoreChangedMatches.removeWhere(
      (_, time) => now.difference(time).inSeconds > 3,
    );
  }

  void _markScoreChanged(String matchId) {
    _scoreChangedMatches[matchId] = DateTime.now();
  }

  bool _detectFixtureScoreChanges(
    List<FixtureMatch> previousMatches,
    List<FixtureMatch> newMatches,
  ) {
    var changed = false;
    final previousById = <String, FixtureMatch>{
      for (final match in previousMatches) match.matchId.toString(): match,
    };

    for (final newMatch in newMatches) {
      final matchId = newMatch.matchId.toString();
      final prevMatch = previousById[matchId];
      if (prevMatch == null) continue;

      final prevHome = prevMatch.homeScore ?? 0;
      final prevAway = prevMatch.awayScore ?? 0;
      final newHome = newMatch.homeScore ?? 0;
      final newAway = newMatch.awayScore ?? 0;

      if (prevHome != newHome || prevAway != newAway) {
        _markScoreChanged(matchId);
        final apiMatchId = newMatch.apiMatchId;
        if (apiMatchId != null) {
          _markScoreChanged(apiMatchId.toString());
        }
        changed = true;
      }
    }

    _cleanExpiredScoreChanges();
    return changed;
  }

  bool _detectSoccerScoreChanges(Map<String, LiveMatchData> newLiveData) {
    var changed = false;

    for (final entry in newLiveData.entries) {
      final id = entry.key;
      final newLive = entry.value;
      final prev = _lastKnownSoccerLiveStates[id];
      if (prev == null) continue;

      final prevHome = (prev['homeScore'] as num?)?.toInt() ?? 0;
      final prevAway = (prev['awayScore'] as num?)?.toInt() ?? 0;

      if (prevHome != newLive.homeScore || prevAway != newLive.awayScore) {
        _markScoreChanged(id);
        changed = true;
      }
    }

    _cleanExpiredScoreChanges();
    return changed;
  }

  // Carried from v1 for score-highlight wiring once TsMatchRow supports it.
  // ignore: unused_element
  DateTime? _scoreChangeTimeForMatch(FixtureMatch match) {
    final matchId = match.matchId.toString();
    final direct = _scoreChangedMatches[matchId];
    if (direct != null) return direct;

    final apiMatchId = match.apiMatchId;
    if (apiMatchId != null) {
      return _scoreChangedMatches[apiMatchId.toString()];
    }
    return null;
  }

  void _notifyScoreChangesIfNeeded(bool changed) {
    if (!changed || !mounted) return;
    setState(() {});
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final before = _scoreChangedMatches.length;
      _cleanExpiredScoreChanges();
      if (before != _scoreChangedMatches.length) {
        setState(() {});
      }
    });
  }

  void _cacheSoccerLiveStates(Map<String, LiveMatchData> liveData) {
    final now = DateTime.now();
    for (final entry in liveData.entries) {
      final id = entry.key;
      final live = entry.value;
      final cached = <String, dynamic>{
        'status': live.status,
        'homeScore': live.homeScore,
        'awayScore': live.awayScore,
        'elapsed': live.elapsed,
        'elapsedExtra': live.elapsedExtra,
        'statusLong': live.statusLong,
      };
      if (_isSoccerFinishedLiveStatus(live.status)) {
        cached['finished'] = true;
        _soccerFinishedCacheAt[id] = now;
      }
      _lastKnownSoccerLiveStates[id] = cached;
    }

    _soccerFinishedCacheAt.removeWhere((id, finishedAt) {
      if (now.difference(finishedAt) > _soccerFinishedCacheTtl) {
        _lastKnownSoccerLiveStates.remove(id);
        return true;
      }
      return false;
    });
  }

  LiveMatchData _soccerLiveDataFromCache(
    String id,
    Map<String, dynamic> cached,
  ) {
    return LiveMatchData(
      matchId: id,
      status: cached['status']?.toString() ?? '',
      statusLong: cached['statusLong']?.toString() ?? '',
      elapsed: (cached['elapsed'] as num?)?.toInt() ?? 0,
      homeScore: (cached['homeScore'] as num?)?.toInt() ?? 0,
      awayScore: (cached['awayScore'] as num?)?.toInt() ?? 0,
      elapsedExtra: (cached['elapsedExtra'] as num?)?.toInt(),
    );
  }

  Map<String, LiveMatchData> _effectiveSoccerLiveMap(
    Map<String, LiveMatchData> pollData,
  ) {
    _cacheSoccerLiveStates(pollData);

    final effective = Map<String, LiveMatchData>.from(pollData);
    final now = DateTime.now();

    for (final entry in _lastKnownSoccerLiveStates.entries) {
      if (effective.containsKey(entry.key)) continue;

      final cached = entry.value;
      if (cached['finished'] == true) {
        final finishedAt = _soccerFinishedCacheAt[entry.key];
        if (finishedAt != null &&
            now.difference(finishedAt) > _soccerFinishedCacheTtl) {
          continue;
        }
      }

      effective[entry.key] = _soccerLiveDataFromCache(entry.key, cached);
    }

    return effective;
  }

  Future<void> _fetchLiveNow() async {
    if (!mounted) return;
    if (ref.read(fixtureSelectedSportProvider) != 'soccer') return;

    final service = ref.read(fixtureServiceProvider);
    final liveData = await service.getLiveMatches();
    if (!mounted) return;
    if (ref.read(fixtureSelectedSportProvider) != 'soccer') return;

    if (liveData.isEmpty) {
      _reevaluateLivePollingGate();
      return;
    }

    final scoreChanged = _detectSoccerScoreChanges(liveData);
    final effective = _effectiveSoccerLiveMap(liveData);
    ref.read(liveMatchesProvider.notifier).state = effective;
    _notifyScoreChangesIfNeeded(scoreChanged);

    if (effective.values.any((live) => live.isFinished)) {
      final base = ref.read(soccerPolledFixturesProvider) ??
          ref.read(soccerFixturesProvider).asData?.value;
      if (base != null) {
        ref.read(soccerPolledFixturesProvider.notifier).state =
            mergeSoccerFinishedFromLive(base, effective);
      }
    }

    _reevaluateLivePollingGate();
  }

  Future<void> _fetchBaseballNow() async {
    if (!mounted) return;
    if (ref.read(fixtureSelectedSportProvider) != 'baseball') return;

    final selectedDate = ref.read(fixtureSelectedDateProvider);
    try {
      final service = ref.read(fixtureServiceProvider);
      final dateMatches = await service
          .getBaseballFixtures(date: selectedDate)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (ref.read(fixtureSelectedSportProvider) != 'baseball') return;

      final base = ref.read(baseballLazyFixturesProvider);
      if (base.isEmpty) return;

      final merged =
          mergeBaseballTodayFixtures(base, dateMatches, selectedDate);
      final scoreChanged = _detectFixtureScoreChanges(base, merged);
      _baseballDateCache[selectedDate] = dateMatches;
      _publishBaseballCache();
      ref.read(baseballPolledFixturesProvider.notifier).state = merged;
      _notifyScoreChangesIfNeeded(scoreChanged);
    } on Object {
      // Non-fatal: poll failure keeps cached fixtures visible.
    }

    _reevaluateLivePollingGate();
  }

  void _ensureBaseballDateLoaded() {
    if (ref.read(fixtureSelectedSportProvider) != 'baseball') return;
    unawaited(_loadBaseballDate(ref.read(fixtureSelectedDateProvider)));
  }

  void _preloadAdjacentBaseballDates(String centerDate, List<DateTime> chipDates) {
    final chipDateStrings = chipDates.map(fixtureDateString).toList();
    final index = chipDateStrings.indexOf(centerDate);
    if (index < 0) return;

    if (index > 0) {
      unawaited(_loadBaseballDate(chipDateStrings[index - 1], background: true));
    }
    if (index < chipDateStrings.length - 1) {
      unawaited(_loadBaseballDate(chipDateStrings[index + 1], background: true));
    }
  }

  Future<void> _loadBaseballDate(
    String date, {
    bool background = false,
    bool force = false,
  }) async {
    if (ref.read(fixtureSelectedSportProvider) != 'baseball') return;
    if (_baseballDateLoading.contains(date)) return;
    if (!force && _baseballDateCache.containsKey(date)) return;

    _baseballDateLoading.add(date);
    _publishBaseballLoadingDates();

    try {
      final service = ref.read(fixtureServiceProvider);
      final matches = await service.getBaseballFixtures(date: date);
      if (!mounted) return;
      if (ref.read(fixtureSelectedSportProvider) != 'baseball') return;

      _baseballDateCache[date] = matches;
      _publishBaseballCache();
      if (mounted) setState(() => _baseballLoadFailed = false);

      if (!background) {
        _preloadAdjacentBaseballDates(date, _chipDates());
      }
    } on Object {
      if (!background && mounted) {
        setState(() => _baseballLoadFailed = true);
      }
    } finally {
      _baseballDateLoading.remove(date);
      _publishBaseballLoadingDates();
    }
  }

  Future<void> _retryFixtureLoad(String sport) async {
    final inFlight = _fixtureRefreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _performFixtureRefresh(sport);
    _fixtureRefreshInFlight = future;
    try {
      await future;
    } finally {
      if (identical(_fixtureRefreshInFlight, future)) {
        _fixtureRefreshInFlight = null;
      }
    }
  }

  Future<void> _performFixtureRefresh(String sport) async {
    if (sport == 'baseball') {
      if (mounted) setState(() => _baseballLoadFailed = false);
      try {
        await _loadBaseballDate(
          ref.read(fixtureSelectedDateProvider),
          force: true,
        );
        await _fetchBaseballNow();
      } on Object {
        // RefreshIndicator must complete normally; failure UI comes from
        // _baseballLoadFailed (baseball).
      }
      _syncLivePolling();
      if (!mounted) return;
      final baseballMatches = ref.read(allFixturesWithLiveProvider).value;
      if (baseballMatches != null) {
        await _refreshAlarmStatesForDate(
          baseballMatches,
          ref.read(fixtureSelectedDateProvider),
        );
      }
      return;
    }
    invalidateFixtureData(ref);
    try {
      await Future.wait([
        ref.read(soccerFixturesProvider.future),
        _fetchLiveNow(),
      ]);
    } on Object {
      // RefreshIndicator must complete normally; failure UI comes from provider
      // state (soccer AsyncError).
    }
    _syncLivePolling();
    if (!mounted) return;
    final matches = ref.read(allFixturesWithLiveProvider).value;
    if (matches != null) {
      await _refreshAlarmStatesForDate(
        matches,
        ref.read(fixtureSelectedDateProvider),
      );
    }
  }

  bool _rowShowsAlarmBell(TsMatchRowStatus status) {
    return status == TsMatchRowStatus.scheduled ||
        status == TsMatchRowStatus.live;
  }

  List<FixtureMatch> _matchesForSelectedDate(
    List<FixtureMatch> matches,
    String selectedDate,
  ) {
    return matches.where((m) => matchIsOnDate(m, selectedDate)).toList();
  }

  Future<void> _refreshAlarmStatesForDate(
    List<FixtureMatch> allMatches,
    String selectedDate,
  ) async {
    final generation = ++_alarmRefreshGeneration;
    final service = ref.read(notificationServiceProvider);
    final selectedSport = ref.read(fixtureSelectedSportProvider);

    final eligible = _matchesForSelectedDate(allMatches, selectedDate)
        .where(
          (match) =>
              match.matchId != 0 &&
              match.sport == selectedSport &&
              _rowShowsAlarmBell(_matchRowPresentation(match).status),
        )
        .toList();

    final matchIds = eligible.map((m) => m.matchId.toString()).toList();
    if (matchIds.isEmpty) {
      if (!mounted || generation != _alarmRefreshGeneration) return;
      setState(() => _alarmEnabledMatchIds.clear());
      return;
    }

    final results = <String, dynamic>{};
    for (var i = 0; i < matchIds.length; i += _alarmBatchChunkSize) {
      final chunk = matchIds.sublist(
        i,
        math.min(i + _alarmBatchChunkSize, matchIds.length),
      );
      final chunkResult = await service.getMatchAlarmsBatch(
        matchIds: chunk,
        sport: selectedSport,
      );
      results.addAll(chunkResult);
      if (!mounted || generation != _alarmRefreshGeneration) return;
    }

    final enabledIds = <String>{};
    for (final match in eligible) {
      final id = match.matchId.toString();
      final alarm = results[id];
      if (alarm is Map && alarm['enabled'] == true) {
        enabledIds.add(id);
      }
    }

    if (!mounted || generation != _alarmRefreshGeneration) return;
    setState(() {
      _alarmEnabledMatchIds
        ..clear()
        ..addAll(enabledIds);
    });
  }

  void _scheduleAlarmStateRefresh(
    List<FixtureMatch> matches, {
    Duration delay = Duration.zero,
    String? selectedDate,
  }) {
    final String date = selectedDate ?? ref.read(fixtureSelectedDateProvider);
    if (delay > Duration.zero) {
      Future<void>.delayed(delay, () {
        if (!mounted) return;
        unawaited(_refreshAlarmStatesForDate(matches, date));
      });
      return;
    }
    unawaited(_refreshAlarmStatesForDate(matches, date));
  }

  void _showAlarmToggleToast(FixtureMatch match, {required bool enabled}) {
    final l10n = context.l10n;
    final homeTeam = localizedTeamName(
      context,
      match.homeTeam,
      match.homeTeamKo,
    );
    final awayTeam = localizedTeamName(
      context,
      match.awayTeam,
      match.awayTeamKo,
    );
    final message = enabled
        ? l10n.alarmEnabledToast(homeTeam, awayTeam)
        : l10n.alarmDisabledToast(homeTeam, awayTeam);
    showTsToast(context, message, TsToastType.success);
  }

  Future<void> _onAlarmTap(FixtureMatch match) async {
    if (!_rowShowsAlarmBell(_matchRowPresentation(match).status)) return;

    final matchId = match.matchId;
    final id = matchId.toString();
    if (_alarmToggleInFlight.contains(id)) return;

    if (!await ensureNotificationPermissionGate(
      context,
      forMatchAlarm: true,
    )) {
      return;
    }
    if (!mounted) return;

    final sport = match.sport;
    final isCurrentlyOn = _alarmEnabledMatchIds.contains(id);
    final service = ref.read(notificationServiceProvider);
    final prefs = ref.read(sharedPreferencesProvider);

    _alarmToggleInFlight.add(id);
    try {
      if (isCurrentlyOn) {
        setState(() => _alarmEnabledMatchIds.remove(id));
        try {
          final ok = await service.saveMatchAlarmSettings(
            matchId,
            sport,
            false,
            AlarmPreferenceKeys.disabledEvents(prefs, sport),
          );
          if (!mounted) return;
          if (!ok) {
            setState(() => _alarmEnabledMatchIds.add(id));
            showTsToast(context, context.l10n.errorUnauthorized, TsToastType.error);
            return;
          }
          _showAlarmToggleToast(match, enabled: false);
        } on Object {
          if (!mounted) return;
          setState(() => _alarmEnabledMatchIds.add(id));
          showTsToast(context, context.l10n.errorUnauthorized, TsToastType.error);
        }
        return;
      }

      setState(() => _alarmEnabledMatchIds.add(id));
      try {
        final ok = await service.saveMatchAlarmSettings(
          matchId,
          sport,
          true,
          AlarmPreferenceKeys.globalEvents(prefs, sport),
        );
        if (!mounted) return;
        if (!ok) {
          setState(() => _alarmEnabledMatchIds.remove(id));
          showTsToast(context, context.l10n.errorUnauthorized, TsToastType.error);
          return;
        }
        _showAlarmToggleToast(match, enabled: true);
      } on Object {
        if (!mounted) return;
        setState(() => _alarmEnabledMatchIds.remove(id));
        showTsToast(context, context.l10n.errorUnauthorized, TsToastType.error);
      }
    } finally {
      _alarmToggleInFlight.remove(id);
    }
  }

  bool _showingFixtureFailure(
    AsyncValue<List<FixtureLeagueGroup>> groupsAsync,
    String sport,
  ) {
    return groupsAsync.when(
      loading: () => false,
      error: (_, _) => true,
      data: (groups) =>
          sport == 'baseball' && _baseballLoadFailed && groups.isEmpty,
    );
  }

  Future<void> _onMatchesRefresh() =>
      _retryFixtureLoad(ref.read(fixtureSelectedSportProvider));

  TsSport _tsSportFromProvider(String sport) =>
      sport == 'baseball' ? TsSport.baseball : TsSport.soccer;

  void _resetFilterToAll() {
    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    ref.read(fixtureLiveFilterProvider.notifier).state = false;
  }

  void _onSportChanged(TsSport sport) {
    final sportStr = sport == TsSport.baseball ? 'baseball' : 'soccer';
    ref.read(fixtureSelectedSportProvider.notifier).state = sportStr;
    _resetFilterToAll();
    setState(() {
      _collapsedLeagueCodes.clear();
      _baseballLoadFailed = false;
    });
    if (sportStr == 'baseball') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ensureBaseballDateLoaded();
      });
    }
    _syncLivePolling();
    final matches = ref.read(allFixturesWithLiveProvider).value;
    if (matches != null) {
      _scheduleAlarmStateRefresh(matches);
    }
  }

  void _onDateSelected(int index, List<DateTime> chipDates) {
    if (index < 0 || index >= chipDates.length) return;
    final dateStr = fixtureDateString(chipDates[index]);
    if (dateStr == ref.read(fixtureSelectedDateProvider)) return;
    _resetFilterToAll();
    ref.read(fixtureSelectedDateProvider.notifier).state = dateStr;
    if (ref.read(fixtureSelectedSportProvider) == 'baseball') {
      unawaited(_loadBaseballDate(dateStr));
    }
    _syncLivePolling();
    _scrollToTop();
    final matches = ref.read(allFixturesWithLiveProvider).value;
    if (matches != null) {
      _scheduleAlarmStateRefresh(matches, selectedDate: dateStr);
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _goToNextDate(int selectedIndex, List<DateTime> chipDates) {
    if (selectedIndex >= chipDates.length - 1) return;
    _onDateSelected(selectedIndex + 1, chipDates);
  }

  void _goToPreviousDate(int selectedIndex, List<DateTime> chipDates) {
    if (selectedIndex <= 0) return;
    _onDateSelected(selectedIndex - 1, chipDates);
  }

  void _onListDateSwipeEnd(
    DragEndDetails details,
    int selectedIndex,
    List<DateTime> chipDates,
  ) {
    final dx = _dateSwipeDragEndX - _dateSwipeDragStartX;
    final velocity = details.primaryVelocity;
    if (velocity == null && dx.abs() < 50) return;

    if ((velocity ?? 0) < -300 || dx < -50) {
      _goToNextDate(selectedIndex, chipDates);
    } else if ((velocity ?? 0) > 300 || dx > 50) {
      _goToPreviousDate(selectedIndex, chipDates);
    }
  }

  Widget _wrapListDateSwipe({
    required int selectedDateIndex,
    required List<DateTime> chipDates,
    required Widget child,
  }) {
    return _MatchesListDateSwipe(
      onDragStart: (details) {
        _dateSwipeDragStartX = details.globalPosition.dx;
        _dateSwipeDragEndX = details.globalPosition.dx;
      },
      onDragUpdate: (details) {
        _dateSwipeDragEndX = details.globalPosition.dx;
      },
      onDragEnd: (details) =>
          _onListDateSwipeEnd(details, selectedDateIndex, chipDates),
      child: child,
    );
  }

  void _onSelectAll() => _resetFilterToAll();

  void _onSelectLive() {
    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    ref.read(fixtureLiveFilterProvider.notifier).state = true;
  }

  void _onSelectLeague(String code) {
    ref.read(fixtureLiveFilterProvider.notifier).state = false;
    ref.read(fixtureSelectedLeagueProvider.notifier).state = code;
  }

  void _toggleCollapse(String leagueId) {
    setState(() {
      if (_collapsedLeagueCodes.contains(leagueId)) {
        _collapsedLeagueCodes.remove(leagueId);
      } else {
        _collapsedLeagueCodes.add(leagueId);
      }
    });
  }

  String _leagueFilterLabel(FixtureLeagueOption league) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'en') {
      return league.nameEn ?? league.name;
    }
    return league.name;
  }

  String _groupLeagueLabel(FixtureLeagueGroup group, String sport) {
    if (sport == 'baseball') {
      return group.leagueCode;
    }
    return localizedLeagueName(
      context,
      group.leagueNameEn,
      group.leagueName,
    );
  }

  String _leagueIconId(String leagueCode) =>
      TsAssets.leagueIconIdFromApiCode(leagueCode) ??
      leagueCode.toLowerCase();

  String _scheduledKickoffLabel(FixtureMatch match) {
    final local = match.matchTimestamp.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  _MatchRowPresentation _matchRowPresentation(FixtureMatch match) {
    final live = _liveDataForFixtureMatch(match, ref.read(liveMatchesProvider));

    return switch (match.status) {
      'postponed' => const _MatchRowPresentation(
          status: TsMatchRowStatus.disrupted,
          timeLabel: 'PPD',
        ),
      'cancelled' => const _MatchRowPresentation(
          status: TsMatchRowStatus.disrupted,
          timeLabel: 'CANC',
        ),
      'interrupted' => const _MatchRowPresentation(
          status: TsMatchRowStatus.disrupted,
          timeLabel: 'SUSP',
        ),
      'live' => _MatchRowPresentation(
          status: TsMatchRowStatus.live,
          timeLabel: match.sport == 'baseball'
              ? _baseballLiveStatusLabel(match.rawStatus)
              : _soccerLiveStatusLabel(match, live),
        ),
      'finished' => const _MatchRowPresentation(
          status: TsMatchRowStatus.finished,
          timeLabel: 'FT',
        ),
      'scheduled' => _MatchRowPresentation(
          status: TsMatchRowStatus.scheduled,
          timeLabel: _scheduledKickoffLabel(match),
        ),
      _ => _MatchRowPresentation(
          status: TsMatchRowStatus.scheduled,
          timeLabel: _scheduledKickoffLabel(match),
        ),
    };
  }

  String _emptyDateTitle(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    final formatted = DateFormat('EEE d', locale).format(date);
    return 'No matches on $formatted';
  }

  void _scrollToDateStrip() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String? _scoreText(int? score) => score?.toString();

  Widget _buildFilterRow({
    required String sport,
    required List<FixtureLeagueOption> leagues,
    required String? selectedLeague,
    required bool liveFilter,
  }) {
    final preferBundledIcon = _preferBundledLeagueIcon(sport);

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: leagues.length + 2,
        separatorBuilder: (_, _) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TsChip(
              label: 'All',
              selected: selectedLeague == null && !liveFilter,
              onTap: _onSelectAll,
            );
          }
          if (index == 1) {
            return TsChip(
              label: 'LIVE',
              selected: liveFilter,
              tone: TsChipTone.live,
              onTap: _onSelectLive,
            );
          }

          final league = leagues[index - 2];
          return _MatchesLeagueFilterChip(
            leagueId: _leagueIconId(league.code),
            logoUrl: preferBundledIcon ? null : league.logo,
            preferAsset: preferBundledIcon,
            label: _leagueFilterLabel(league),
            selected: selectedLeague == league.code && !liveFilter,
            onTap: () => _onSelectLeague(league.code),
          );
        },
      ),
    );
  }

  Widget _buildLeagueGroup(
    FixtureLeagueGroup group,
    TsThemeColors c,
    String sport,
  ) {
    final leagueId = _leagueIconId(group.leagueCode);
    final collapsed = _collapsedLeagueCodes.contains(group.leagueCode);
    final preferBundledIcon = _preferBundledLeagueIcon(sport);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 48,
            color: c.surfaceRaised,
            padding: const EdgeInsets.all(TsSpacing.md),
            child: _MatchesLeagueGroupHeader(
              leagueId: leagueId,
              logoUrl: preferBundledIcon ? null : group.leagueLogo,
              preferAsset: preferBundledIcon,
              label: _groupLeagueLabel(group, sport),
              hasAnalysis: leagueSupportsAnalysis(sport, group.leagueCode),
              matchCount: group.matches.length.toString(),
              collapsed: collapsed,
              onToggleCollapse: () => _toggleCollapse(group.leagueCode),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: collapsed
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(TsSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < group.matches.length; i++) ...[
                          _buildMatchRow(group.matches[i]),
                          if (i < group.matches.length - 1) ...[
                            const SizedBox(height: 6),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: c.borderSubtle,
                            ),
                            const SizedBox(height: 6),
                          ],
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchRow(FixtureMatch match) {
    final presentation = _matchRowPresentation(match);
    final showScores = presentation.status == TsMatchRowStatus.live ||
        presentation.status == TsMatchRowStatus.finished ||
        presentation.status == TsMatchRowStatus.disrupted;
    final showAlarmBell = _rowShowsAlarmBell(presentation.status);

    return TsMatchRow(
      homeTeam: localizedTeamName(
        context,
        match.homeTeam,
        match.homeTeamKo,
      ),
      awayTeam: localizedTeamName(
        context,
        match.awayTeam,
        match.awayTeamKo,
      ),
      timeLabel: presentation.timeLabel,
      status: presentation.status,
      homeScore: showScores ? _scoreText(match.homeScore) : null,
      awayScore: showScores ? _scoreText(match.awayScore) : null,
      homeEmblemUrl: match.homeTeamLogo,
      awayEmblemUrl: match.awayTeamLogo,
      alarmOn: showAlarmBell
          ? _alarmEnabledMatchIds.contains(match.matchId.toString())
          : null,
      onAlarmTap: showAlarmBell ? () => unawaited(_onAlarmTap(match)) : null,
    );
  }

  Widget _buildSkeletonGroups() {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          const TsSkeletonBlock(TsSkeletonType.block),
          if (i < 2) const SizedBox(height: TsSpacing.md),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final auth = ref.watch(authProvider);
    final hideMonetisation = auth.isPremium || auth.isTrial;

    final sport = ref.watch(fixtureSelectedSportProvider);
    final selectedDateStr = ref.watch(fixtureSelectedDateProvider);
    final selectedLeague = ref.watch(fixtureSelectedLeagueProvider);
    final liveFilter = ref.watch(fixtureLiveFilterProvider);
    final leagues = ref.watch(fixtureAvailableLeaguesProvider);
    final groupsAsync = ref.watch(fixtureLeagueGroupsProvider);
    final chipDates = _chipDates();

    ref.listen<List<FixtureLeagueOption>>(fixtureAvailableLeaguesProvider,
        (previous, next) {
      final selected = ref.read(fixtureSelectedLeagueProvider);
      if (selected == null) return;
      if (next.any((league) => league.code == selected)) return;
      ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    });

    ref.listen<AsyncValue<List<FixtureLeagueGroup>>>(
      fixtureLeagueGroupsProvider,
      (previous, next) {
        if (!next.hasValue) return;
        if (_shouldPollLive()) {
          if (_livePollingTimer == null) {
            _startLivePolling();
          }
        } else {
          _stopLivePolling();
        }
      },
    );

    ref.listen<AsyncValue<List<FixtureMatch>>>(allFixturesWithLiveProvider,
        (previous, next) {
      next.whenData((matches) {
        _scheduleAlarmStateRefresh(matches);
      });
    });

    ref.listen(authProvider, (previous, next) {
      final wasLoggedIn = previous?.isLoggedIn ?? false;
      final isLoggedIn = next.isLoggedIn;

      // Logout: keep bell states in memory (device-level settings).
      if (wasLoggedIn && !isLoggedIn) return;

      final matches = ref.read(allFixturesWithLiveProvider).value;
      if (matches == null) return;

      if (!wasLoggedIn && isLoggedIn) {
        _scheduleAlarmStateRefresh(
          matches,
          delay: const Duration(milliseconds: 500),
        );
        return;
      }

      _scheduleAlarmStateRefresh(matches);
    });

    final selectedDateIndex = _selectedDateIndex(selectedDateStr, chipDates);
    final showingFixtureFailure = _showingFixtureFailure(groupsAsync, sport);

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: hideMonetisation ? TsAppBarType.homeMember : TsAppBarType.homeGuest,
        authLabel: 'Log in',
        onAuthTap: () => context.go('/login'),
        tierLabel: 'PREMIUM',
      ),
      body: RefreshIndicator(
        onRefresh: _onMatchesRefresh,
        displacement:
            _MatchesStickyHeaderDelegate.stickyHeaderHeight + TsSpacing.lg,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _MatchesStickyHeaderDelegate(
              canvasColor: c.canvas,
              activeSport: _tsSportFromProvider(sport),
              chipDates: chipDates,
              selectedDateIndex: selectedDateIndex,
              weekdayLabel: _weekdayLabel,
              isToday: _isToday,
              onSportChanged: _onSportChanged,
              onDateSelected: (index) => _onDateSelected(index, chipDates),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.lg)),
          if (!showingFixtureFailure) ...[
            SliverToBoxAdapter(
              child: _buildFilterRow(
                sport: sport,
                leagues: leagues,
                selectedLeague: selectedLeague,
                liveFilter: liveFilter,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.md)),
          ],
          ...groupsAsync.when(
            loading: () => [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: _wrapListDateSwipe(
                    selectedDateIndex: selectedDateIndex,
                    chipDates: chipDates,
                    child: _buildSkeletonGroups(),
                  ),
                ),
              ),
            ],
            error: (_, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: _wrapListDateSwipe(
                  selectedDateIndex: selectedDateIndex,
                  chipDates: chipDates,
                  child: Center(
                    child: TsEmptyState(
                      type: TsEmptyType.failure,
                      title: 'Could not load matches',
                      description: 'Check your connection and try again.',
                      actionLabel: 'Retry',
                      onAction: () => _retryFixtureLoad(sport),
                    ),
                  ),
                ),
              ),
            ],
            data: (groups) {
              if (groups.isEmpty) {
                if (sport == 'baseball' && _baseballLoadFailed) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _wrapListDateSwipe(
                        selectedDateIndex: selectedDateIndex,
                        chipDates: chipDates,
                        child: Center(
                          child: TsEmptyState(
                            type: TsEmptyType.failure,
                            title: 'Could not load matches',
                            description: 'Check your connection and try again.',
                            actionLabel: 'Retry',
                            onAction: () => _retryFixtureLoad(sport),
                          ),
                        ),
                      ),
                    ),
                  ];
                }

                if (liveFilter) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _wrapListDateSwipe(
                        selectedDateIndex: selectedDateIndex,
                        chipDates: chipDates,
                        child: Center(
                          child: TsEmptyState(
                            type: TsEmptyType.withAction,
                            title: 'No live matches',
                            description: 'No matches are in progress right now.',
                            actionLabel: 'Browse all matches',
                            onAction: _onSelectAll,
                          ),
                        ),
                      ),
                    ),
                  ];
                }

                final selectedDate = chipDates[selectedDateIndex];
                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _wrapListDateSwipe(
                      selectedDateIndex: selectedDateIndex,
                      chipDates: chipDates,
                      child: Center(
                        child: TsEmptyState(
                          type: TsEmptyType.withAction,
                          title: _emptyDateTitle(selectedDate),
                          description:
                              'Try another date from the strip above.',
                          actionLabel: 'View other dates',
                          onAction: _scrollToDateStrip,
                        ),
                      ),
                    ),
                  ),
                ];
              }
              return [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: _wrapListDateSwipe(
                      selectedDateIndex: selectedDateIndex,
                      chipDates: chipDates,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < groups.length; i++) ...[
                            _buildLeagueGroup(groups[i], c, sport),
                            if (i < groups.length - 1)
                              const SizedBox(height: TsSpacing.md),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.lg)),
        ],
        ),
      ),
    );
  }
}

/// Horizontal date swipe on the match-list region only — not the date strip or
/// filter row.
class _MatchesListDateSwipe extends StatelessWidget {
  const _MatchesListDateSwipe({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

class _MatchesLeagueFilterChip extends StatelessWidget {
  const _MatchesLeagueFilterChip({
    required this.leagueId,
    this.logoUrl,
    this.preferAsset = true,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String leagueId;
  final String? logoUrl;
  final bool preferAsset;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: TsRadius.full,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? c.primaryMuted : c.surfaceRaised,
            borderRadius: TsRadius.full,
            border: selected ? Border.all(color: c.primary, width: 1) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.md),
            child: SizedBox(
              height: TsSpacing.xxl,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TsLeagueIcon(
                    leagueId,
                    size: TsIconSize.xs,
                    logoUrl: logoUrl,
                    preferAsset: preferAsset,
                  ),
                  const SizedBox(width: TsSpacing.xs),
                  Text(
                    label,
                    style: (selected ? TsType.bodyMBold : TsType.bodyMMedium)
                        .copyWith(
                      color: selected ? c.primary : c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchesLeagueGroupHeader extends StatelessWidget {
  const _MatchesLeagueGroupHeader({
    required this.leagueId,
    this.logoUrl,
    this.preferAsset = true,
    required this.label,
    required this.hasAnalysis,
    required this.matchCount,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  final String leagueId;
  final String? logoUrl;
  final bool preferAsset;
  final String label;
  final bool hasAnalysis;
  final String matchCount;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return SizedBox(
      height: TsSpacing.xl,
      child: Row(
        children: [
          TsLeagueIcon(
            leagueId,
            size: TsIconSize.md,
            logoUrl: logoUrl,
            preferAsset: preferAsset,
          ),
          const SizedBox(width: TsSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TsType.bodyLBold.copyWith(color: c.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasAnalysis) ...[
            const TsBadge(label: 'AI', tone: TsBadgeTone.primary),
            const SizedBox(width: TsSpacing.sm),
          ],
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
            ),
            child: Text(
              matchCount,
              style: TsType.labelSRegular.copyWith(color: c.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: TsSpacing.sm),
          GestureDetector(
            onTap: onToggleCollapse,
            child: TsIcon(
              collapsed ? TsIcons.keyboardArrowDown : TsIcons.keyboardArrowUp,
              size: TsIconSize.sm,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class MatchesDateStrip extends StatelessWidget {
  const MatchesDateStrip({
    required this.chipDates,
    required this.selectedDateIndex,
    required this.weekdayLabel,
    required this.isToday,
    required this.onDateSelected,
    super.key,
  });

  static const minChipWidth = 44.0;
  static const gap = TsSpacing.xs;
  static const hPadding = TsSpacing.lg;

  static double fillThreshold(int chipCount) =>
      chipCount * minChipWidth + (chipCount - 1) * gap + hPadding * 2;

  final List<DateTime> chipDates;
  final int selectedDateIndex;
  final String Function(DateTime date) weekdayLabel;
  final bool Function(DateTime date) isToday;
  final ValueChanged<int> onDateSelected;

  Widget _dateChip(int index) {
    final date = chipDates[index];
    return TsDateChip(
      weekday: weekdayLabel(date),
      day: date.day.toString(),
      selected: index == selectedDateIndex,
      isToday: isToday(date),
      onTap: () => onDateSelected(index),
    );
  }

  List<Widget> _chipChildren({required bool scrollMode}) {
    return [
      for (var index = 0; index < chipDates.length; index++) ...[
        if (index > 0) const SizedBox(width: gap),
        if (scrollMode)
          SizedBox(width: minChipWidth, child: _dateChip(index))
        else
          Expanded(child: _dateChip(index)),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useFill =
              constraints.maxWidth >= fillThreshold(chipDates.length);

          if (useFill) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: hPadding),
              child: Row(children: _chipChildren(scrollMode: false)),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: hPadding),
            child: Row(children: _chipChildren(scrollMode: true)),
          );
        },
      ),
    );
  }
}

class _MatchesStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _MatchesStickyHeaderDelegate({
    required this.canvasColor,
    required this.activeSport,
    required this.chipDates,
    required this.selectedDateIndex,
    required this.weekdayLabel,
    required this.isToday,
    required this.onSportChanged,
    required this.onDateSelected,
  });

  static const double stickyHeaderHeight = 104;

  final Color canvasColor;
  final TsSport activeSport;
  final List<DateTime> chipDates;
  final int selectedDateIndex;
  final String Function(DateTime date) weekdayLabel;
  final bool Function(DateTime date) isToday;
  final ValueChanged<TsSport> onSportChanged;
  final ValueChanged<int> onDateSelected;

  @override
  double get minExtent => stickyHeaderHeight;

  @override
  double get maxExtent => stickyHeaderHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: canvasColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            child: SizedBox(
              height: 36,
              width: double.infinity,
              child: TsSportToggle(
                active: activeSport,
                onChanged: onSportChanged,
              ),
            ),
          ),
          const SizedBox(height: TsSpacing.md),
          MatchesDateStrip(
            chipDates: chipDates,
            selectedDateIndex: selectedDateIndex,
            weekdayLabel: weekdayLabel,
            isToday: isToday,
            onDateSelected: onDateSelected,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MatchesStickyHeaderDelegate oldDelegate) {
    return canvasColor != oldDelegate.canvasColor ||
        activeSport != oldDelegate.activeSport ||
        selectedDateIndex != oldDelegate.selectedDateIndex;
  }
}
