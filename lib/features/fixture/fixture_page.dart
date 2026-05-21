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

  final Set<String> _notificationMatchIds = {};

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
    final chipDates = fixtureDateChipDates(todayDay);

    final children = <Widget>[
      DateNavChip(
        type: DateNavChipType.live,
        isActive: isLiveFilter,
        onTap: () {
          ref.read(fixtureLiveFilterProvider.notifier).state = true;
          ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
        },
      ),
      const SizedBox(width: 8),
    ];

    for (final date in chipDates) {
      final dateStr = fixtureDateString(date);
      final isToday = _isSameDay(date, todayDay);
      final isActive = !isLiveFilter && selectedDateStr == dateStr;

      children.add(
        DateNavChip(
          type: isToday ? DateNavChipType.today : DateNavChipType.date,
          dayLabel: isToday ? '오늘' : _weekdays[date.weekday - 1],
          dateLabel: _md.format(date),
          isActive: isActive,
          onTap: () {
            ref.read(fixtureLiveFilterProvider.notifier).state = false;
            ref.read(fixtureSelectedDateProvider.notifier).state = dateStr;
            ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
          },
        ),
      );
      children.add(const SizedBox(width: 8));
    }

    if (children.isNotEmpty) {
      children.removeLast();
    }

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: children,
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

  void _resetFromLiveEmpty() {
    ref.read(fixtureLiveFilterProvider.notifier).state = false;
    ref.read(fixtureSelectedDateProvider.notifier).state =
        fixtureTodayDateString();
    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
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

    ref.listen(rawFixturesProvider, (previous, next) {
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasError && context.mounted) {
        TsToast.error(context, '경기 일정을 불러오지 못했습니다.');
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
                    ref.read(fixtureSelectedLeagueProvider.notifier).state =
                        null;
                    ref.read(fixtureLiveFilterProvider.notifier).state = false;
                    ref.read(fixtureSelectedDateProvider.notifier).state =
                        fixtureTodayDateString();
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
            child: groupsAsync.when(
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
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
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
                                    subtitle:
                                        '선택한 날짜에 예정된 경기가 없습니다.',
                                  ),
                          ),
                        ),
                      );
                    },
                  );
                }

                final matchWidgets =
                    _buildMatchWidgets(groups, isBaseball: isBaseball);
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...matchWidgets,
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
