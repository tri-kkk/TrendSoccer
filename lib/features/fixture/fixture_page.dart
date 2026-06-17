import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/constants/alarm_preference_keys.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/fixture_service.dart';
import 'package:trendsoccer/core/services/notification_service.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/baseball_status.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/features/fixture/fixture_baseball_content.dart';
import 'package:trendsoccer/features/fixture/fixture_league_filters.dart';
import 'package:trendsoccer/features/fixture/fixture_soccer_content.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_shell_app_bar_content.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/fixture/alarm_sheet.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_header.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_match_row.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_matches_card.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_status.dart';
import 'package:trendsoccer/shared/widgets/navigation/date_tab_bar.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';
import 'package:trendsoccer/shared/widgets/toggle/sports_toggle.dart';

class FixturePage extends ConsumerStatefulWidget {
  const FixturePage({super.key});

  @override
  ConsumerState<FixturePage> createState() => _FixturePageState();
}

class _FixturePageState extends ConsumerState<FixturePage>
    with WidgetsBindingObserver {
  static final _md = DateFormat('M.dd');

  final Set<String> _alarmEnabledMatchIds = {};
  int _alarmRefreshGeneration = 0;
  final Map<String, Map<String, dynamic>> _lastKnownSoccerLiveStates = {};
  final Map<String, DateTime> _soccerFinishedCacheAt = {};
  static const _soccerFinishedCacheTtl = Duration(minutes: 5);
  final Map<String, List<FixtureMatch>> _baseballDateCache = {};
  final Set<String> _baseballDateLoading = {};
  final ScrollController _scrollController = ScrollController();
  final ScrollController _dateTabScrollController = ScrollController();
  double _dragStartX = 0;
  double _dragEndX = 0;
  bool _deepLinkApplied = false;
  Timer? _livePollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLivePolling();
      _ensureBaseballDateLoaded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLivePolling();
    _scrollController.dispose();
    _dateTabScrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyFixtureDeepLinkIfNeeded();
  }

  void _applyFixtureDeepLinkIfNeeded() {
    final params = GoRouterState.of(context).uri.queryParameters;
    final sportParam = params['sport'];
    final filterParam = params['filter'];

    final hasDeepLink = sportParam == 'soccer' ||
        sportParam == 'baseball' ||
        filterParam == 'live';
    if (!hasDeepLink) {
      _deepLinkApplied = false;
      return;
    }
    if (_deepLinkApplied) return;
    _deepLinkApplied = true;

    if (sportParam == 'soccer' || sportParam == 'baseball') {
      ref.read(fixtureSelectedSportProvider.notifier).state = sportParam!;
    }
    if (filterParam == 'live') {
      ref.read(fixtureLiveFilterProvider.notifier).state = true;
      ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    }

    _startLivePolling();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/fixture');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startLivePolling();
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopLivePolling();
    }
  }

  bool _isSoccerFinishedLiveStatus(String status) {
    final raw = status.trim().toUpperCase();
    return raw == 'FT' ||
        raw == 'AET' ||
        raw == 'PEN' ||
        normalizeMatchStatus(raw) == 'finished';
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
    var liveData = await service.getLiveMatches();
    if (!mounted) return;

    if (liveData.isEmpty) {
      debugPrint('[FIXTURE] Soccer live: empty response, retrying in 3s');
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      final retryData = await service.getLiveMatches();
      if (!mounted) return;
      if (retryData.isNotEmpty) {
        debugPrint('[FIXTURE] Soccer live retry: ${retryData.length} matches');
        liveData = retryData;
      } else {
        debugPrint('[FIXTURE] Soccer live retry: still empty');
      }
    }

    final effective = _effectiveSoccerLiveMap(liveData);
    if (liveData.isEmpty && effective.isNotEmpty) {
      debugPrint(
        '[FIXTURE] Soccer live: empty poll, using ${effective.length} cached states',
      );
    }

    ref.read(liveMatchesProvider.notifier).state = effective;

    if (effective.values.any((live) => live.isFinished)) {
      final base = ref.read(soccerPolledFixturesProvider) ??
          ref.read(soccerFixturesProvider).asData?.value;
      if (base != null) {
        ref.read(soccerPolledFixturesProvider.notifier).state =
            mergeSoccerFinishedFromLive(base, effective);
      }
    }
  }

  void _clearBaseballDateCache() {
    _baseballDateCache.clear();
    _baseballDateLoading.clear();
    clearBaseballFixtureLazyCache(ref);
  }

  void _onFixtureRefresh() {
    if (ref.read(fixtureSelectedSportProvider) == 'baseball') {
      _clearBaseballDateCache();
    }
    invalidateFixtureData(ref);
    if (ref.read(fixtureSelectedSportProvider) == 'baseball') {
      unawaited(_loadBaseballDate(ref.read(fixtureSelectedDateProvider)));
    }
  }

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

    final merged = [...byMatchId.values, ...withoutId]
      ..sort((a, b) => a.matchTimestamp.compareTo(b.matchTimestamp));
    return merged;
  }

  void _publishBaseballCache() {
    ref.read(baseballLazyFixturesProvider.notifier).state =
        _mergedBaseballCache();
  }

  void _ensureBaseballDateLoaded() {
    if (ref.read(fixtureSelectedSportProvider) != 'baseball') return;
    unawaited(_loadBaseballDate(ref.read(fixtureSelectedDateProvider)));
  }

  void _preloadAdjacentBaseballDates(String centerDate) {
    final chipDates = _chipDates().map(fixtureDateString).toList();
    final index = chipDates.indexOf(centerDate);
    if (index < 0) return;

    if (index > 0) {
      unawaited(_loadBaseballDate(chipDates[index - 1], background: true));
    }
    if (index < chipDates.length - 1) {
      unawaited(_loadBaseballDate(chipDates[index + 1], background: true));
    }
  }

  Future<void> _loadBaseballDate(
    String date, {
    bool background = false,
  }) async {
    if (_baseballDateCache.containsKey(date) ||
        _baseballDateLoading.contains(date)) {
      return;
    }

    _baseballDateLoading.add(date);
    if (!background) {
      ref.read(baseballFixturesLoadingProvider.notifier).state =
          _baseballDateCache.isEmpty;
    }

    try {
      final service = ref.read(fixtureServiceProvider);
      final matches = await service.getBaseballFixtures(date: date);
      if (!mounted) return;

      _baseballDateCache[date] = matches;
      _publishBaseballCache();

      if (!background) {
        _preloadAdjacentBaseballDates(date);
      }
    } catch (e) {
      debugPrint('[FIXTURE] Baseball date load failed ($date): $e');
    } finally {
      _baseballDateLoading.remove(date);
      if (!background && mounted) {
        ref.read(baseballFixturesLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _fetchBaseballNow() async {
    if (!mounted) return;
    if (ref.read(fixtureSelectedSportProvider) != 'baseball') return;

    final selectedDate = ref.read(fixtureSelectedDateProvider);
    debugPrint(
      '[FIXTURE] Baseball poll fetch: date=$selectedDate, '
      'timezone=${DateTime.now().timeZoneName}, '
      'utcOffset=${DateTime.now().timeZoneOffset}',
    );
    try {
      final service = ref.read(fixtureServiceProvider);
      final dateMatches = await service
          .getBaseballFixtures(date: selectedDate)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;

      debugPrint(
        '[FIXTURE] Baseball poll result: ${dateMatches.length} matches, '
        'statuses=${dateMatches.map((m) => m.status).toSet().toList()}',
      );
      if (dateMatches.isNotEmpty) {
        final match = dateMatches.first;
        debugPrint(
          '[FIXTURE] Poll match logo: '
          'home=${match.homeTeamLogo != null && match.homeTeamLogo!.isNotEmpty}, '
          'away=${match.awayTeamLogo != null && match.awayTeamLogo!.isNotEmpty}',
        );
      }

      final polled = ref.read(baseballPolledFixturesProvider);
      final List<FixtureMatch> base =
          polled ?? ref.read(baseballLazyFixturesProvider);
      if (base.isEmpty) {
        debugPrint(
          '[FIXTURE] Baseball poll: skipped merge (initial load not ready)',
        );
        return;
      }

      final merged =
          mergeBaseballTodayFixtures(base, dateMatches, selectedDate);
      _baseballDateCache[selectedDate] = dateMatches;
      _publishBaseballCache();
      debugPrint(
        '[FIXTURE] Merge: before=${base.where((m) => m.status == 'scheduled').length} NS, '
        'after=${merged.where((m) => m.status == 'scheduled').length} NS',
      );
      ref.read(baseballPolledFixturesProvider.notifier).state = merged;
    } catch (e) {
      debugPrint('[FIXTURE] Baseball poll error: $e');
    }
  }

  bool _shouldPollBaseball() {
    return ref.read(fixtureSelectedSportProvider) == 'baseball';
  }

  void _startLivePolling() {
    if (!mounted) return;

    _stopLivePolling();

    final sport = ref.read(fixtureSelectedSportProvider);
    final isToday =
        fixtureIsTodayDate(ref.read(fixtureSelectedDateProvider));
    if (sport == 'soccer') {
      unawaited(_fetchLiveNow());
      _livePollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        unawaited(_fetchLiveNow());
      });
      debugPrint(
        '[FIXTURE] startPolling: sport=soccer, isToday=$isToday, '
        'timerActive=${_livePollingTimer?.isActive}',
      );
      return;
    }

    if (_shouldPollBaseball()) {
      unawaited(_fetchBaseballNow());
      _livePollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        unawaited(_fetchBaseballNow());
      });
      debugPrint(
        '[FIXTURE] startPolling: sport=baseball, isToday=$isToday, '
        'timerActive=${_livePollingTimer?.isActive}',
      );
    } else {
      debugPrint(
        '[FIXTURE] startPolling: sport=baseball, isToday=$isToday, '
        'timerActive=false',
      );
    }
  }

  void _stopLivePolling() {
    _livePollingTimer?.cancel();
    _livePollingTimer = null;
  }

  int _todayChipIndex() => 2;

  List<DateTime> _chipDates() {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    return fixtureDateChipDates(todayDay);
  }

  void _resetFixtureToTodayOnSportChange() {
    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    ref.read(fixtureLiveFilterProvider.notifier).state = false;
    ref.read(fixtureSelectedDateProvider.notifier).state =
        fixtureTodayDateString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToTop();
      _ensureBaseballDateLoaded();
    });
  }

  void _selectDateAtIndex(int index) {
    if (index < 0 || index >= _chipDates().length) return;

    ref.read(fixtureLiveFilterProvider.notifier).state = false;
    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    ref.read(fixtureSelectedDateProvider.notifier).state =
        fixtureDateString(_chipDates()[index]);

    if (ref.read(fixtureSelectedSportProvider) == 'baseball') {
      unawaited(_loadBaseballDate(fixtureDateString(_chipDates()[index])));
    }

    _startLivePolling();
    _scrollToTop();
  }

  void _goToNextDate(int selectedIndex, int dateCount) {
    if (selectedIndex >= dateCount - 1) return;
    _selectDateAtIndex(selectedIndex + 1);
  }

  void _goToPreviousDate(int selectedIndex) {
    if (selectedIndex <= 0) return;
    _selectDateAtIndex(selectedIndex - 1);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTabItem> _buildDateItems({
    required List<DateTime> chipDates,
    required AppLocalizations l10n,
  }) {
    final weekdays = _weekdayLabels(l10n);
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    return [
      for (final date in chipDates)
        DateTabItem(
          dayLabel: _isSameDay(date, todayDay)
              ? l10n.today
              : weekdays[date.weekday - 1],
          dateLabel: _md.format(date),
          isToday: _isSameDay(date, todayDay),
        ),
    ];
  }

  int _selectedDateIndex({
    required List<DateTime> chipDates,
    required String selectedDateStr,
  }) {
    final index = chipDates.indexWhere(
      (date) => fixtureDateString(date) == selectedDateStr,
    );
    return index < 0 ? 0 : index;
  }

  List<String> _weekdayLabels(AppLocalizations l10n) => [
        l10n.weekdayMon,
        l10n.weekdayTue,
        l10n.weekdayWed,
        l10n.weekdayThu,
        l10n.weekdayFri,
        l10n.weekdaySat,
        l10n.weekdaySun,
      ];

  SportType _selectedSport(String sport) =>
      sport == 'baseball' ? SportType.baseball : SportType.soccer;

  String _sportApiValue(String sport) =>
      sport == 'baseball' ? 'baseball' : 'soccer';

  bool _isAlarmEligible(FixtureMatch match, {LiveMatchData? live}) {
    var status = match.status;
    var rawStatus = match.rawStatus;
    if (live != null) {
      rawStatus = live.status.trim().toUpperCase();
      status = normalizeMatchStatus(rawStatus);
    }

    if (status == 'scheduled' || status == 'live') return true;

    if (match.sport == 'baseball') {
      return BaseballStatus.isLive(rawStatus) ||
          BaseballStatus.isScheduled(rawStatus);
    }

    return live?.isLive ?? false;
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
    final sport = _sportApiValue(selectedSport);
    final eligible = _matchesForSelectedDate(allMatches, selectedDate)
        .where(
          (match) =>
              match.matchId != 0 &&
              match.sport == selectedSport &&
              _isAlarmEligible(match),
        )
        .toList();

    final matchIds = eligible.map((m) => m.matchId.toString()).toList();
    if (matchIds.isEmpty) {
      if (!mounted || generation != _alarmRefreshGeneration) return;
      setState(() {
        _alarmEnabledMatchIds.clear();
      });
      return;
    }

    final results = <String, dynamic>{};
    const chunkSize = 50;
    for (var i = 0; i < matchIds.length; i += chunkSize) {
      final chunk = matchIds.sublist(
        i,
        math.min(i + chunkSize, matchIds.length),
      );
      final chunkResult = await service.getMatchAlarmsBatch(
        matchIds: chunk,
        sport: sport,
      );
      results.addAll(chunkResult);
    }

    _checkAndResyncAlarms(results, sport);

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

  void _checkAndResyncAlarms(
    Map<String, dynamic> serverResults,
    String sport,
  ) {
    final prefs = ref.read(sharedPreferencesProvider);
    final localEvents = AlarmPreferenceKeys.globalEvents(prefs, sport);
    final service = ref.read(notificationServiceProvider);

    for (final entry in serverResults.entries) {
      final alarm = entry.value;
      if (alarm is! Map || alarm['enabled'] != true) continue;
      if (_alarmEventsMatchLocal(alarm['events'], localEvents)) continue;

      final matchId = int.tryParse(entry.key);
      if (matchId == null || matchId == 0) continue;

      unawaited(
        service.saveMatchAlarmSettings(
          matchId,
          sport,
          true,
          localEvents,
        ),
      );
    }
  }

  bool _alarmEventsMatchLocal(
    Object? serverEventsRaw,
    Map<String, bool> localEvents,
  ) {
    if (serverEventsRaw is! Map) return false;

    for (final entry in localEvents.entries) {
      final serverVal = serverEventsRaw[entry.key];
      if (serverVal is! bool || serverVal != entry.value) {
        return false;
      }
    }
    return true;
  }

  void _scheduleAlarmStateRefresh(
    List<FixtureMatch> matches, {
    Duration delay = Duration.zero,
    String? selectedDate,
  }) {
    final String date =
        selectedDate ?? ref.read(fixtureSelectedDateProvider);
    if (delay > Duration.zero) {
      Future<void>.delayed(delay, () {
        if (!mounted) return;
        unawaited(_refreshAlarmStatesForDate(matches, date));
      });
      return;
    }
    unawaited(_refreshAlarmStatesForDate(matches, date));
  }

  Future<void> _onNotificationTap(FixtureMatch match) async {
    if (!_isAlarmEligible(match)) return;
    if (!await ensureMatchAlarmGate(context)) return;
    if (!mounted) return;

    final sport = _sportApiValue(match.sport);
    final matchId = match.matchId;
    final id = matchId.toString();
    final isCurrentlyOn = _alarmEnabledMatchIds.contains(id);
    final service = ref.read(notificationServiceProvider);
    final prefs = ref.read(sharedPreferencesProvider);

    if (isCurrentlyOn) {
      final disabledEvents =
          AlarmPreferenceKeys.disabledEvents(prefs, sport);
      setState(() => _alarmEnabledMatchIds.remove(id));
      try {
        final ok = await service.saveMatchAlarmSettings(
          matchId,
          sport,
          false,
          disabledEvents,
        );
        debugPrint('[ALARM] Save response: matchId=$matchId, success=true');
        if (!ok && mounted) {
          setState(() => _alarmEnabledMatchIds.add(id));
          TsToast.error(context, context.l10n.errorUnauthorized);
        }
      } catch (e) {
        debugPrint('[ALARM] Save FAILED: matchId=$matchId, error=$e');
      }
      return;
    }

    final events = AlarmPreferenceKeys.globalEvents(prefs, sport);
    debugPrint(
      '[ALARM] Bell ON: matchId=$matchId, sport=$sport, events=$events',
    );
    setState(() => _alarmEnabledMatchIds.add(id));
    try {
      final ok = await service.saveMatchAlarmSettings(
        matchId,
        sport,
        true,
        events,
      );
      debugPrint('[ALARM] Save response: matchId=$matchId, success=true');
      if (!ok && mounted) {
        setState(() => _alarmEnabledMatchIds.remove(id));
        TsToast.error(context, context.l10n.errorUnauthorized);
      }
    } catch (e) {
      debugPrint('[ALARM] Save FAILED: matchId=$matchId, error=$e');
    }
  }

  FixtureMatchStatus _toFixtureStatus(
    FixtureMatch match, {
    required bool isBaseball,
  }) {
    if (isBaseball) {
      return FixtureBaseballContent.toFixtureStatus(match);
    }
    return FixtureSoccerContent.toFixtureStatus(match);
  }

  String? _scoreText(
    FixtureMatch match, {
    required bool isHome,
    required bool isBaseball,
  }) {
    if (isBaseball) {
      return FixtureBaseballContent.scoreText(match, isHome: isHome);
    }
    return FixtureSoccerContent.scoreText(match, isHome: isHome);
  }

  String? _statusTimeText(
    FixtureMatch match, {
    required bool isBaseball,
    required AppLocalizations l10n,
    LiveMatchData? live,
  }) {
    if (isBaseball) {
      return FixtureBaseballContent.statusTimeText(match, l10n);
    }
    return FixtureSoccerContent.statusTimeText(
      match,
      l10n: l10n,
      live: live,
    );
  }

  Widget _buildLeagueFilters(
    List<FixtureLeagueOption> leagues, {
    required bool isLiveFilter,
  }) {
    return FixtureLeagueFilters(
      leagues: leagues,
      selectedLeague: ref.watch(fixtureSelectedLeagueProvider),
      filterAllLabel: context.l10n.filterAll,
      liveLabel: context.l10n.fixtureLive,
      locale: Localizations.localeOf(context).languageCode,
      isLiveFilter: isLiveFilter,
      onSelectAll: () {
        ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
        ref.read(fixtureLiveFilterProvider.notifier).state = false;
      },
      onLiveTap: () {
        ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
        ref.read(fixtureLiveFilterProvider.notifier).state = true;
      },
      onSelectLeague: (code) {
        ref.read(fixtureLiveFilterProvider.notifier).state = false;
        ref.read(fixtureSelectedLeagueProvider.notifier).state = code;
      },
    );
  }

  FixtureMatch? _sourceSoccerFixture(FixtureMatch match) {
    final raw = ref.read(soccerFixturesProvider).asData?.value;
    if (raw == null) return null;
    for (final source in raw) {
      if (match.matchId != 0 && source.matchId == match.matchId) return source;
      final apiId = match.apiMatchId;
      final sourceApiId = source.apiMatchId;
      if (apiId != null && sourceApiId != null && apiId == sourceApiId) {
        return source;
      }
    }
    return null;
  }

  String? _displayTeamLogo(
    FixtureMatch match, {
    required bool isHome,
    required bool isBaseball,
  }) {
    final direct = isHome ? match.homeTeamLogo : match.awayTeamLogo;
    if (direct != null && direct.isNotEmpty) return direct;
    if (isBaseball) return direct;
    final source = _sourceSoccerFixture(match);
    if (source == null) return direct;
    return isHome ? source.homeTeamLogo : source.awayTeamLogo;
  }

  LiveMatchData? _liveDataForMatch(
    FixtureMatch match,
    Map<String, LiveMatchData> liveMap,
  ) {
    final byMatchId = liveMap[match.matchId.toString()];
    if (byMatchId != null) return byMatchId;
    final apiMatchId = match.apiMatchId;
    if (apiMatchId != null) return liveMap[apiMatchId.toString()];
    return null;
  }

  Widget _buildMatchRow(
    FixtureMatch match, {
    required bool isBaseball,
    required AppLocalizations l10n,
    LiveMatchData? live,
  }) {
    return FixtureMatchRow(
      status: _toFixtureStatus(match, isBaseball: isBaseball),
      timeText: _statusTimeText(
        match,
        isBaseball: isBaseball,
        l10n: l10n,
        live: live,
      ),
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
      homeLogoUrl: _displayTeamLogo(match, isHome: true, isBaseball: isBaseball),
      awayLogoUrl: _displayTeamLogo(match, isHome: false, isBaseball: isBaseball),
      homeScore: _scoreText(match, isHome: true, isBaseball: isBaseball),
      awayScore: _scoreText(match, isHome: false, isBaseball: isBaseball),
      isNotificationOn: _alarmEnabledMatchIds.contains(match.matchId.toString()),
      showNotification: _isAlarmEligible(match, live: live),
      onNotificationTap: _isAlarmEligible(match, live: live)
          ? () => _onNotificationTap(match)
          : null,
    );
  }

  Widget _emptyDayContent({required bool isLiveFilter}) {
    final l10n = context.l10n;
    if (isLiveFilter) {
      return TsEmptyState(
        type: TsEmptyStateType.withAction,
        title: l10n.fixtureNoLiveMatches,
        buttonLabel: l10n.fixtureLiveEmptyAction,
        onButtonPressed: _resetFromLiveEmpty,
      );
    }
    return TsEmptyState(
      type: TsEmptyStateType.noData,
      title: l10n.fixtureNoMatches,
      subtitle: l10n.fixtureNoMatchesOnDate,
    );
  }

  List<Widget> _groupsToSlivers(
    List<FixtureLeagueGroup> groups, {
    required bool isBaseball,
    required AppLocalizations l10n,
    Map<String, LiveMatchData> liveMap = const {},
  }) {
    final slivers = <Widget>[];
    for (var gi = 0; gi < groups.length; gi++) {
      final group = groups[gi];
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, gi == 0 ? 0 : 16, 16, 8),
            child: FixtureLeagueHeader(
              leagueName: group.leagueName,
              leagueNameEn: group.leagueNameEn,
              leagueCode: group.leagueCode,
              leagueLogoUrl: group.leagueLogo,
            ),
          ),
        ),
      );
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FixtureMatchesCard(
              children: [
                for (final match in group.matches)
                  _buildMatchRow(
                    match,
                    isBaseball: isBaseball,
                    l10n: l10n,
                    live: _liveDataForMatch(match, liveMap),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return slivers;
  }

  List<Widget> _buildFixtureContentSlivers({
    required AsyncValue<List<FixtureLeagueGroup>> groupsAsync,
    required bool isLiveFilter,
    required bool isBaseball,
    required AppLocalizations l10n,
    required TsSemanticColors semantic,
    Map<String, LiveMatchData> liveMap = const {},
  }) {
    return groupsAsync.when(
      loading: () => const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (error, stackTrace) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.fixtureLoadFailed,
                  style: TextStyle(color: semantic.textSecondary),
                ),
                const SizedBox(height: 16),
                TsButton(
                  label: context.l10n.retry,
                  variant: TsButtonVariant.primary,
                  size: TsButtonSize.small,
                  onPressed: _onFixtureRefresh,
                ),
              ],
            ),
          ),
        ),
      ],
      data: (groups) {
        if (groups.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: _emptyDayContent(isLiveFilter: isLiveFilter),
              ),
            ),
          ];
        }
        return _groupsToSlivers(
          groups,
          isBaseball: isBaseball,
          l10n: l10n,
          liveMap: liveMap,
        );
      },
    );
  }

  void _resetFromLiveEmpty() {
    ref.read(fixtureLiveFilterProvider.notifier).state = false;
    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    _selectDateAtIndex(_todayChipIndex());
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final selectedSportStr = ref.watch(fixtureSelectedSportProvider);
    final selectedSport = _selectedSport(selectedSportStr);
    final isBaseball = selectedSportStr == 'baseball';
    final isLiveFilter = ref.watch(fixtureLiveFilterProvider);
    final leagues = ref.watch(fixtureAvailableLeaguesProvider);
    final groupsAsync = ref.watch(fixtureLeagueGroupsProvider);
    final liveMap = ref.watch(liveMatchesProvider);

    ref.listen(rawFixturesProvider, (previous, next) {
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasError && context.mounted) {
        TsToast.error(context, context.l10n.fixtureLoadFailed);
      }
    });

    ref.listen(allFixturesWithLiveProvider, (previous, next) {
      next.whenData((matches) {
        _scheduleAlarmStateRefresh(
          matches,
          selectedDate: ref.read(fixtureSelectedDateProvider),
        );
      });
    });

    ref.listen(authProvider, (previous, next) {
      final wasLoggedIn = previous?.isLoggedIn ?? false;
      final isLoggedIn = next.isLoggedIn;

      // Logout: keep bell states in memory (device-level settings)
      if (wasLoggedIn && !isLoggedIn) return;

      final matches = ref.read(allFixturesWithLiveProvider).value;
      if (matches == null) return;

      // Login: delay refresh so migration can complete on the backend
      if (!wasLoggedIn && isLoggedIn) {
        _scheduleAlarmStateRefresh(
          matches,
          delay: const Duration(milliseconds: 500),
        );
        return;
      }

      _scheduleAlarmStateRefresh(matches);
    });

    ref.listen(fixtureSelectedDateProvider, (previous, next) {
      if (previous != next) {
        _startLivePolling();
        final matches = ref.read(allFixturesWithLiveProvider).value;
        if (matches != null) {
          _scheduleAlarmStateRefresh(matches, selectedDate: next);
        }
      }
    });

    final auth = ref.watch(authProvider);
    final l10n = context.l10n;
    final chipDates = _chipDates();
    final selectedDateStr = ref.watch(fixtureSelectedDateProvider);
    final dateItems = _buildDateItems(chipDates: chipDates, l10n: l10n);
    final selectedDateIndex = _selectedDateIndex(
      chipDates: chipDates,
      selectedDateStr: selectedDateStr,
    );

    return Scaffold(
      backgroundColor: semantic.surfaceRaised,
      body: GestureDetector(
        onHorizontalDragStart: (details) {
          _dragStartX = details.globalPosition.dx;
          _dragEndX = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          _dragEndX = details.globalPosition.dx;
        },
        onHorizontalDragEnd: (details) {
          final dx = _dragEndX - _dragStartX;
          final velocity = details.primaryVelocity;
          if (velocity == null && dx.abs() < 50) return;

          if ((velocity ?? 0) < -300 || dx < -50) {
            _goToNextDate(selectedDateIndex, chipDates.length);
          } else if ((velocity ?? 0) > 300 || dx > 50) {
            _goToPreviousDate(selectedDateIndex);
          }
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              toolbarHeight: TsShellAppBarMetrics.barHeight,
              backgroundColor: semantic.surfaceRaised,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: TsShellAppBarTitle(
                auth: auth,
                onLogoTap: () => context.go('/trend'),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(DateTabBar.barHeight),
                child: DateTabBar(
                  scrollController: _dateTabScrollController,
                  dates: dateItems,
                  selectedIndex: selectedDateIndex,
                  onDateSelected: _selectDateAtIndex,
                  fillWidth: false,
                  backgroundColor: semantic.surfaceRaised,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SportsToggle(
                  selectedSport: selectedSport,
                  onChanged: (sport) {
                    ref.read(fixtureSelectedSportProvider.notifier).state =
                        sport == SportType.baseball ? 'baseball' : 'soccer';
                    _resetFixtureToTodayOnSportChange();
                    _startLivePolling();
                    if (sport == SportType.baseball) {
                      _ensureBaseballDateLoaded();
                    }
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildLeagueFilters(
                  leagues,
                  isLiveFilter: isLiveFilter,
                ),
              ),
            ),
            ..._buildFixtureContentSlivers(
              groupsAsync: groupsAsync,
              isLiveFilter: isLiveFilter,
              isBaseball: isBaseball,
              l10n: l10n,
              semantic: semantic,
              liveMap: liveMap,
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: false,
              child: SizedBox.shrink(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 56),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 16),
            ),
          ],
        ),
      ),
    );
  }
}
