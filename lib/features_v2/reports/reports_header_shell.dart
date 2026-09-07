import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/utils/plan_tier_label.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_bottom_navigation.dart';
import 'package:trendsoccer/design_system/widgets/ts_segment_tabs.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/features_v2/reports/reports_date_strip.dart';
import 'package:trendsoccer/features_v2/reports/reports_league_chips.dart';
import 'package:trendsoccer/features_v2/reports/reports_league_filter_row.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_scope.dart';
import 'package:trendsoccer/features_v2/reports/reports_route_map.dart';

/// Shared reports header: app bar, sport toggle, segment tabs, optional date strip and filter.
class ReportsHeaderShell extends ConsumerStatefulWidget {
  const ReportsHeaderShell({
    required this.sport,
    required this.segment,
    required this.child,
    this.dateStripDates,
    this.selectedDateIndex = reportsHistoryDateStripSelectedIndex,
    this.onDateSelected,
    this.weekdayLabel,
    this.isToday,
    super.key,
  });

  final TsSport sport;
  final ReportsSegment segment;
  final Widget child;

  final List<DateTime>? dateStripDates;
  final int selectedDateIndex;
  final ValueChanged<int>? onDateSelected;
  final String Function(DateTime date)? weekdayLabel;
  final bool Function(DateTime date)? isToday;

  @override
  ConsumerState<ReportsHeaderShell> createState() => _ReportsHeaderShellState();
}

class _ReportsHeaderShellState extends ConsumerState<ReportsHeaderShell> {
  String? _selectedLeagueId;
  late int _selectedDateIndex;
  final ScrollController _leagueFilterScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDateIndex = widget.selectedDateIndex;
  }

  @override
  void dispose() {
    _leagueFilterScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReportsHeaderShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDateIndex != oldWidget.selectedDateIndex) {
      _selectedDateIndex = widget.selectedDateIndex;
    }
  }

  bool get _showsDateStrip =>
      reportsShowsDateStrip(widget.segment) && widget.dateStripDates != null;

  void _navigateTo(
    BuildContext context,
    TsSport targetSport,
    ReportsSegment targetSegment,
  ) {
    final route = reportsRouteFor(targetSport, targetSegment);
    if (GoRouterState.of(context).uri.path != route) {
      context.go(route);
    }
  }

  void _onSportChanged(BuildContext context, TsSport newSport) {
    if (newSport == widget.sport) return;
    _navigateTo(context, newSport, ReportsSegment.analysis);
  }

  void _onSegmentTap(BuildContext context, int index) {
    final targetSegment = reportsSegmentAtIndex(widget.sport, index);
    if (targetSegment == widget.segment) return;
    _navigateTo(context, widget.sport, targetSegment);
  }

  void _scrollLeagueFilterToStart() {
    if (!_leagueFilterScrollController.hasClients) return;
    _leagueFilterScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onLeagueSelected(String? id) {
    if (id == null) {
      _scrollLeagueFilterToStart();
    }
    setState(() => _selectedLeagueId = id);
  }

  void _clearLeagueSelection() {
    _scrollLeagueFilterToStart();
    setState(() => _selectedLeagueId = null);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isGuest = auth.planType == PlanType.none;
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final segmentLabels = reportsSegmentLabels(widget.sport);
    final activeSegmentIndex = reportsSegmentIndex(widget.sport, widget.segment);
    final languageCode = Localizations.localeOf(context).languageCode;
    final leagues = reportsLeagueFiltersForSport(widget.sport, languageCode);

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: isGuest ? TsAppBarType.homeGuest : TsAppBarType.homeMember,
        authLabel: 'Log in',
        onAuthTap: () => context.push('/login'),
        tierLabel: PlanTierLabel.forPlanType(auth.planType),
        onAvatarTap: () {
          StatefulNavigationShell.of(context).goBranch(
            TsNavTab.values.indexOf(TsNavTab.menu),
          );
        },
      ),
      body: ColoredBox(
        color: c.canvas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReportsHeaderControls(
              sport: widget.sport,
              segmentLabels: segmentLabels,
              activeSegmentIndex: activeSegmentIndex,
              onSportChanged: (value) => _onSportChanged(context, value),
              onSegmentTap: (index) => _onSegmentTap(context, index),
            ),
            const SizedBox(height: _ReportsHeaderControls.gapBelow),
            if (_showsDateStrip) ...[
              ReportsDateStrip(
                dates: widget.dateStripDates!,
                selectedIndex: _selectedDateIndex,
                weekdayLabel:
                    widget.weekdayLabel ?? (date) => _weekdayLabel(context, date),
                isToday: widget.isToday ?? _defaultIsToday,
                onSelected: (index) => setState(() => _selectedDateIndex = index),
              ),
              const SizedBox(height: ReportsDateStrip.chipGap),
            ],
            ReportsLeagueFilterRow(
              leagues: leagues,
              selectedLeagueId: _selectedLeagueId,
              scrollController: _leagueFilterScrollController,
              onSelected: _onLeagueSelected,
            ),
            SizedBox(
              height: _showsDateStrip ? TsSpacing.xl : _ReportsHeaderControls.gapBelow,
            ),
            Expanded(
              child: ReportsHeaderScope(
                selectedLeagueId: _selectedLeagueId,
                onClearLeagueSelection: _clearLeagueSelection,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _weekdayLabel(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.E(locale).format(date);
  }

  static bool _defaultIsToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _ReportsHeaderControls extends StatelessWidget {
  const _ReportsHeaderControls({
    required this.sport,
    required this.segmentLabels,
    required this.activeSegmentIndex,
    required this.onSportChanged,
    required this.onSegmentTap,
  });

  /// Figma HeaderControls: padding top 12 + toggle 36 + gap 8 + tabs 44 = 100.
  static const double height = 100;
  static const double topPadding = TsSpacing.md;
  static const double toggleHeight = 36;
  static const double toggleToTabsGap = TsSpacing.sm;
  static const double gapBelow = TsSpacing.lg;

  final TsSport sport;
  final List<String> segmentLabels;
  final int activeSegmentIndex;
  final ValueChanged<TsSport> onSportChanged;
  final ValueChanged<int> onSegmentTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: topPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
              child: SizedBox(
                height: toggleHeight,
                child: TsSportToggle(
                  active: sport,
                  onChanged: onSportChanged,
                ),
              ),
            ),
            const SizedBox(height: toggleToTabsGap),
            TsSegmentTabs(
              labels: segmentLabels,
              activeIndex: activeSegmentIndex,
              onTap: onSegmentTap,
            ),
          ],
        ),
      ),
    );
  }
}
