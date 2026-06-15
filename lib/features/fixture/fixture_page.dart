import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/services/fixture_service.dart';
import 'package:trendsoccer/core/services/notification_service.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/baseball_status.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';
import 'package:trendsoccer/shared/widgets/fixture/alarm_sheet.dart';
import 'package:trendsoccer/shared/widgets/fixture/date_nav_chip.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_header.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_logo.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_match_row.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_matches_card.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_status.dart';
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
  static const _pageScrollPhysics = PageScrollPhysics(
    parent: ClampingScrollPhysics(),
  );
  static const _verticalScrollPhysics = AlwaysScrollableScrollPhysics(
    parent: ClampingScrollPhysics(),
  );

  static const _dateChipWidth = 72.0;
  static const _dateChipGap = 8.0;
  static const _dateChipHorizontalPadding = 16.0;

  final Set<String> _alarmEnabledMatchIds = {};
  int _alarmRefreshGeneration = 0;
  final Map<String, Map<String, dynamic>> _lastKnownSoccerLiveStates = {};
  final Map<String, DateTime> _soccerFinishedCacheAt = {};
  static const _soccerFinishedCacheTtl = Duration(minutes: 5);
  late final PageController _pageController;
  final ScrollController _dateChipScrollController = ScrollController();
  bool _syncingPage = false;
  bool _deepLinkApplied = false;
  Timer? _livePollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _todayChipIndex());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollDateChipToIndex(_dateChipIndexForPage(_todayChipIndex()));
      _startLivePolling();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLivePolling();
    _pageController.dispose();
    _dateChipScrollController.dispose();
    super.dispose();
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
      final base = polled ??
          ref.read(baseballFixturesProvider).asData?.value;
      if (base == null) {
        debugPrint(
          '[FIXTURE] Baseball poll: skipped merge (initial load not ready)',
        );
        return;
      }

      final merged =
          mergeBaseballTodayFixtures(base, dateMatches, selectedDate);
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

  bool _isHalftimeStatus(String? status) {
    if (status == null || status.isEmpty) return false;
    final normalized = status.trim().toUpperCase();
    return normalized == 'HT' || normalized.contains('HALFTIME');
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

  int _dateChipIndexForPage(int pageIndex) => pageIndex + 1;

  void _scrollDateChipToIndex(int chipIndex) {
    if (!_dateChipScrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_dateChipScrollController.hasClients) return;

      final screenWidth = MediaQuery.sizeOf(context).width;
      final targetOffset = _dateChipHorizontalPadding +
          (chipIndex * (_dateChipWidth + _dateChipGap)) -
          (screenWidth / 2) +
          (_dateChipWidth / 2);
      final clampedOffset = targetOffset.clamp(
        0.0,
        _dateChipScrollController.position.maxScrollExtent,
      );

      _dateChipScrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  List<DateTime> _chipDates() {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    return fixtureDateChipDates(todayDay);
  }

  int _todayChipIndex() => 2;

  int _dateIndexFor(String dateStr) {
    return _chipDates().indexWhere((date) => fixtureDateString(date) == dateStr);
  }

  void _onPageChanged(int index) {
    if (_syncingPage) return;

    final dateStr = fixtureDateString(_chipDates()[index]);
    ref.read(fixtureSelectedDateProvider.notifier).state = dateStr;
    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    ref.read(fixtureLiveFilterProvider.notifier).state = false;
    _scrollDateChipToIndex(_dateChipIndexForPage(index));
    _startLivePolling();
  }

  void _resetFixtureToTodayOnSportChange() {
    final todayPageIndex = _todayChipIndex();
    final todayChipIndex = _dateChipIndexForPage(todayPageIndex);

    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    ref.read(fixtureLiveFilterProvider.notifier).state = false;
    ref.read(fixtureSelectedDateProvider.notifier).state =
        fixtureTodayDateString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _syncingPage = true;
        _pageController.jumpToPage(todayPageIndex);
        _syncingPage = false;
      }
      _scrollDateChipToIndex(todayChipIndex);
    });
  }

  void _jumpToPageIndex(int index) {
    if (!_pageController.hasClients) return;
    _syncingPage = true;
    _pageController.jumpToPage(index);
    _syncingPage = false;
  }

  void _selectDateAtIndex(int index) {
    if (index < 0 || index >= _chipDates().length) return;

    _syncingPage = true;
    ref.read(fixtureLiveFilterProvider.notifier).state = false;
    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    ref.read(fixtureSelectedDateProvider.notifier).state =
        fixtureDateString(_chipDates()[index]);

    if (!_pageController.hasClients) {
      _syncingPage = false;
      return;
    }

    _pageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
      if (mounted) {
        _syncingPage = false;
        _startLivePolling();
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

    final sport = _sportApiValue(match.sport);
    await showAlarmSheet(
      context,
      matchId: match.matchId,
      sport: sport,
      onEnabledChanged: (enabled) {
        setState(() {
          final id = match.matchId.toString();
          if (enabled) {
            _alarmEnabledMatchIds.add(id);
          } else {
            _alarmEnabledMatchIds.remove(id);
          }
        });
      },
    );
  }

  FixtureMatchStatus _toFixtureStatus(
    FixtureMatch match, {
    required bool isBaseball,
  }) {
    if (isBaseball) {
      return _baseballFixtureStatus(match);
    }
    switch (match.status) {
      case 'live':
        return FixtureMatchStatus.live;
      case 'finished':
        return FixtureMatchStatus.finished;
      case 'postponed':
        return FixtureMatchStatus.postponed;
      case 'cancelled':
        return FixtureMatchStatus.cancelled;
      case 'interrupted':
        return FixtureMatchStatus.interrupted;
      default:
        return FixtureMatchStatus.scheduled;
    }
  }

  FixtureMatchStatus _baseballFixtureStatus(FixtureMatch match) {
    if (BaseballStatus.isInterrupted(match.rawStatus)) {
      return FixtureMatchStatus.interrupted;
    }
    if (BaseballStatus.isCancelled(match.rawStatus) ||
        match.status == 'cancelled') {
      return FixtureMatchStatus.cancelled;
    }
    if (BaseballStatus.isPostponed(match.rawStatus) ||
        match.status == 'postponed') {
      return FixtureMatchStatus.postponed;
    }
    if (BaseballStatus.isLive(match.rawStatus)) {
      return FixtureMatchStatus.live;
    }
    switch (match.status) {
      case 'finished':
        return FixtureMatchStatus.finished;
      case 'postponed':
        return FixtureMatchStatus.postponed;
      case 'cancelled':
        return FixtureMatchStatus.cancelled;
      case 'interrupted':
        return FixtureMatchStatus.interrupted;
      default:
        return FixtureMatchStatus.scheduled;
    }
  }

  String? _scoreText(
    FixtureMatch match, {
    required bool isHome,
    required bool isBaseball,
  }) {
    if (isBaseball) {
      if (match.status == 'scheduled' ||
          match.status == 'postponed' ||
          match.status == 'cancelled') {
        return null;
      }
    } else if (match.status == 'scheduled') {
      return null;
    }
    final score = isHome ? match.homeScore : match.awayScore;
    return score?.toString();
  }

  String? _statusTimeText(
    FixtureMatch match, {
    required bool isBaseball,
    required AppLocalizations l10n,
    LiveMatchData? live,
  }) {
    if (isBaseball) {
      return _baseballStatusTimeText(match, l10n);
    }
    if (live != null && _isHalftimeStatus(live.status)) {
      return 'HT';
    }
    if (_isHalftimeStatus(match.rawStatus)) {
      return 'HT';
    }
    if (live != null && live.isLive) {
      return l10n.liveMinutes(live.elapsed);
    }
    if (live != null && live.isFinished) {
      return l10n.fixtureStatusFinal;
    }
    switch (match.status) {
      case 'live':
        if (_isHalftimeStatus(match.rawStatus) ||
            (live != null && _isHalftimeStatus(live.status))) {
          return 'HT';
        }
        return live != null && live.elapsed > 0
            ? l10n.liveMinutes(live.elapsed)
            : l10n.fixtureLive;
      case 'finished':
        return l10n.fixtureStatusFinal;
      case 'postponed':
        return l10n.matchPostponed;
      case 'cancelled':
        return l10n.matchCancelled;
      case 'interrupted':
        return l10n.fixtureInterrupted;
      default:
        return fixtureMatchTimeKst(match);
    }
  }

  String? _baseballStatusTimeText(
    FixtureMatch match,
    AppLocalizations l10n,
  ) {
    if (match.status == 'postponed' ||
        BaseballStatus.isPostponed(match.rawStatus)) {
      return l10n.matchPostponed;
    }
    if (match.status == 'cancelled' ||
        BaseballStatus.isCancelled(match.rawStatus)) {
      return l10n.matchCancelled;
    }
    if (BaseballStatus.isInterrupted(match.rawStatus)) {
      return l10n.fixtureInterrupted;
    }

    if (BaseballStatus.isScheduled(match.rawStatus) ||
        match.status == 'scheduled') {
      return fixtureMatchTimeKst(match);
    }

    if (match.status == 'finished' || BaseballStatus.isFinished(match.rawStatus)) {
      return l10n.fixtureStatusFinal;
    }

    if (BaseballStatus.isLive(match.rawStatus)) {
      final display = _localizeBaseballStatusCode(
        BaseballStatus.displayStatus(match.rawStatus),
        l10n,
      );
      if (display.isNotEmpty) return display;
      return l10n.fixtureLive;
    }

    return _localizeBaseballStatusCode(
      BaseballStatus.displayStatus(match.rawStatus),
      l10n,
    );
  }

  String _localizeBaseballStatusCode(String code, AppLocalizations l10n) {
    if (code.isEmpty) return code;
    if (code == 'INT') return l10n.fixtureInterrupted;
    final topMatch = RegExp(r'^(\d+)T$').firstMatch(code);
    if (topMatch != null) {
      return l10n.baseballInningTop(int.parse(topMatch.group(1)!));
    }
    final bottomMatch = RegExp(r'^(\d+)B$').firstMatch(code);
    if (bottomMatch != null) {
      return l10n.baseballInningBottom(int.parse(bottomMatch.group(1)!));
    }
    return code;
  }

  Widget _buildDateNavStrip() {
    final l10n = context.l10n;
    final weekdays = _weekdayLabels(l10n);
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final selectedDateStr = ref.watch(fixtureSelectedDateProvider);
    final isLiveFilter = ref.watch(fixtureLiveFilterProvider);
    final chipDates = _chipDates();

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        controller: _dateChipScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DateNavChip(
              type: DateNavChipType.live,
              isActive: isLiveFilter,
              onTap: () {
                ref.read(fixtureLiveFilterProvider.notifier).state = true;
                ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
              },
            ),
            const SizedBox(width: _dateChipGap),
            for (var i = 0; i < chipDates.length; i++) ...[
              if (i > 0) const SizedBox(width: _dateChipGap),
              DateNavChip(
                type: _isSameDay(chipDates[i], todayDay)
                    ? DateNavChipType.today
                    : DateNavChipType.date,
                dayLabel: _isSameDay(chipDates[i], todayDay)
                    ? l10n.today
                    : weekdays[chipDates[i].weekday - 1],
                dateLabel: _md.format(chipDates[i]),
                isActive: !isLiveFilter &&
                    selectedDateStr == fixtureDateString(chipDates[i]),
                onTap: () => _selectDateAtIndex(i),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueFilters(List<FixtureLeagueOption> leagues) {
    final selectedLeague = ref.watch(fixtureSelectedLeagueProvider);

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: leagues.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TsFilterChip(
              label: context.l10n.filterAll,
              isSelected: selectedLeague == null,
              type: TsFilterChipType.textOnly,
              onTap: () {
                ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
              },
            );
          }

          final league = leagues[index - 1];
          final locale = Localizations.localeOf(context).languageCode;
          final displayName = locale == 'en'
              ? (league.nameEn ?? league.name)
              : league.name;

          return TsFilterChip(
            label: displayName,
            isSelected: selectedLeague == league.code,
            type: TsFilterChipType.withIcon,
            iconWidget: FixtureLeagueLogo(
              leagueName: displayName,
              leagueCode: league.code,
              leagueLogoUrl: league.logo,
              size: 16,
            ),
            onTap: () {
              ref.read(fixtureSelectedLeagueProvider.notifier).state =
                  league.code;
            },
          );
        },
      ),
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

  List<Widget> _buildMatchWidgets(
    List<FixtureLeagueGroup> groups, {
    required bool isBaseball,
    required AppLocalizations l10n,
    Map<String, LiveMatchData> liveMap = const {},
  }) {
    return groups.asMap().entries.expand((entry) {
      final gi = entry.key;
      final group = entry.value;

      return [
        FixtureLeagueHeader(
          leagueName: group.leagueName,
          leagueNameEn: group.leagueNameEn,
          leagueCode: group.leagueCode,
          leagueLogoUrl: group.leagueLogo,
        ),
        const SizedBox(height: 8),
        FixtureMatchesCard(
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
        if (gi < groups.length - 1) const SizedBox(height: 16),
      ];
    }).toList();
  }

  List<FixtureLeagueGroup> _groupsForDate({
    required List<FixtureMatch> matches,
    required String dateStr,
    required String? selectedLeague,
  }) {
    var filtered =
        matches.where((match) => matchIsOnDate(match, dateStr)).toList();

    if (selectedLeague != null && selectedLeague.isNotEmpty) {
      filtered = filtered
          .where((match) => match.leagueKey == selectedLeague)
          .toList();
    }

    return groupMatchesByLeague(filtered);
  }

  Widget _buildEmptyDayState({required bool isLiveFilter}) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: _verticalScrollPhysics,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: isLiveFilter
                  ? TsEmptyState(
                      type: TsEmptyStateType.withAction,
                      title: l10n.fixtureLiveEmpty,
                      buttonLabel: l10n.fixtureLiveEmptyAction,
                      onButtonPressed: _resetFromLiveEmpty,
                    )
                  : TsEmptyState(
                      type: TsEmptyStateType.noData,
                      title: l10n.fixtureNoMatches,
                      subtitle: l10n.fixtureNoMatchesOnDate,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchScrollView(
    List<FixtureLeagueGroup> groups, {
    required bool isBaseball,
    required AppLocalizations l10n,
    Map<String, LiveMatchData> liveMap = const {},
  }) {
    if (groups.isEmpty) {
      return _buildEmptyDayState(isLiveFilter: false);
    }

    final matchWidgets = _buildMatchWidgets(
      groups,
      isBaseball: isBaseball,
      l10n: l10n,
      liveMap: liveMap,
    );
    return ListView(
      physics: _verticalScrollPhysics,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        ...matchWidgets,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDayPage({
    required String dateStr,
    required List<FixtureMatch> matches,
    required String? selectedLeague,
    required bool isBaseball,
    required AppLocalizations l10n,
    Map<String, LiveMatchData> liveMap = const {},
  }) {
    final groups = _groupsForDate(
      matches: matches,
      dateStr: dateStr,
      selectedLeague: selectedLeague,
    );
    return _buildMatchScrollView(
      groups,
      isBaseball: isBaseball,
      l10n: l10n,
      liveMap: liveMap,
    );
  }

  Widget _buildLiveMatchArea({
    required AsyncValue<List<FixtureLeagueGroup>> groupsAsync,
    required bool isBaseball,
    required TsSemanticColors semantic,
    Map<String, LiveMatchData> liveMap = const {},
  }) {
    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
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
              onPressed: () => invalidateFixtureData(ref),
            ),
          ],
        ),
      ),
      data: (groups) {
        if (groups.isEmpty) {
          return _buildEmptyDayState(isLiveFilter: true);
        }
        return _buildMatchScrollView(
          groups,
          isBaseball: isBaseball,
          l10n: context.l10n,
          liveMap: liveMap,
        );
      },
    );
  }

  Widget _buildDatePageView({
    required List<FixtureMatch> allMatches,
    required bool isBaseball,
    required String? selectedLeague,
    required List<DateTime> chipDates,
    required AppLocalizations l10n,
    Map<String, LiveMatchData> liveMap = const {},
  }) {
    return PageView.builder(
      controller: _pageController,
      dragStartBehavior: DragStartBehavior.down,
      physics: _pageScrollPhysics,
      itemCount: chipDates.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        return _buildDayPage(
          dateStr: fixtureDateString(chipDates[index]),
          matches: allMatches,
          selectedLeague: selectedLeague,
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
    final selectedLeague = ref.watch(fixtureSelectedLeagueProvider);
    final leagues = ref.watch(fixtureAvailableLeaguesProvider);
    final groupsAsync = ref.watch(fixtureLeagueGroupsProvider);
    final allMatchesAsync = ref.watch(allFixturesWithLiveProvider);
    final liveMap = ref.watch(liveMatchesProvider);
    final chipDates = _chipDates();

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

      if (_syncingPage || ref.read(fixtureLiveFilterProvider)) return;

      final index = _dateIndexFor(next);
      if (index < 0 || !_pageController.hasClients) return;

      final currentPage =
          _pageController.page?.round() ?? _pageController.initialPage;
      if (currentPage != index) {
        _jumpToPageIndex(index);
      }
    });

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SportsToggle(
                  selectedSport: selectedSport,
                  onChanged: (sport) {
                    ref.read(fixtureSelectedSportProvider.notifier).state =
                        sport == SportType.baseball ? 'baseball' : 'soccer';
                    _resetFixtureToTodayOnSportChange();
                    _startLivePolling();
                  },
                ),
                const SizedBox(height: 16),
                _buildDateNavStrip(),
                const SizedBox(height: 16),
                _buildLeagueFilters(leagues),
              ],
            ),
          ),
          Expanded(
            child: isLiveFilter
                ? _buildLiveMatchArea(
                    groupsAsync: groupsAsync,
                    isBaseball: isBaseball,
                    semantic: semantic,
                    liveMap: liveMap,
                  )
                : allMatchesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
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
                            onPressed: () => invalidateFixtureData(ref),
                          ),
                        ],
                      ),
                    ),
                    data: (matches) => _buildDatePageView(
                      allMatches: matches,
                      isBaseball: isBaseball,
                      selectedLeague: selectedLeague,
                      chipDates: chipDates,
                      l10n: context.l10n,
                      liveMap: liveMap,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
