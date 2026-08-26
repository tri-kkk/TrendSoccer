import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_chip.dart';
import 'package:trendsoccer/design_system/widgets/ts_date_chip.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_league_filter_chip.dart';
import 'package:trendsoccer/design_system/widgets/ts_league_group_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';

/// Eight-day window aligned with soccer `daysBack=3` / `daysAhead=4`.
const _dateChipCount = 8;

/// Index of today within [_dateChipCount] chips (today − 3 … today + 4).
const _todayChipIndex = 3;

class _LeagueFilterOption {
  const _LeagueFilterOption({required this.code, required this.label});

  final String code;
  final String label;
}

class _SampleMatch {
  const _SampleMatch({
    required this.homeTeam,
    required this.awayTeam,
    required this.timeLabel,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.hasAnalysis = false,
  });

  final String homeTeam;
  final String awayTeam;
  final String timeLabel;
  final TsMatchRowStatus status;
  final String? homeScore;
  final String? awayScore;
  final bool hasAnalysis;
}

class _SampleLeagueGroup {
  const _SampleLeagueGroup({
    required this.leagueId,
    required this.label,
    required this.matches,
  });

  final String leagueId;
  final String label;
  final List<_SampleMatch> matches;
}

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  TsSport _activeSport = TsSport.soccer;
  int _selectedDateIndex = _todayChipIndex;
  String? _selectedLeague;
  bool _liveFilter = false;
  final Set<String> _collapsedLeagueCodes = {};
  late final List<DateTime> _chipDates;

  static const _soccerLeagueFilters = [
    _LeagueFilterOption(code: 'PL', label: 'Premier League'),
    _LeagueFilterOption(code: 'PD', label: 'LaLiga'),
    _LeagueFilterOption(code: 'SA', label: 'Serie A'),
    _LeagueFilterOption(code: 'BL1', label: 'Bundesliga'),
  ];

  static const _baseballLeagueFilters = [
    _LeagueFilterOption(code: 'MLB', label: 'MLB'),
    _LeagueFilterOption(code: 'KBO', label: 'KBO'),
    _LeagueFilterOption(code: 'NPB', label: 'NPB'),
    _LeagueFilterOption(code: 'CPBL', label: 'CPBL'),
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    _chipDates = List.generate(
      _dateChipCount,
      (index) => todayDay.add(Duration(days: index - _todayChipIndex)),
    );
    // TODO(data): date strip does not refresh across midnight yet; an
    // AppLifecycle resume hook (as home_screen uses for profile) is where
    // _chipDates would be regenerated and selection adjusted.
  }

  List<_LeagueFilterOption> get _leagueFilters =>
      _activeSport == TsSport.soccer
          ? _soccerLeagueFilters
          : _baseballLeagueFilters;

  List<_SampleLeagueGroup> get _activeGroups =>
      _activeSport == TsSport.soccer ? _soccerGroups : _baseballGroups;

  List<_SampleLeagueGroup> _filteredGroups() {
    final source = _activeGroups;

    if (_liveFilter) {
      return source
          .map(
            (group) => _SampleLeagueGroup(
              leagueId: group.leagueId,
              label: group.label,
              matches: group.matches
                  .where((match) => match.status == TsMatchRowStatus.live)
                  .toList(),
            ),
          )
          .where((group) => group.matches.isNotEmpty)
          .toList();
    }

    if (_selectedLeague != null) {
      return source.where((group) => group.leagueId == _selectedLeague).toList();
    }

    return source;
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

  void _resetFilterToAll() {
    _selectedLeague = null;
    _liveFilter = false;
  }

  void _onSportChanged(TsSport sport) {
    setState(() {
      _activeSport = sport;
      _resetFilterToAll();
      _collapsedLeagueCodes.clear();
    });
    // TODO(data): drive fixture sport selection and data fetch (soccer vs baseball).
  }

  void _onDateSelected(int index) {
    setState(() => _selectedDateIndex = index);
    // TODO(data): drive fixture selected date, fixture fetch, and alarm refresh.
  }

  void _onSelectAll() {
    setState(_resetFilterToAll);
  }

  void _onSelectLive() {
    setState(() {
      _selectedLeague = null;
      _liveFilter = true;
    });
  }

  void _onSelectLeague(String code) {
    setState(() {
      _liveFilter = false;
      _selectedLeague = code;
    });
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

  Widget _buildFilterRow() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: _leagueFilters.length + 2,
        separatorBuilder: (_, _) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TsChip(
              label: 'All',
              selected: _selectedLeague == null && !_liveFilter,
              onTap: _onSelectAll,
            );
          }
          if (index == 1) {
            return TsChip(
              label: 'LIVE',
              selected: _liveFilter,
              tone: TsChipTone.live,
              onTap: _onSelectLive,
            );
          }

          final league = _leagueFilters[index - 2];
          return TsLeagueFilterChip(
            leagueId: league.code,
            label: league.label,
            selected: _selectedLeague == league.code && !_liveFilter,
            onTap: () => _onSelectLeague(league.code),
          );
        },
      ),
    );
  }

  Widget _buildLeagueGroup(_SampleLeagueGroup group, TsThemeColors c) {
    final collapsed = _collapsedLeagueCodes.contains(group.leagueId);

    return Container(
      width: 380,
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
            child: TsLeagueGroupHeader(
              leagueId: group.leagueId,
              label: group.label,
              matchCount: group.matches.length.toString(),
              collapsed: collapsed,
              onToggleCollapse: () => _toggleCollapse(group.leagueId),
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
                      children: [
                        for (var i = 0; i < group.matches.length; i++) ...[
                          SizedBox(
                            width: 356,
                            child: _buildMatchRow(group.matches[i]),
                          ),
                          if (i < group.matches.length - 1)
                            const SizedBox(height: TsSpacing.md),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchRow(_SampleMatch match) {
    return TsMatchRow(
      homeTeam: match.homeTeam,
      awayTeam: match.awayTeam,
      timeLabel: match.timeLabel,
      status: match.status,
      homeScore: match.homeScore,
      awayScore: match.awayScore,
      hasAnalysis: match.hasAnalysis,
      alarmOn: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final auth = ref.watch(authProvider);
    // Trial users already have access: member app bar, no upsell, no ads.
    final hideMonetisation = auth.isPremium || auth.isTrial;
    final filteredGroups = _filteredGroups();

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: hideMonetisation ? TsAppBarType.homeMember : TsAppBarType.homeGuest,
        authLabel: 'Log in',
        onAuthTap: () => context.go('/login'),
        tierLabel: 'PREMIUM',
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _MatchesStickyHeaderDelegate(
              canvasColor: c.canvas,
              activeSport: _activeSport,
              chipDates: _chipDates,
              selectedDateIndex: _selectedDateIndex,
              weekdayLabel: _weekdayLabel,
              isToday: _isToday,
              onSportChanged: _onSportChanged,
              onDateSelected: _onDateSelected,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.lg)),
          SliverToBoxAdapter(child: _buildFilterRow()),
          const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.md)),
          if (filteredGroups.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: TsEmptyState(
                  type: TsEmptyType.withAction,
                  title: 'No matches on this date',
                  description: 'Try another date',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
              sliver: SliverList.separated(
                itemCount: filteredGroups.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: TsSpacing.md),
                itemBuilder: (context, index) =>
                    _buildLeagueGroup(filteredGroups[index], c),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.lg)),
        ],
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

  static const double _height = 104;

  final Color canvasColor;
  final TsSport activeSport;
  final List<DateTime> chipDates;
  final int selectedDateIndex;
  final String Function(DateTime date) weekdayLabel;
  final bool Function(DateTime date) isToday;
  final ValueChanged<TsSport> onSportChanged;
  final ValueChanged<int> onDateSelected;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

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
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
              itemCount: chipDates.length,
              separatorBuilder: (_, _) => const SizedBox(width: TsSpacing.sm),
              itemBuilder: (context, index) {
                final date = chipDates[index];
                return SizedBox(
                  width: 47,
                  child: TsDateChip(
                    weekday: weekdayLabel(date),
                    day: date.day.toString(),
                    selected: index == selectedDateIndex,
                    isToday: isToday(date),
                    onTap: () => onDateSelected(index),
                  ),
                );
              },
            ),
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

// TODO(data): replace with soccerFixturesProvider / fixtureLeagueGroupsProvider.
const _soccerGroups = [
  _SampleLeagueGroup(
    leagueId: 'PL',
    label: 'Premier League',
    matches: [
      _SampleMatch(
        homeTeam: 'Arsenal',
        awayTeam: 'Chelsea',
        timeLabel: '15:00',
        status: TsMatchRowStatus.scheduled,
        hasAnalysis: true,
      ),
      _SampleMatch(
        homeTeam: 'Liverpool',
        awayTeam: 'Man City',
        timeLabel: "67'",
        status: TsMatchRowStatus.live,
        homeScore: '2',
        awayScore: '1',
      ),
      _SampleMatch(
        homeTeam: 'Tottenham',
        awayTeam: 'Newcastle',
        timeLabel: 'FT',
        status: TsMatchRowStatus.finished,
        homeScore: '3',
        awayScore: '0',
      ),
    ],
  ),
  _SampleLeagueGroup(
    leagueId: 'PD',
    label: 'LaLiga',
    matches: [
      _SampleMatch(
        homeTeam: 'Barcelona',
        awayTeam: 'Sevilla',
        timeLabel: '18:30',
        status: TsMatchRowStatus.scheduled,
      ),
      _SampleMatch(
        homeTeam: 'Real Madrid',
        awayTeam: 'Valencia',
        timeLabel: "52'",
        status: TsMatchRowStatus.live,
        homeScore: '1',
        awayScore: '1',
        hasAnalysis: true,
      ),
    ],
  ),
  _SampleLeagueGroup(
    leagueId: 'SA',
    label: 'Serie A',
    matches: [
      _SampleMatch(
        homeTeam: 'Inter',
        awayTeam: 'Milan',
        timeLabel: 'FT',
        status: TsMatchRowStatus.finished,
        homeScore: '2',
        awayScore: '2',
      ),
      _SampleMatch(
        homeTeam: 'Juventus',
        awayTeam: 'Napoli',
        timeLabel: '20:45',
        status: TsMatchRowStatus.scheduled,
      ),
    ],
  ),
];

// TODO(data): replace with baseballFixturesProvider / fixtureLeagueGroupsProvider.
const _baseballGroups = [
  _SampleLeagueGroup(
    leagueId: 'MLB',
    label: 'MLB',
    matches: [
      _SampleMatch(
        homeTeam: 'Yankees',
        awayTeam: 'Red Sox',
        timeLabel: '19:05',
        status: TsMatchRowStatus.scheduled,
      ),
      _SampleMatch(
        homeTeam: 'Dodgers',
        awayTeam: 'Giants',
        timeLabel: 'Bot 7',
        status: TsMatchRowStatus.live,
        homeScore: '4',
        awayScore: '3',
        hasAnalysis: true,
      ),
      _SampleMatch(
        homeTeam: 'Cubs',
        awayTeam: 'Cardinals',
        timeLabel: 'Final',
        status: TsMatchRowStatus.finished,
        homeScore: '5',
        awayScore: '2',
      ),
    ],
  ),
  _SampleLeagueGroup(
    leagueId: 'KBO',
    label: 'KBO',
    matches: [
      _SampleMatch(
        homeTeam: 'LG Twins',
        awayTeam: 'Doosan Bears',
        timeLabel: '18:30',
        status: TsMatchRowStatus.scheduled,
      ),
      _SampleMatch(
        homeTeam: 'Samsung Lions',
        awayTeam: 'Kiwoom Heroes',
        timeLabel: 'Top 5',
        status: TsMatchRowStatus.live,
        homeScore: '2',
        awayScore: '0',
      ),
    ],
  ),
  _SampleLeagueGroup(
    leagueId: 'NPB',
    label: 'NPB',
    matches: [
      _SampleMatch(
        homeTeam: 'Giants',
        awayTeam: 'Tigers',
        timeLabel: 'Final',
        status: TsMatchRowStatus.finished,
        homeScore: '1',
        awayScore: '4',
      ),
      _SampleMatch(
        homeTeam: 'Swallows',
        awayTeam: 'Dragons',
        timeLabel: '14:00',
        status: TsMatchRowStatus.scheduled,
      ),
    ],
  ),
];
