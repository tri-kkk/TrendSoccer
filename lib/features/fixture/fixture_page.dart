import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
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

class _FixturePageState extends ConsumerState<FixturePage> {
  static final _md = DateFormat('M.dd');
  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  static const _pageScrollPhysics = PageScrollPhysics(
    parent: ClampingScrollPhysics(),
  );
  static const _verticalScrollPhysics = AlwaysScrollableScrollPhysics(
    parent: ClampingScrollPhysics(),
  );

  static const _dateChipWidth = 72.0;
  static const _dateChipGap = 8.0;
  static const _dateChipHorizontalPadding = 16.0;

  final Set<String> _notificationMatchIds = {};
  late final PageController _pageController;
  final ScrollController _dateChipScrollController = ScrollController();
  bool _syncingPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _todayChipIndex());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollDateChipToIndex(_dateChipIndexForPage(_todayChipIndex()));
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dateChipScrollController.dispose();
    super.dispose();
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
      if (mounted) _syncingPage = false;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  SportType _selectedSport(String sport) =>
      sport == 'baseball' ? SportType.baseball : SportType.soccer;

  FixtureMatchStatus _toFixtureStatus(String status) {
    switch (status) {
      case 'live':
        return FixtureMatchStatus.live;
      case 'finished':
        return FixtureMatchStatus.finished;
      default:
        return FixtureMatchStatus.scheduled;
    }
  }

  String? _scoreText(FixtureMatch match, {required bool isHome}) {
    if (match.status == 'scheduled') return null;
    final score = isHome ? match.homeScore : match.awayScore;
    return score?.toString();
  }

  String? _statusTimeText(FixtureMatch match, {required bool isBaseball}) {
    switch (match.status) {
      case 'live':
        return null;
      case 'finished':
        return isBaseball ? 'Final' : 'FT';
      default:
        return fixtureMatchTimeKst(match);
    }
  }

  Widget _buildDateNavStrip() {
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
                    ? '오늘'
                    : _weekdays[chipDates[i].weekday - 1],
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
              label: '전체',
              isSelected: selectedLeague == null,
              type: TsFilterChipType.textOnly,
              onTap: () {
                ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
              },
            );
          }

          final league = leagues[index - 1];
          final displayName =
              fixtureDisplayLeagueName(league.name, league.code);

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

  List<Widget> _buildMatchWidgets(
    List<FixtureLeagueGroup> groups, {
    required bool isBaseball,
  }) {
    for (final group in groups) {
      print(
        '[FIXTURE] League group: ${group.leagueCode} '
        'name=${group.leagueName} logo=${group.leagueLogo ?? "NULL"}',
      );
    }

    return groups.asMap().entries.expand((entry) {
      final gi = entry.key;
      final group = entry.value;

      return [
        FixtureLeagueHeader(
          leagueName: group.leagueName,
          leagueCode: group.leagueCode,
          leagueLogoUrl: group.leagueLogo,
        ),
        const SizedBox(height: 8),
        FixtureMatchesCard(
          children: [
            for (final match in group.matches)
              FixtureMatchRow(
                status: _toFixtureStatus(match.status),
                timeText: _statusTimeText(match, isBaseball: isBaseball),
                homeTeam: match.homeTeam,
                awayTeam: match.awayTeam,
                homeLogoUrl: match.homeTeamLogo,
                awayLogoUrl: match.awayTeamLogo,
                homeScore: _scoreText(match, isHome: true),
                awayScore: _scoreText(match, isHome: false),
                isNotificationOn: _notificationMatchIds
                    .contains(match.matchId.toString()),
                onNotificationTap:
                    (match.status == 'scheduled' || match.status == 'live')
                        ? () {
                            setState(() {
                              final id = match.matchId.toString();
                              if (_notificationMatchIds.contains(id)) {
                                _notificationMatchIds.remove(id);
                              } else {
                                _notificationMatchIds.add(id);
                                showAlarmSheet(
                                  context,
                                  _selectedSport(match.sport),
                                );
                              }
                            });
                          }
                        : null,
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
                      title: '진행 중인 경기가 없습니다',
                      buttonLabel: '오늘 경기 확인하기',
                      onButtonPressed: _resetFromLiveEmpty,
                    )
                  : const TsEmptyState(
                      type: TsEmptyStateType.noData,
                      title: '경기가 없습니다',
                      subtitle: '선택한 날짜에 예정된 경기가 없습니다.',
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
  }) {
    if (groups.isEmpty) {
      return _buildEmptyDayState(isLiveFilter: false);
    }

    final matchWidgets = _buildMatchWidgets(groups, isBaseball: isBaseball);
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
  }) {
    final groups = _groupsForDate(
      matches: matches,
      dateStr: dateStr,
      selectedLeague: selectedLeague,
    );
    return _buildMatchScrollView(groups, isBaseball: isBaseball);
  }

  Widget _buildLiveMatchArea({
    required AsyncValue<List<FixtureLeagueGroup>> groupsAsync,
    required bool isBaseball,
    required TsSemanticColors semantic,
  }) {
    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '경기 일정을 불러오지 못했습니다.',
              style: TextStyle(color: semantic.textSecondary),
            ),
            const SizedBox(height: 16),
            TsButton(
              label: '다시 시도',
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
        return _buildMatchScrollView(groups, isBaseball: isBaseball);
      },
    );
  }

  Widget _buildDatePageView({
    required List<FixtureMatch> allMatches,
    required bool isBaseball,
    required String? selectedLeague,
    required List<DateTime> chipDates,
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
    final rawAsync = ref.watch(rawFixturesProvider);
    final chipDates = _chipDates();

    ref.listen(rawFixturesProvider, (previous, next) {
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasError && context.mounted) {
        TsToast.error(context, '경기 일정을 불러오지 못했습니다.');
      }
    });

    ref.listen(fixtureSelectedDateProvider, (previous, next) {
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
                  )
                : rawAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '경기 일정을 불러오지 못했습니다.',
                            style: TextStyle(color: semantic.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          TsButton(
                            label: '다시 시도',
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
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
