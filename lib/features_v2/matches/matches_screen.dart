import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/utils/league_supports_analysis.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
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
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';

/// Eight-day window aligned with soccer `daysBack=3` / `daysAhead=4`.
const _dateChipCount = 8;

/// Index of today within [_dateChipCount] chips (today − 3 … today + 4).
const _todayChipIndex = 3;

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

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  final Set<String> _collapsedLeagueCodes = {};
  final ScrollController _scrollController = ScrollController();
  late final List<DateTime> _chipDates;

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  int _selectedDateIndex(String selectedDateStr) {
    final index = _chipDates.indexWhere(
      (date) => fixtureDateString(date) == selectedDateStr,
    );
    return index < 0 ? _todayChipIndex : index;
  }

  TsSport _tsSportFromProvider(String sport) =>
      sport == 'baseball' ? TsSport.baseball : TsSport.soccer;

  void _resetFilterToAll() {
    ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    ref.read(fixtureLiveFilterProvider.notifier).state = false;
  }

  void _onSportChanged(TsSport sport) {
    ref.read(fixtureSelectedSportProvider.notifier).state =
        sport == TsSport.baseball ? 'baseball' : 'soccer';
    _resetFilterToAll();
    ref.read(fixtureSelectedDateProvider.notifier).state =
        fixtureTodayDateString();
    setState(_collapsedLeagueCodes.clear);
  }

  void _onDateSelected(int index) {
    if (index < 0 || index >= _chipDates.length) return;
    _resetFilterToAll();
    ref.read(fixtureSelectedDateProvider.notifier).state =
        fixtureDateString(_chipDates[index]);
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
    return switch (match.status) {
      'postponed' => const _MatchRowPresentation(
          status: TsMatchRowStatus.scheduled,
          timeLabel: 'Postponed',
        ),
      'cancelled' => const _MatchRowPresentation(
          status: TsMatchRowStatus.finished,
          timeLabel: 'Cancelled',
        ),
      'interrupted' => const _MatchRowPresentation(
          status: TsMatchRowStatus.live,
          timeLabel: 'Suspended',
        ),
      'live' => _MatchRowPresentation(
          status: TsMatchRowStatus.live,
          // Elapsed time comes from live polling in step 3b.
          timeLabel: match.matchTime,
        ),
      'finished' => _MatchRowPresentation(
          status: TsMatchRowStatus.finished,
          timeLabel: match.matchTime,
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
    required List<FixtureLeagueOption> leagues,
    required String? selectedLeague,
    required bool liveFilter,
  }) {
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
            logoUrl: league.logo,
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
            child: _MatchesLeagueGroupHeader(
              leagueId: leagueId,
              logoUrl: group.leagueLogo,
              label: _groupLeagueLabel(group, sport),
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

  Widget _buildMatchRow(FixtureMatch match) {
    final presentation = _matchRowPresentation(match);
    final showScores = presentation.status == TsMatchRowStatus.live ||
        presentation.status == TsMatchRowStatus.finished;

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
      hasAnalysis: leagueSupportsAnalysis(match.sport, match.leagueKey),
      alarmOn: null,
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

    ref.listen<List<FixtureLeagueOption>>(fixtureAvailableLeaguesProvider,
        (previous, next) {
      final selected = ref.read(fixtureSelectedLeagueProvider);
      if (selected == null) return;
      if (next.any((league) => league.code == selected)) return;
      ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    });

    final selectedDateIndex = _selectedDateIndex(selectedDateStr);

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: hideMonetisation ? TsAppBarType.homeMember : TsAppBarType.homeGuest,
        authLabel: 'Log in',
        onAuthTap: () => context.go('/login'),
        tierLabel: 'PREMIUM',
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _MatchesStickyHeaderDelegate(
              canvasColor: c.canvas,
              activeSport: _tsSportFromProvider(sport),
              chipDates: _chipDates,
              selectedDateIndex: selectedDateIndex,
              weekdayLabel: _weekdayLabel,
              isToday: _isToday,
              onSportChanged: _onSportChanged,
              onDateSelected: _onDateSelected,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.lg)),
          SliverToBoxAdapter(
            child: _buildFilterRow(
              leagues: leagues,
              selectedLeague: selectedLeague,
              liveFilter: liveFilter,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.md)),
          ...groupsAsync.when(
            loading: () => [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
                sliver: SliverToBoxAdapter(child: _buildSkeletonGroups()),
              ),
            ],
            error: (_, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: TsEmptyState(
                    type: TsEmptyType.failure,
                    title: 'Could not load matches',
                    description: 'Check your connection and try again.',
                    actionLabel: 'Retry',
                    onAction: () => invalidateFixtureData(ref),
                  ),
                ),
              ),
            ],
            data: (groups) {
              if (groups.isEmpty) {
                if (liveFilter) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
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
                  ];
                }

                final selectedDate = _chipDates[selectedDateIndex];
                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
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
                ];
              }
              return [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
                  sliver: SliverList.separated(
                    itemCount: groups.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: TsSpacing.md),
                    itemBuilder: (context, index) =>
                        _buildLeagueGroup(groups[index], c, sport),
                  ),
                ),
              ];
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.lg)),
        ],
      ),
    );
  }
}

class _MatchesLeagueFilterChip extends StatelessWidget {
  const _MatchesLeagueFilterChip({
    required this.leagueId,
    required this.logoUrl,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String leagueId;
  final String? logoUrl;
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
                    preferAsset: false,
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
    required this.logoUrl,
    required this.label,
    required this.matchCount,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  final String leagueId;
  final String? logoUrl;
  final String label;
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
            preferAsset: false,
          ),
          const SizedBox(width: TsSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TsType.bodyLBold.copyWith(color: c.textSecondary),
            ),
          ),
          Text(
            matchCount,
            style: TsType.labelSMedium.copyWith(color: c.textTertiary),
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
