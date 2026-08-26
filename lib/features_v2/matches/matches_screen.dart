import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/services/fixture_service.dart';
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

/// Eight-day window: today − 3 … today + 4 (both sports).
const _dateChipCount = 8;
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
  final Map<String, List<FixtureMatch>> _baseballDateCache = {};
  final Set<String> _baseballDateLoading = {};
  bool _baseballLoadFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureBaseballDateLoaded();
    });
    // TODO(data): date strip does not refresh across midnight yet; an
    // AppLifecycle resume hook (as home_screen uses for profile) is where
    // chip dates would be regenerated and selection adjusted.
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

  void _clearBaseballDateCache() {
    _baseballDateCache.clear();
    _baseballDateLoading.clear();
    clearBaseballFixtureLazyCache(ref);
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

    return [...byMatchId.values, ...withoutId]
      ..sort((a, b) => a.matchTimestamp.compareTo(b.matchTimestamp));
  }

  void _publishBaseballCache() {
    ref.read(baseballLazyFixturesProvider.notifier).state =
        _mergedBaseballCache();
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
  }) async {
    if (ref.read(fixtureSelectedSportProvider) != 'baseball') return;
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
      if (!background && mounted) {
        ref.read(baseballFixturesLoadingProvider.notifier).state = false;
      }
    }
  }

  void _retryFixtureLoad(String sport) {
    if (sport == 'baseball') {
      setState(() => _baseballLoadFailed = false);
      _clearBaseballDateCache();
    }
    invalidateFixtureData(ref);
    if (sport == 'baseball') {
      unawaited(_loadBaseballDate(ref.read(fixtureSelectedDateProvider)));
    }
  }

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
  }

  void _onDateSelected(int index, List<DateTime> chipDates) {
    if (index < 0 || index >= chipDates.length) return;
    _resetFilterToAll();
    final dateStr = fixtureDateString(chipDates[index]);
    ref.read(fixtureSelectedDateProvider.notifier).state = dateStr;
    if (ref.read(fixtureSelectedSportProvider) == 'baseball') {
      unawaited(_loadBaseballDate(dateStr));
    }
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
              logoUrl: preferBundledIcon ? null : group.leagueLogo,
              preferAsset: preferBundledIcon,
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
    final chipDates = _chipDates();

    ref.listen<List<FixtureLeagueOption>>(fixtureAvailableLeaguesProvider,
        (previous, next) {
      final selected = ref.read(fixtureSelectedLeagueProvider);
      if (selected == null) return;
      if (next.any((league) => league.code == selected)) return;
      ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
    });

    final selectedDateIndex = _selectedDateIndex(selectedDateStr, chipDates);

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
              chipDates: chipDates,
              selectedDateIndex: selectedDateIndex,
              weekdayLabel: _weekdayLabel,
              isToday: _isToday,
              onSportChanged: _onSportChanged,
              onDateSelected: (index) => _onDateSelected(index, chipDates),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: TsSpacing.lg)),
          SliverToBoxAdapter(
            child: _buildFilterRow(
              sport: sport,
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
                    onAction: () => _retryFixtureLoad(sport),
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
                  ];
                }

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

                final selectedDate = chipDates[selectedDateIndex];
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
    required this.matchCount,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  final String leagueId;
  final String? logoUrl;
  final bool preferAsset;
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
            preferAsset: preferAsset,
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
