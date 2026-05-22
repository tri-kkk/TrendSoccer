import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/sport_type.dart';

import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';

import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';

import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

import 'package:trendsoccer/features/analysis/analysis_dummy_data.dart';

import 'package:trendsoccer/features/analysis/widgets/baseball_matches_section.dart';

import 'package:trendsoccer/features/analysis/widgets/soccer_matches_section.dart';

import 'package:trendsoccer/shared/widgets/cards/baseball_today_combo_card.dart';

import 'package:trendsoccer/shared/widgets/cards/premium_pick_stats_card.dart';

import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';

import 'package:trendsoccer/shared/widgets/fixture/date_nav_chip.dart';

import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';

import 'package:trendsoccer/shared/widgets/toggle/sports_toggle.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  static final _md = DateFormat('M.dd');

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  static const _pageScrollPhysics = PageScrollPhysics(
    parent: ClampingScrollPhysics(),
  );

  static const _dateChipGap = 8.0;

  SportType _selectedSport = SportType.soccer;

  late final PageController _baseballPageController;
  late final PageController _soccerPageController;

  bool _syncingBaseballPage = false;
  bool _syncingSoccerPage = false;

  @override
  void initState() {
    super.initState();

    _baseballPageController = PageController(initialPage: 0);
    _soccerPageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _baseballPageController.dispose();
    _soccerPageController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final sportParam = GoRouterState.of(context).uri.queryParameters['sport'];

    if (sportParam == 'baseball' && _selectedSport != SportType.baseball) {
      setState(() => _selectedSport = SportType.baseball);

      _resetBaseballToToday();
    }
  }

  void _resetSoccerToToday() {
    ref.read(selectedLeagueProvider.notifier).state = null;
    ref.read(soccerAnalysisDateProvider.notifier).state =
        fixtureTodayDateString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_soccerPageController.hasClients) {
        _syncingSoccerPage = true;
        _soccerPageController.jumpToPage(0);
        _syncingSoccerPage = false;
      }
    });
  }

  void _resetBaseballToToday() {
    ref.read(selectedBaseballLeagueProvider.notifier).state = null;

    ref.read(baseballAnalysisDateProvider.notifier).state =
        baseballTodayDateString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_baseballPageController.hasClients) {
        _syncingBaseballPage = true;

        _baseballPageController.jumpToPage(0);

        _syncingBaseballPage = false;
      }
    });
  }

  void _onSoccerPageChanged(int index) {
    if (_syncingSoccerPage) return;

    final dates = ref.read(soccerAnalysisDatesProvider);
    if (index < 0 || index >= dates.length) return;

    ref.read(soccerAnalysisDateProvider.notifier).state = dates[index];
    ref.read(selectedLeagueProvider.notifier).state = null;
  }

  void _selectSoccerDateAtIndex(int index) {
    final dates = ref.read(soccerAnalysisDatesProvider);
    if (index < 0 || index >= dates.length) return;

    _syncingSoccerPage = true;
    ref.read(selectedLeagueProvider.notifier).state = null;
    ref.read(soccerAnalysisDateProvider.notifier).state = dates[index];

    if (!_soccerPageController.hasClients) {
      _syncingSoccerPage = false;
      return;
    }

    _soccerPageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
          if (mounted) _syncingSoccerPage = false;
        });
  }

  void _jumpSoccerToPageIndex(int index) {
    if (!_soccerPageController.hasClients) return;

    _syncingSoccerPage = true;
    _soccerPageController.jumpToPage(index);
    _syncingSoccerPage = false;
  }

  void _onBaseballPageChanged(int index) {
    if (_syncingBaseballPage) return;

    final dates = ref.read(baseballAnalysisDatesProvider);

    if (index < 0 || index >= dates.length) return;

    ref.read(baseballAnalysisDateProvider.notifier).state = dates[index];

    ref.read(selectedBaseballLeagueProvider.notifier).state = null;
  }

  void _selectBaseballDateAtIndex(int index) {
    final dates = ref.read(baseballAnalysisDatesProvider);

    if (index < 0 || index >= dates.length) return;

    _syncingBaseballPage = true;

    ref.read(selectedBaseballLeagueProvider.notifier).state = null;

    ref.read(baseballAnalysisDateProvider.notifier).state = dates[index];

    if (!_baseballPageController.hasClients) {
      _syncingBaseballPage = false;

      return;
    }

    _baseballPageController
        .animateToPage(
          index,

          duration: const Duration(milliseconds: 300),

          curve: Curves.easeInOut,
        )
        .whenComplete(() {
          if (mounted) _syncingBaseballPage = false;
        });
  }

  void _jumpBaseballToPageIndex(int index) {
    if (!_baseballPageController.hasClients) return;

    _syncingBaseballPage = true;

    _baseballPageController.jumpToPage(index);

    _syncingBaseballPage = false;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildSoccerFilterChips() {
    final selectedSoccerLeague = ref.watch(selectedLeagueProvider);

    return SizedBox(
      height: 32,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: soccerAnalysisLeagueChips.length,

        separatorBuilder: (_, _) => const SizedBox(width: 8),

        itemBuilder: (context, index) {
          final chip = soccerAnalysisLeagueChips[index];

          final isSelected = chip.isAll
              ? selectedSoccerLeague == null
              : selectedSoccerLeague == chip.id;

          return TsFilterChip(
            label: chip.displayLabel,

            isSelected: isSelected,

            type: chip.iconId != null
                ? TsFilterChipType.withIcon
                : TsFilterChipType.textOnly,

            iconWidget: chip.iconId != null
                ? TsLeagueIcon(leagueId: chip.iconId!, size: 16)
                : null,

            onTap: () {
              ref.read(selectedLeagueProvider.notifier).state = chip.isAll
                  ? null
                  : chip.id;
            },
          );
        },
      ),
    );
  }

  Widget _buildBaseballLeagueFilterChips() {
    final selectedBaseballLeague = ref.watch(selectedBaseballLeagueProvider);

    return SizedBox(
      height: 32,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: baseballAnalysisLeagueChips.length,

        separatorBuilder: (_, _) => const SizedBox(width: 8),

        itemBuilder: (context, index) {
          final chip = baseballAnalysisLeagueChips[index];

          final isSelected = chip.isAll
              ? selectedBaseballLeague == null
              : selectedBaseballLeague == chip.code;

          return TsFilterChip(
            label: chip.displayLabel,

            isSelected: isSelected,

            type: chip.iconId != null
                ? TsFilterChipType.withIcon
                : TsFilterChipType.textOnly,

            iconWidget: chip.iconId != null
                ? TsLeagueIcon(leagueId: chip.iconId!, size: 16)
                : null,

            onTap: () {
              ref.read(selectedBaseballLeagueProvider.notifier).state =
                  chip.isAll ? null : chip.code;
            },
          );
        },
      ),
    );
  }

  Widget _buildBaseballDateNavStrip() {
    final today = DateTime.now();

    final todayDay = DateTime(today.year, today.month, today.day);

    final chipDates = baseballAnalysisDateTimes();

    final selectedDateStr = ref.watch(baseballAnalysisDateProvider);

    return SizedBox(
      height: 40,

      child: Row(
        children: [
          for (var i = 0; i < chipDates.length; i++) ...[
            if (i > 0) const SizedBox(width: _dateChipGap),

            Expanded(
              child: DateNavChip(
                expandWidth: true,
                type: _isSameDay(chipDates[i], todayDay)
                    ? DateNavChipType.today
                    : DateNavChipType.date,

                dayLabel: _isSameDay(chipDates[i], todayDay)
                    ? '오늘'
                    : _weekdays[chipDates[i].weekday - 1],

                dateLabel: _md.format(chipDates[i]),

                isActive: selectedDateStr == baseballDateString(chipDates[i]),

                onTap: () => _selectBaseballDateAtIndex(i),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSoccerDateNavStrip() {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final chipDates = soccerAnalysisDateTimes();
    final selectedDateStr = ref.watch(soccerAnalysisDateProvider);

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          for (var i = 0; i < chipDates.length; i++) ...[
            if (i > 0) const SizedBox(width: _dateChipGap),
            Expanded(
              child: DateNavChip(
                expandWidth: true,
                type: _isSameDay(chipDates[i], todayDay)
                    ? DateNavChipType.today
                    : DateNavChipType.date,
                dayLabel: _isSameDay(chipDates[i], todayDay)
                    ? '오늘'
                    : _weekdays[chipDates[i].weekday - 1],
                dateLabel: _md.format(chipDates[i]),
                isActive: selectedDateStr == fixtureDateString(chipDates[i]),
                onTap: () => _selectSoccerDateAtIndex(i),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSoccerSection({required VoidCallback onPremiumCtaTap}) {
    final dates = ref.watch(soccerAnalysisDatesProvider);

    ref.listen(soccerAnalysisDateProvider, (previous, next) {
      if (_syncingSoccerPage) return;

      final index = dates.indexOf(next);
      if (index < 0 || !_soccerPageController.hasClients) return;

      final currentPage =
          _soccerPageController.page?.round() ??
          _soccerPageController.initialPage;
      if (currentPage != index) {
        _jumpSoccerToPageIndex(index);
      }
    });

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    PremiumPickStatsCard(
                      showCTA: true,
                      onCTATap: onPremiumCtaTap,
                    ),
                    const SizedBox(height: 16),
                    _buildSoccerDateNavStrip(),
                    const SizedBox(height: 16),
                    _buildSoccerFilterChips(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: PageView.builder(
        controller: _soccerPageController,
        physics: _pageScrollPhysics,
        dragStartBehavior: DragStartBehavior.down,
        itemCount: dates.length,
        onPageChanged: _onSoccerPageChanged,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SoccerMatchesSection(
              dateStr: dates[index],
              scrollable: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBaseballSection() {
    final dates = ref.watch(baseballAnalysisDatesProvider);

    ref.listen(baseballAnalysisDateProvider, (previous, next) {
      if (_syncingBaseballPage) return;

      final index = dates.indexOf(next);

      if (index < 0 || !_baseballPageController.hasClients) return;

      final currentPage =
          _baseballPageController.page?.round() ??
          _baseballPageController.initialPage;

      if (currentPage != index) {
        _jumpBaseballToPageIndex(index);
      }
    });

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const BaseballTodayComboCard(),
                    const SizedBox(height: 16),
                    _buildBaseballDateNavStrip(),
                    const SizedBox(height: 16),
                    _buildBaseballLeagueFilterChips(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: PageView.builder(
        controller: _baseballPageController,
        physics: _pageScrollPhysics,
        dragStartBehavior: DragStartBehavior.down,
        itemCount: dates.length,
        onPageChanged: _onBaseballPageChanged,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BaseballMatchesSection(
              dateStr: dates[index],
              scrollable: true,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    final auth = ref.watch(authProvider);

    void onPremiumCtaTap({required SportType sport}) {
      if (auth.hasFullAccess) {
        context.go(
          sport == SportType.baseball ? '/premium?sport=baseball' : '/premium',
        );
      } else {
        navigateToSubscribeIfLoggedIn(context, auth.isLoggedIn);
      }
    }

    return Scaffold(
      backgroundColor: semantic.surfaceBase,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

            child: SportsToggle(
              selectedSport: _selectedSport,

              onChanged: (sport) {
                setState(() => _selectedSport = sport);

                if (sport == SportType.soccer) {
                  _resetSoccerToToday();
                } else {
                  _resetBaseballToToday();
                }
              },
            ),
          ),

          Expanded(
            child: _selectedSport == SportType.soccer
                ? _buildSoccerSection(
                    onPremiumCtaTap: () =>
                        onPremiumCtaTap(sport: SportType.soccer),
                  )
                : _buildBaseballSection(),
          ),
        ],
      ),
    );
  }
}
