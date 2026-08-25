import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/models/premium_pick_stats.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/home_pick_history_provider.dart';
import 'package:trendsoccer/core/providers/home_combo_summary_provider.dart';
import 'package:trendsoccer/core/providers/home_match_preview_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/services/soccer_service.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_accuracy_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_analysis_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_banner_slot.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_today_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_news_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/design_system/widgets/ts_subscription_banner.dart';

Widget _homeSeeAllHeader(
  BuildContext context, {
  required String title,
  String? subtitle,
  required VoidCallback onSeeAll,
}) {
  final c = Theme.of(context).extension<TsThemeColors>()!;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TsType.h3.copyWith(color: c.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Text(
              'See all',
              style: TsType.labelSMedium.copyWith(color: c.textTertiary),
            ),
          ),
        ],
      ),
      if (subtitle != null) ...[
        const SizedBox(height: TsSpacing.xs),
        Text(
          subtitle,
          style: TsType.labelSRegular.copyWith(color: c.textSecondary),
        ),
      ],
    ],
  );
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TsAccuracyPeriod _accuracyPeriod = TsAccuracyPeriod.d30;
  TsSport _accuracySport = TsSport.soccer;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final auth = ref.watch(authProvider);
    // Trial users already have access: member app bar, no upsell, no ads.
    final hideMonetisation = auth.isPremium || auth.isTrial;
    final showSoccerAnalysisBlock = ref.watch(
      homeAnalysisMatchesProvider(TsSport.soccer).select(
        (asyncValue) => asyncValue.when(
          data: (matches) => matches.isNotEmpty,
          loading: () => true,
          error: (_, _) => true,
        ),
      ),
    );
    final showBaseballAnalysisBlock = ref.watch(
      homeAnalysisMatchesProvider(TsSport.baseball).select(
        (asyncValue) => asyncValue.when(
          data: (matches) => matches.isNotEmpty,
          loading: () => true,
          error: (_, _) => true,
        ),
      ),
    );
    final showTodayMatchesBlock = ref.watch(
      homeTodayMatchesProvider.select(
        (asyncValue) => asyncValue.when(
          data: (matches) => matches.isNotEmpty,
          loading: () => true,
          error: (_, _) => true,
        ),
      ),
    );
    final showComboBlock = ref.watch(
      homeComboSummaryProvider.select(
        (asyncValue) => asyncValue.when(
          data: (summary) => summary.comboCount > 0,
          loading: () => true,
          error: (_, _) => true,
        ),
      ),
    );

    final blocks = <Widget>[
      _plainBlock(
        _AccuracyCardSection(
          period: _accuracyPeriod,
          sport: _accuracySport,
          onPeriodChanged: (period) => setState(() => _accuracyPeriod = period),
          onSportChanged: (sport) => setState(() => _accuracySport = sport),
        ),
      ),
      // TODO(data): subscription upsell state and CTA destination
      if (!hideMonetisation)
        _plainBlock(
          TsSubscriptionBanner(
            headline: 'Unlock full analysis',
            subline: 'Reports, multi-match analysis',
            onAction: () => context.go('/menu/subscribe'),
          ),
        ),
      if (showSoccerAnalysisBlock)
        const _AnalysisCarouselSection(
          sport: TsSport.soccer,
          title: 'Soccer Analysis',
          seeAllPath: '/reports/soccer/premium',
        ),
      if (showBaseballAnalysisBlock)
        const _AnalysisCarouselSection(
          sport: TsSport.baseball,
          title: 'Baseball Analysis',
          subtitle: 'MLB · KBO · NPB',
          seeAllPath: '/reports/baseball',
        ),
      if (showTodayMatchesBlock) const _TodayMatchesSection(),
      // TODO(data): promotional banner content
      _plainBlock(const TsBannerSlot(ratio: TsBannerRatio.h214)),
      if (showComboBlock) _plainBlock(const _ComboTodaySection()),
      // TODO(data): news feed provider
      _newsBlock(context),
      // TODO(data): secondary promotional banner content
      if (!hideMonetisation) _plainBlock(const TsBannerSlot(ratio: TsBannerRatio.h160)),
      // TODO(data): AdMob banner ad unit
      if (!hideMonetisation)
        const TsBannerSlot(ratio: TsBannerRatio.h50),
    ];

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: hideMonetisation ? TsAppBarType.homeMember : TsAppBarType.homeGuest,
        authLabel: 'Log in',
        onAuthTap: () => context.go('/login'),
        tierLabel: 'PREMIUM',
      ),
      body: RefreshIndicator(
        onRefresh: _onHomeRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: TsSpacing.lg, bottom: TsSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withGaps(blocks),
          ),
        ),
      ),
    );
  }

  Future<void> _onHomeRefresh() async {
    ref.invalidate(homePickHistoryProvider(_accuracySport));
    ref.invalidate(analysisSoccerMatchesProvider);
    ref.invalidate(baseballAnalysisMatchesProvider);
    ref.invalidate(homeAnalysisMatchesProvider);
    ref.invalidate(homeTodayMatchesProvider);
    ref.invalidate(homeComboSummaryProvider);
    await Future.wait([
      ref.read(homePickHistoryProvider(_accuracySport).future),
      ref.read(homeTodayMatchesProvider.future),
      ref.read(homeAnalysisMatchesProvider(TsSport.soccer).future),
      ref.read(homeAnalysisMatchesProvider(TsSport.baseball).future),
      ref.read(homeComboSummaryProvider.future),
    ]);
    // TODO(data): also invalidate news providers once wired.
  }

  List<Widget> _withGaps(List<Widget> blocks) {
    if (blocks.isEmpty) return blocks;
    final spaced = <Widget>[blocks.first];
    for (var i = 1; i < blocks.length; i++) {
      spaced
        ..add(const SizedBox(height: TsSpacing.xl))
        ..add(blocks[i]);
    }
    return spaced;
  }

  Widget _plainBlock(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
      child: child,
    );
  }

  Widget _newsBlock(BuildContext context) {
    return _plainBlock(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _homeSeeAllHeader(
            context,
            title: 'News',
            onSeeAll: () => context.go('/feed/news'),
          ),
          const SizedBox(height: TsSpacing.sm),
          for (var i = 0; i < _newsSamples.length; i++) ...[
            if (i > 0) const SizedBox(height: TsSpacing.md),
            TsNewsRow(
                title: _newsSamples[i].title,
                source: _newsSamples[i].source,
                timeLabel: _newsSamples[i].timeLabel,
                onTap: () {
                  // TODO(data): open news article ${_newsSamples[i].title}
                },
              ),
          ],
        ],
      ),
    );
  }

}

class _AccuracyCardSection extends ConsumerStatefulWidget {
  const _AccuracyCardSection({
    required this.period,
    required this.sport,
    required this.onPeriodChanged,
    required this.onSportChanged,
  });

  final TsAccuracyPeriod period;
  final TsSport sport;
  final ValueChanged<TsAccuracyPeriod> onPeriodChanged;
  final ValueChanged<TsSport> onSportChanged;

  @override
  ConsumerState<_AccuracyCardSection> createState() =>
      _AccuracyCardSectionState();
}

class _AccuracyCardSectionState extends ConsumerState<_AccuracyCardSection> {
  Timer? _countdownTimer;
  String? _soccerNextUpdateLabel;

  @override
  void initState() {
    super.initState();
    _refreshSoccerCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _refreshSoccerCountdown();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _refreshSoccerCountdown() {
    if (!mounted || widget.sport != TsSport.soccer) return;
    final label =
        'New picks in ${formatCountdown(nextKstUpdateRemaining())}';
    if (_soccerNextUpdateLabel != label) {
      setState(() => _soccerNextUpdateLabel = label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(homePickHistoryProvider(widget.sport));

    return historyAsync.when(
      loading: _accuracyLoadingSkeleton,
      error: (error, stackTrace) => _accuracyCardWithRetry(
        context,
        onRetry: () => ref.invalidate(homePickHistoryProvider(widget.sport)),
      ),
      data: (history) => _accuracyCardFromHistory(context, history),
    );
  }

  Widget _accuracyLoadingSkeleton() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TsSkeletonBlock(TsSkeletonType.title, width: 160),
            TsSkeletonBlock(TsSkeletonType.line, width: 88),
          ],
        ),
        SizedBox(height: TsSpacing.md),
        TsSkeletonBlock(TsSkeletonType.block),
        SizedBox(height: TsSpacing.md),
        TsSkeletonBlock(TsSkeletonType.line, width: 120),
        SizedBox(height: TsSpacing.sm),
        TsSkeletonBlock(TsSkeletonType.line, width: 200),
        SizedBox(height: TsSpacing.lg),
        TsSkeletonBlock(TsSkeletonType.title, width: 72),
        SizedBox(height: TsSpacing.sm),
        SizedBox(
          height: 111,
          child: Row(
            children: [
              Expanded(child: TsSkeletonBlock(TsSkeletonType.block)),
              SizedBox(width: TsSpacing.sm),
              Expanded(child: TsSkeletonBlock(TsSkeletonType.block)),
              SizedBox(width: TsSpacing.sm),
              Expanded(child: TsSkeletonBlock(TsSkeletonType.block)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accuracyCardWithRetry(
    BuildContext context, {
    required VoidCallback onRetry,
  }) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _accuracyCardFromHistory(context, const {}),
        const SizedBox(height: TsSpacing.sm),
        TextButton(
          onPressed: onRetry,
          child: Text(
            'Retry',
            style: TsType.labelSRegular.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _accuracyCardFromHistory(
    BuildContext context,
    Map<String, dynamic> history,
  ) {
    final service = ref.read(soccerServiceProvider);
    final windowDays =
        widget.period == TsAccuracyPeriod.d7 ? 7 : 30;
    final stats = service.calculateRecentStats(
      history,
      windowDays: windowDays,
    );

    if (stats.isEmpty) {
      return _accuracyCardEmpty(context);
    }

    final wins = stats['wins'] as int? ?? 0;
    final losses = stats['losses'] as int? ?? 0;
    final total = stats['total'] as int? ?? 0;
    final winRate = stats['winRate'] as int? ?? 0;
    final streak = stats['streak'] as int? ?? 0;
    final streakType = stats['streakType'] as String? ?? 'losing';
    final streakSuffix = streakType == 'winning' ? 'W' : 'L';

    final isBaseball = widget.sport == TsSport.baseball;
    final baselineFraction = isBaseball ? 0.50 : 0.33;
    final baselineNoteLabel = isBaseball
        ? 'Baseline 50% — random guess between two teams'
        : 'Baseline 33% — random guess across three results';

    final windowPicks = stats['windowPicks'];
    final recentPicks = windowPicks is List
        ? windowPicks
            .whereType<Map>()
            .map((pick) => Map<String, dynamic>.from(pick))
            .take(10)
            .map(_mapRecentPick)
            .whereType<TsRecentPick>()
            .toList()
        : const <TsRecentPick>[];

    return TsAccuracyCard(
      titleLabel: 'Prediction accuracy',
      period7Label: '7D',
      period30Label: '30D',
      initialPeriod: widget.period,
      onPeriodChanged: widget.onPeriodChanged,
      sport: widget.sport,
      onSportChanged: widget.onSportChanged,
      valueLabel: '$winRate%',
      winLossLabel: '${wins}W · ${losses}L',
      accuracyFraction: winRate / 100,
      baselineFraction: baselineFraction,
      sampleLabel: 'Based on $total picks',
      baselineNoteLabel: baselineNoteLabel,
      streakLabel: '$streak$streakSuffix streak',
      nextUpdateLabel:
          isBaseball ? null : _soccerNextUpdateLabel,
      recentPicks: recentPicks,
      recentLabel: 'Recent',
      seeAllLabel: 'View picks',
      onSeeAllPressed: () {
        // TODO(data): navigate to full accuracy history
      },
    );
  }

  Widget _accuracyCardEmpty(BuildContext context) {
    // Duplicates TsAccuracyCard chrome (surface, title, toggles) until the
    // component gains a Figma state=empty — passing zeroed stats would still
    // render the gauge and meta row, and there is no flag to suppress that body.
    final c = Theme.of(context).extension<TsThemeColors>()!;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: TsRadius.md,
        ),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Prediction accuracy',
                      style: TsType.h3.copyWith(color: c.textPrimary),
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  _buildPeriodToggle(c),
                ],
              ),
              const SizedBox(height: TsSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 240),
                child: TsSportToggle(
                  active: widget.sport,
                  onChanged: widget.onSportChanged,
                ),
              ),
              const SizedBox(height: TsSpacing.lg),
              const TsEmptyState(
                title: 'No settled picks in this period',
                description:
                    'Try a longer window, or check back when the season resumes.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(TsThemeColors c) {
    return Container(
      padding: const EdgeInsets.all(TsSpacing.xs),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: TsRadius.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodSegment(
            c,
            '7D',
            widget.period == TsAccuracyPeriod.d7,
            () => widget.onPeriodChanged(TsAccuracyPeriod.d7),
          ),
          const SizedBox(width: TsSpacing.xs),
          _buildPeriodSegment(
            c,
            '30D',
            widget.period == TsAccuracyPeriod.d30,
            () => widget.onPeriodChanged(TsAccuracyPeriod.d30),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSegment(
    TsThemeColors c,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? c.primary : Colors.transparent,
          borderRadius: TsRadius.full,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: TsSpacing.xs,
            horizontal: TsSpacing.sm,
          ),
          child: Text(
            label,
            style: (selected ? TsType.labelSBold : TsType.labelSMedium).copyWith(
              color: selected ? c.onPrimary : c.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  TsRecentPick? _mapRecentPick(Map<String, dynamic> pick) {
    final resultRaw = pick['result']?.toString().toUpperCase();
    final TsRecentPickResult? result;
    switch (resultRaw) {
      case 'WIN':
        result = TsRecentPickResult.match;
      case 'LOSE':
        result = TsRecentPickResult.mismatch;
      default:
        return null;
    }

    final homeTeam =
        _readPickString(pick, const ['homeTeam', 'home_team', 'home']);
    final awayTeam =
        _readPickString(pick, const ['awayTeam', 'away_team', 'away']);
    if (homeTeam == null || awayTeam == null) return null;

    final league = _readPickString(pick, const ['league']) ?? '';
    final leagueId =
        TsAssets.leagueIconIdFromApiCode(league) ?? league.toLowerCase();

    final dateRaw = pick['date'] ??
        pick['commence_time'] ??
        pick['commenceTime'] ??
        pick['matchDate'];
    final dateLabel = dateRaw == null
        ? ''
        : formatSoccerCardDate(dateRaw.toString());

    return TsRecentPick(
      result: result,
      homeTeamLabel: homeTeam,
      awayTeamLabel: awayTeam,
      homeScoreLabel: _pickScoreLabel(pick['homeScore'] ?? pick['home_score']),
      awayScoreLabel: _pickScoreLabel(pick['awayScore'] ?? pick['away_score']),
      pickedTeamLabel: _pickedTeamLabel(pick, homeTeam, awayTeam),
      leagueLabel: TsAssets.leagueDisplayName(league),
      leagueIcon: TsLeagueIcon(leagueId, size: TsIconSize.xs),
      dateLabel: dateLabel,
      homeEmblemUrl: _readPickLogo(pick, isHome: true),
      awayEmblemUrl: _readPickLogo(pick, isHome: false),
    );
  }

  String? _readPickString(Map<String, dynamic> pick, List<String> keys) {
    for (final key in keys) {
      final value = pick[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  String? _readPickLogo(Map<String, dynamic> pick, {required bool isHome}) {
    return _readPickString(
      pick,
      isHome
          ? const [
              'homeTeamLogo',
              'home_team_logo',
              'homeLogo',
              'home_logo',
            ]
          : const [
              'awayTeamLogo',
              'away_team_logo',
              'awayLogo',
              'away_logo',
            ],
    );
  }

  String _pickScoreLabel(Object? value) {
    if (value == null) return '-';
    return value.toString();
  }

  String _pickedTeamLabel(
    Map<String, dynamic> pick,
    String homeTeam,
    String awayTeam,
  ) {
    final predicted = pick['predicted']?.toString().toLowerCase().trim();
    switch (predicted) {
      case 'home':
        return homeTeam;
      case 'away':
        return awayTeam;
      case 'draw':
        return 'Draw';
      default:
        return homeTeam;
    }
  }
}

String _analysisKickoffTimeLabel(DateTime kickoffUtc) {
  final local = kickoffUtc.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String _analysisKickoffSubLabel(DateTime kickoffUtc) {
  final local = kickoffUtc.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final kickoffDay = DateTime(local.year, local.month, local.day);
  if (kickoffDay == today) return 'Today';
  if (kickoffDay == today.add(const Duration(days: 1))) return 'Tomorrow';
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$month.$day';
}

class _AnalysisCarouselSection extends ConsumerWidget {
  const _AnalysisCarouselSection({
    required this.sport,
    required this.title,
    this.subtitle,
    required this.seeAllPath,
  });

  final TsSport sport;
  final String title;
  final String? subtitle;
  final String seeAllPath;

  void _retry(WidgetRef ref) {
    switch (sport) {
      case TsSport.soccer:
        ref.invalidate(analysisSoccerMatchesProvider);
      case TsSport.baseball:
        ref.invalidate(baseballAnalysisMatchesProvider);
    }
    ref.invalidate(homeAnalysisMatchesProvider(sport));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(homeAnalysisMatchesProvider(sport));

    final rail = matchesAsync.when(
      loading: () => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: homeAnalysisMatchesLimit,
        separatorBuilder: (context, index) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) => const SizedBox(
          width: 340,
          child: TsSkeletonBlock(TsSkeletonType.block),
        ),
      ),
      error: (error, stackTrace) => Align(
        alignment: Alignment.center,
        child: TsEmptyState(
          type: TsEmptyType.failure,
          title: 'Could not load matches',
          description: 'Check your connection and try again.',
          actionLabel: 'Retry',
          onAction: () => _retry(ref),
        ),
      ),
      data: (matches) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: matches.length,
        separatorBuilder: (context, index) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) {
          final item = matches[index];
          final leagueCode = item.leagueCode;
          final leagueId =
              TsAssets.leagueIconIdFromApiCode(leagueCode) ??
              leagueCode.toLowerCase();
          return SizedBox(
            width: 340,
            child: TsAnalysisCard(
              leagueId: leagueId,
              leagueLabel: TsAssets.leagueDisplayName(leagueCode),
              homeTeam: localizedTeamName(
                context,
                item.homeTeamEn,
                item.homeTeamKo,
              ),
              awayTeam: localizedTeamName(
                context,
                item.awayTeamEn,
                item.awayTeamKo,
              ),
              homeEmblemUrl: item.homeEmblemUrl,
              awayEmblemUrl: item.awayEmblemUrl,
              status: TsAnalysisStatus.scheduled,
              centerLabel: _analysisKickoffTimeLabel(item.kickoffUtc),
              subLabel: _analysisKickoffSubLabel(item.kickoffUtc),
              onTap: () {
                // TODO(data): open analysis report detail
              },
            ),
          );
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
          child: _homeSeeAllHeader(
            context,
            title: title,
            subtitle: subtitle,
            onSeeAll: () => context.go(seeAllPath),
          ),
        ),
        const SizedBox(height: TsSpacing.sm),
        SizedBox(
          height: 120,
          child: rail,
        ),
      ],
    );
  }
}

class _ComboTodaySection extends ConsumerWidget {
  const _ComboTodaySection();

  void _retry(WidgetRef ref) {
    ref.invalidate(homeComboSummaryProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeComboSummaryProvider);

    final card = summaryAsync.when(
      loading: () => const TsSkeletonBlock(TsSkeletonType.block),
      error: (error, stackTrace) => TsEmptyState(
        type: TsEmptyType.failure,
        title: 'Could not load combinations',
        description: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => _retry(ref),
      ),
      data: (summary) => TsComboTodayCard(
        countValue: summary.comboCount.toString(),
        countLabel: 'combinations today',
        leagues: [
          for (final league in summary.leagueCounts)
            TsComboLeagueCount(
              icon: TsLeagueIcon(
                TsAssets.leagueIconIdFromApiCode(league.leagueCode) ??
                    league.leagueCode.toLowerCase(),
                size: 28,
              ),
              countLabel: league.count.toString(),
            ),
        ],
        stableLabel: 'Stable',
        aggressiveLabel: 'Aggressive',
        stableValueLabel: summary.stableCount.toString(),
        aggressiveValueLabel: summary.aggressiveCount.toString(),
        stableFraction: summary.stableFraction,
        accuracyLabel: summary.accuracyLabel,
        ctaLabel: 'View combinations',
        onCtaPressed: () {
          // TODO(data): navigate to combo picks
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TsSectionHeader(
          title: 'Multi-Match Analysis',
          subtitle: "Today's baseball combinations",
        ),
        const SizedBox(height: TsSpacing.sm),
        card,
      ],
    );
  }
}

class _TodayMatchesSection extends ConsumerWidget {
  const _TodayMatchesSection();

  void _retry(WidgetRef ref) {
    ref.invalidate(analysisSoccerMatchesProvider);
    ref.invalidate(baseballAnalysisMatchesProvider);
    ref.invalidate(homeTodayMatchesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(homeTodayMatchesProvider);

    final rail = matchesAsync.when(
      loading: () => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: homeTodayMatchesLimit,
        separatorBuilder: (context, index) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) => const SizedBox(
          width: 300,
          child: TsSkeletonBlock(TsSkeletonType.block),
        ),
      ),
      error: (error, stackTrace) => Align(
        alignment: Alignment.center,
        child: TsEmptyState(
          type: TsEmptyType.failure,
          title: 'Could not load matches',
          description: 'Check your connection and try again.',
          actionLabel: 'Retry',
          onAction: () => _retry(ref),
        ),
      ),
      data: (matches) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: matches.length,
        separatorBuilder: (context, index) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) {
          final item = matches[index];
          final leagueCode = item.leagueCode;
          final leagueId =
              TsAssets.leagueIconIdFromApiCode(leagueCode) ??
              leagueCode.toLowerCase();
          final kickoffLocal = item.kickoffUtc.toLocal();
          final kickoffLabel =
              '${kickoffLocal.hour.toString().padLeft(2, '0')}:'
              '${kickoffLocal.minute.toString().padLeft(2, '0')}';
          return SizedBox(
            width: 300,
            child: TsMatchCard(
              leagueId: leagueId,
              leagueLabel: TsAssets.leagueDisplayName(leagueCode),
              kickoffLabel: kickoffLabel,
              homeTeam: localizedTeamName(
                context,
                item.homeTeamEn,
                item.homeTeamKo,
              ),
              awayTeam: localizedTeamName(
                context,
                item.awayTeamEn,
                item.awayTeamKo,
              ),
              homeEmblemUrl: item.homeEmblemUrl,
              awayEmblemUrl: item.awayEmblemUrl,
              density: TsMatchCardDensity.card,
              hasAnalysis: item.hasAnalysis,
              onTap: () => context.go('/matches'),
            ),
          );
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
          child: _homeSeeAllHeader(
            context,
            title: "Today's Matches",
            onSeeAll: () => context.go('/matches'),
          ),
        ),
        const SizedBox(height: TsSpacing.sm),
        SizedBox(
          height: 118,
          child: rail,
        ),
      ],
    );
  }
}

class _NewsSample {
  const _NewsSample({
    required this.title,
    required this.source,
    required this.timeLabel,
  });

  final String title;
  final String source;
  final String timeLabel;
}

// TODO(data): replace with news feed provider
const _newsSamples = <_NewsSample>[
  _NewsSample(
    title: 'Arsenal extend lead at the top after late winner',
    source: 'TrendSoccer',
    timeLabel: '2h ago',
  ),
  _NewsSample(
    title: 'Dodgers rotation shift ahead of weekend series',
    source: 'MLB Wire',
    timeLabel: '4h ago',
  ),
  _NewsSample(
    title: 'Premium pick accuracy hits 45% over last 30 days',
    source: 'TrendSoccer',
    timeLabel: '6h ago',
  ),
];
