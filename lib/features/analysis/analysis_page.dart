import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_combo_provider.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/features/analysis/analysis_dummy_data.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball_matches_section.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer_matches_section.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_shell_app_bar_content.dart';
import 'package:trendsoccer/shared/widgets/cards/baseball_today_combo_card.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_stats_card.dart';
import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';
import 'package:trendsoccer/shared/widgets/navigation/date_tab_bar.dart';
import 'package:trendsoccer/shared/widgets/exit_pop_scope.dart';
import 'package:trendsoccer/shared/widgets/toggle/sports_toggle.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  static final _md = DateFormat('M.dd');

  SportType _selectedSport = SportType.soccer;
  final ScrollController _scrollController = ScrollController();
  double _dragStartX = 0;
  double _dragEndX = 0;

  @override
  void dispose() {
    _scrollController.dispose();
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

  Future<void> _onRefresh() async {
    ref.invalidate(analysisSoccerMatchesProvider);
    ref.invalidate(premiumPickStatsProvider);
    ref.invalidate(baseballAnalysisMatchesProvider);
    ref.invalidate(baseballComboStatsProvider);

    clearSoccerAnalysisEmptyCache();

    await Future.wait([
      ref.read(analysisSoccerMatchesProvider.future),
      ref.read(premiumPickStatsProvider.future),
      ref.read(baseballAnalysisMatchesProvider.future),
      ref.read(baseballComboStatsProvider.future),
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final sportParam = GoRouterState.of(context).uri.queryParameters['sport'];

    if (sportParam == 'baseball' && _selectedSport != SportType.baseball) {
      setState(() => _selectedSport = SportType.baseball);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _resetBaseballToToday();
        }
      });
    }
  }

  void _resetSoccerToToday() {
    ref.read(selectedLeagueProvider.notifier).state = null;
    ref.read(soccerAnalysisDateProvider.notifier).state =
        fixtureTodayDateString();
  }

  void _resetBaseballToToday() {
    ref.read(selectedBaseballLeagueProvider.notifier).state = null;
    ref.read(baseballAnalysisDateProvider.notifier).state =
        baseballTodayDateString();
  }

  void _selectSoccerDateAtIndex(int index) {
    final dates = ref.read(soccerAnalysisDatesProvider);
    if (index < 0 || index >= dates.length) return;

    ref.read(selectedLeagueProvider.notifier).state = null;
    ref.read(soccerAnalysisDateProvider.notifier).state = dates[index];
    _scrollToTop();
  }

  void _selectBaseballDateAtIndex(int index) {
    final dates = ref.read(baseballAnalysisDatesProvider);
    if (index < 0 || index >= dates.length) return;

    ref.read(selectedBaseballLeagueProvider.notifier).state = null;
    ref.read(baseballAnalysisDateProvider.notifier).state = dates[index];
    _scrollToTop();
  }

  void _goToNextDate({
    required bool isSoccer,
    required int selectedIndex,
    required int dateCount,
  }) {
    if (selectedIndex >= dateCount - 1) return;
    if (isSoccer) {
      _selectSoccerDateAtIndex(selectedIndex + 1);
    } else {
      _selectBaseballDateAtIndex(selectedIndex + 1);
    }
  }

  void _goToPreviousDate({
    required bool isSoccer,
    required int selectedIndex,
  }) {
    if (selectedIndex <= 0) return;
    if (isSoccer) {
      _selectSoccerDateAtIndex(selectedIndex - 1);
    } else {
      _selectBaseballDateAtIndex(selectedIndex - 1);
    }
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
              ? l10n.analysisToday
              : weekdays[date.weekday - 1],
          dateLabel: _md.format(date),
          isToday: _isSameDay(date, todayDay),
        ),
    ];
  }

  int _selectedDateIndex({
    required List<DateTime> chipDates,
    required String selectedDateStr,
    required String Function(DateTime) dateStringFor,
  }) {
    final index = chipDates.indexWhere(
      (date) => dateStringFor(date) == selectedDateStr,
    );
    return index < 0 ? 0 : index;
  }

  String _leagueChipLabel({
    required bool isAll,
    required String label,
    required String labelEn,
    required AppLanguage language,
    required AppLocalizations l10n,
  }) {
    if (isAll) return l10n.filterAll;
    return language == AppLanguage.en ? labelEn : label;
  }

  Widget _buildSoccerFilterChips() {
    final language = ref.watch(languageProvider);
    final l10n = context.l10n;
    final selectedSoccerLeague = ref.watch(selectedLeagueProvider);

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: soccerAnalysisLeagueChips.length,
        separatorBuilder: (_, _) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) {
          final chip = soccerAnalysisLeagueChips[index];
          final isSelected = chip.isAll
              ? selectedSoccerLeague == null
              : selectedSoccerLeague == chip.id;

          return TsFilterChip(
            label: _leagueChipLabel(
              isAll: chip.isAll,
              label: chip.label,
              labelEn: chip.labelEn,
              language: language,
              l10n: l10n,
            ),
            isSelected: isSelected,
            type: chip.iconId != null
                ? TsFilterChipType.withIcon
                : TsFilterChipType.textOnly,
            iconWidget: chip.iconId != null
                ? TsLeagueIcon(
                    leagueId: chip.iconId!,
                    size: 16,
                    isActive: isSelected,
                  )
                : null,
            onTap: () {
              ref.read(selectedLeagueProvider.notifier).state =
                  chip.isAll ? null : chip.id;
            },
          );
        },
      ),
    );
  }

  Widget _buildBaseballLeagueFilterChips() {
    final language = ref.watch(languageProvider);
    final l10n = context.l10n;
    final selectedBaseballLeague = ref.watch(selectedBaseballLeagueProvider);

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: baseballAnalysisLeagueChips.length,
        separatorBuilder: (_, _) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) {
          final chip = baseballAnalysisLeagueChips[index];
          final isSelected = chip.isAll
              ? selectedBaseballLeague == null
              : selectedBaseballLeague == chip.code;

          return TsFilterChip(
            label: _leagueChipLabel(
              isAll: chip.isAll,
              label: chip.label,
              labelEn: chip.labelEn,
              language: language,
              l10n: l10n,
            ),
            isSelected: isSelected,
            type: chip.iconId != null
                ? TsFilterChipType.withIcon
                : TsFilterChipType.textOnly,
            iconWidget: chip.iconId != null
                ? TsLeagueIcon(
                    leagueId: chip.iconId!,
                    size: 16,
                    isActive: isSelected,
                  )
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

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final auth = ref.watch(authProvider);
    final l10n = context.l10n;
    final isSoccer = _selectedSport == SportType.soccer;

    final chipDates = isSoccer
        ? soccerAnalysisDateTimes()
        : baseballAnalysisDateTimes();
    final selectedDateStr = isSoccer
        ? ref.watch(soccerAnalysisDateProvider)
        : ref.watch(baseballAnalysisDateProvider);
    final dateStringFor =
        isSoccer ? fixtureDateString : baseballDateString;
    final onDateSelected =
        isSoccer ? _selectSoccerDateAtIndex : _selectBaseballDateAtIndex;

    final dateItems = _buildDateItems(chipDates: chipDates, l10n: l10n);
    final selectedDateIndex = _selectedDateIndex(
      chipDates: chipDates,
      selectedDateStr: selectedDateStr,
      dateStringFor: dateStringFor,
    );

    void onPremiumCtaTap({required SportType sport}) {
      if (auth.hasFullAccess) {
        context.go(
          sport == SportType.baseball ? '/premium?sport=baseball' : '/premium',
        );
      } else {
        navigateToSubscribeIfLoggedIn(context, auth.isLoggedIn);
      }
    }

    return ExitPopScope(
      child: Scaffold(
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
            _goToNextDate(
              isSoccer: isSoccer,
              selectedIndex: selectedDateIndex,
              dateCount: chipDates.length,
            );
          } else if ((velocity ?? 0) > 300 || dx > 50) {
            _goToPreviousDate(
              isSoccer: isSoccer,
              selectedIndex: selectedDateIndex,
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: semantic.interactivePrimary,
          backgroundColor: semantic.surfaceBase,
          displacement: 40,
          edgeOffset: 0,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
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
                  dates: dateItems,
                  selectedIndex: selectedDateIndex,
                  onDateSelected: onDateSelected,
                  fillWidth: true,
                  backgroundColor: semantic.surfaceRaised,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(TsSpacing.lg, TsSpacing.lg, TsSpacing.lg, 0),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(TsSpacing.lg, TsSpacing.lg, TsSpacing.lg, 0),
              child: isSoccer
                  ? PremiumPickStatsCard(
                      showCTA: true,
                      onCTATap: () =>
                          onPremiumCtaTap(sport: SportType.soccer),
                    )
                  : const BaseballTodayComboCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(TsSpacing.lg),
              child: isSoccer
                  ? _buildSoccerFilterChips()
                  : _buildBaseballLeagueFilterChips(),
            ),
          ),
          if (isSoccer)
            SoccerMatchesSection(dateStr: selectedDateStr)
          else
            BaseballMatchesSection(dateStr: selectedDateStr),
          const SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: false,
            child: SizedBox.shrink(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 56),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: TsSpacing.lg),
          ),
        ],
          ),
        ),
      ),
    ),
    );
  }
}
