import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/models/premium_pick_stats.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/home_pick_history_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/services/soccer_service.dart';
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
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_today_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_news_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/design_system/widgets/ts_subscription_banner.dart';

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
      // TODO(data): soccer analysis matches provider
      _analysisCarousel(
        context,
        title: 'Soccer Analysis',
        seeAllPath: '/reports/soccer/premium',
        items: _soccerAnalysisSamples,
      ),
      // TODO(data): baseball analysis matches provider
      _analysisCarousel(
        context,
        title: 'Baseball Analysis',
        subtitle: 'MLB · KBO · NPB',
        seeAllPath: '/reports/baseball',
        items: _baseballAnalysisSamples,
      ),
      // TODO(data): today's matches provider
      _matchesCarousel(context),
      // TODO(data): promotional banner content
      _plainBlock(const TsBannerSlot(ratio: TsBannerRatio.h214)),
      // TODO(data): baseballComboStatsProvider — multi-match combo card
      _plainBlock(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TsSectionHeader(
              title: 'Multi-Match Analysis',
              subtitle: "Today's baseball combinations",
            ),
            const SizedBox(height: TsSpacing.sm),
            TsComboTodayCard(
                countValue: '4',
                countLabel: 'combinations today',
                leagues: [
                  TsComboLeagueCount(
                    icon: TsLeagueIcon('mlb', size: 28),
                    countLabel: '1',
                  ),
                  TsComboLeagueCount(
                    icon: TsLeagueIcon('kbo', size: 28),
                    countLabel: '1',
                  ),
                  TsComboLeagueCount(
                    icon: TsLeagueIcon('npb', size: 28),
                    countLabel: '1',
                  ),
                ],
                stableLabel: 'Stable',
                aggressiveLabel: 'Aggressive',
                stableValueLabel: '2',
                aggressiveValueLabel: '1',
                stableFraction: 0.67,
                accuracyLabel: '58% accuracy · last 30',
                ctaLabel: 'View combos',
                onCtaPressed: () {
                  // TODO(data): navigate to combo picks
                },
              ),
          ],
        ),
      ),
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
    await ref.read(homePickHistoryProvider(_accuracySport).future);
    // TODO(data): also invalidate soccer analysis, baseball analysis, today's
    // matches, combo picks, and news providers once those blocks are wired.
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

  Widget _analysisCarousel(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String seeAllPath,
    required List<_AnalysisSample> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
          child: _seeAllHeader(
            context,
            title: title,
            subtitle: subtitle,
            onSeeAll: () => context.go(seeAllPath),
          ),
        ),
        const SizedBox(height: TsSpacing.sm),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: TsSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: 340,
                child: TsAnalysisCard(
                  leagueId: item.leagueId,
                  leagueLabel: item.leagueLabel,
                  homeTeam: item.homeTeam,
                  awayTeam: item.awayTeam,
                  status: item.status,
                  centerLabel: item.centerLabel,
                  subLabel: item.subLabel,
                  onTap: () {
                    // TODO(data): open analysis detail for ${item.homeTeam} vs ${item.awayTeam}
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _matchesCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
          child: _seeAllHeader(
            context,
            title: "Today's Matches",
            onSeeAll: () => context.go('/matches'),
          ),
        ),
        const SizedBox(height: TsSpacing.sm),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            itemCount: _matchSamples.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: TsSpacing.sm),
            itemBuilder: (context, index) {
              final item = _matchSamples[index];
              return SizedBox(
                width: 300,
                child: TsMatchCard(
                  leagueId: item.leagueId,
                  leagueLabel: item.leagueLabel,
                  kickoffLabel: item.kickoffLabel,
                  homeTeam: item.homeTeam,
                  awayTeam: item.awayTeam,
                  density: TsMatchCardDensity.card,
                  hasAnalysis: item.hasAnalysis,
                  pickLabel: item.pickLabel,
                  pickTone: item.pickTone,
                  probabilityLabel: item.probabilityLabel,
                  locked: item.locked,
                  onTap: () {
                    // TODO(data): open match detail for ${item.homeTeam} vs ${item.awayTeam}
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _newsBlock(BuildContext context) {
    return _plainBlock(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _seeAllHeader(
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

  Widget _seeAllHeader(
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

class _AnalysisSample {
  const _AnalysisSample({
    required this.leagueId,
    required this.leagueLabel,
    required this.homeTeam,
    required this.awayTeam,
    this.status = TsAnalysisStatus.scheduled,
    this.centerLabel,
    this.subLabel,
  });

  final String leagueId;
  final String leagueLabel;
  final String homeTeam;
  final String awayTeam;
  final TsAnalysisStatus status;
  final String? centerLabel;
  final String? subLabel;
}

class _MatchSample {
  const _MatchSample({
    required this.leagueId,
    required this.leagueLabel,
    required this.kickoffLabel,
    required this.homeTeam,
    required this.awayTeam,
    this.hasAnalysis = false,
    this.pickLabel,
    this.pickTone = TsBadgeTone.positive,
    this.probabilityLabel,
    this.locked = false,
  });

  final String leagueId;
  final String leagueLabel;
  final String kickoffLabel;
  final String homeTeam;
  final String awayTeam;
  final bool hasAnalysis;
  final String? pickLabel;
  final TsBadgeTone pickTone;
  final String? probabilityLabel;
  final bool locked;
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

// TODO(data): replace with soccer analysis matches provider
const _soccerAnalysisSamples = <_AnalysisSample>[
  _AnalysisSample(
    leagueId: 'premier_league',
    leagueLabel: 'Premier League',
    homeTeam: 'Arsenal',
    awayTeam: 'Chelsea',
    centerLabel: '15:00',
    subLabel: 'Sat',
  ),
  _AnalysisSample(
    leagueId: 'la_liga',
    leagueLabel: 'La Liga',
    homeTeam: 'Barcelona',
    awayTeam: 'Real Madrid',
    status: TsAnalysisStatus.live,
    centerLabel: '1 - 1',
    subLabel: "72'",
  ),
  _AnalysisSample(
    leagueId: 'bundesliga',
    leagueLabel: 'Bundesliga',
    homeTeam: 'Bayern',
    awayTeam: 'Dortmund',
    status: TsAnalysisStatus.finished,
    centerLabel: '3 - 2',
    subLabel: 'FT',
  ),
];

// TODO(data): replace with baseball analysis matches provider
const _baseballAnalysisSamples = <_AnalysisSample>[
  _AnalysisSample(
    leagueId: 'mlb',
    leagueLabel: 'MLB',
    homeTeam: 'Yankees',
    awayTeam: 'Red Sox',
    centerLabel: '19:05',
    subLabel: 'Today',
  ),
  _AnalysisSample(
    leagueId: 'kbo',
    leagueLabel: 'KBO',
    homeTeam: 'LG Twins',
    awayTeam: 'Doosan',
    centerLabel: '18:30',
    subLabel: 'Today',
  ),
  _AnalysisSample(
    leagueId: 'npb',
    leagueLabel: 'NPB',
    homeTeam: 'Giants',
    awayTeam: 'Tigers',
    centerLabel: '18:00',
    subLabel: 'Today',
  ),
];

// TODO(data): replace with today's matches provider
const _matchSamples = <_MatchSample>[
  _MatchSample(
    leagueId: 'premier_league',
    leagueLabel: 'Premier League',
    kickoffLabel: '15:00',
    homeTeam: 'Liverpool',
    awayTeam: 'Spurs',
    hasAnalysis: true,
  ),
  _MatchSample(
    leagueId: 'la_liga',
    leagueLabel: 'La Liga',
    kickoffLabel: '22:00',
    homeTeam: 'Atletico',
    awayTeam: 'Sevilla',
    hasAnalysis: true,
    pickLabel: 'HOME',
    pickTone: TsBadgeTone.positive,
    probabilityLabel: '62%',
    locked: true,
  ),
  _MatchSample(
    leagueId: 'mlb',
    leagueLabel: 'MLB',
    kickoffLabel: '08:10',
    homeTeam: 'Dodgers',
    awayTeam: 'Padres',
  ),
  _MatchSample(
    leagueId: 'kbo',
    leagueLabel: 'KBO',
    kickoffLabel: '18:30',
    homeTeam: 'Samsung',
    awayTeam: 'Hanwha',
    hasAnalysis: true,
  ),
  _MatchSample(
    leagueId: 'serie_a',
    leagueLabel: 'Serie A',
    kickoffLabel: '03:45',
    homeTeam: 'Inter',
    awayTeam: 'Milan',
    hasAnalysis: true,
  ),
];

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
