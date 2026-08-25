import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_accuracy_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_analysis_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_banner_slot.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_today_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_news_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
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
      // TODO(data): premiumPickStatsProvider — accuracy card
      _plainBlock(
        TsAccuracyCard(
            titleLabel: 'Prediction accuracy',
            period7Label: '7D',
            period30Label: '30D',
            initialPeriod: _accuracyPeriod,
            onPeriodChanged: (period) {
              setState(() => _accuracyPeriod = period);
              // TODO(data): fetch accuracy stats for selected period
            },
            sport: _accuracySport,
            onSportChanged: (sport) {
              setState(() => _accuracySport = sport);
              // TODO(data): switch accuracy sport and reload stats
            },
            valueLabel: '45%',
            winLossLabel: '19W · 23L',
            accuracyFraction: 0.45,
            baselineFraction: 0.33,
            sampleLabel: 'Based on 42 picks',
            baselineNoteLabel: 'Baseline 33% — random pick',
            streakLabel: '3L streak',
            nextUpdateLabel: 'Next update 02:24',
            recentPicks: _accuracyRecentPicks,
            recentLabel: 'Recent',
            seeAllLabel: 'View picks',
            onSeeAllPressed: () {
              // TODO(data): navigate to full accuracy history
            },
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: TsSpacing.lg, bottom: TsSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _withGaps(blocks),
        ),
      ),
    );
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

// TODO(data): replace with premiumPickStatsProvider
const _accuracyRecentPicks = <TsRecentPick>[
  TsRecentPick(
    result: TsRecentPickResult.match,
    homeTeamLabel: 'Espanyol',
    awayTeamLabel: 'Levante',
    homeScoreLabel: '2',
    awayScoreLabel: '1',
    pickedTeamLabel: 'Espanyol',
    leagueLabel: 'La Liga',
    leagueIcon: TsLeagueIcon('la_liga', size: TsIconSize.xs),
    dateLabel: '8.14',
  ),
  TsRecentPick(
    result: TsRecentPickResult.mismatch,
    homeTeamLabel: 'Getafe',
    awayTeamLabel: 'Osasuna',
    homeScoreLabel: '0',
    awayScoreLabel: '1',
    pickedTeamLabel: 'Getafe',
    leagueLabel: 'La Liga',
    leagueIcon: TsLeagueIcon('la_liga', size: TsIconSize.xs),
    dateLabel: '8.13',
  ),
  TsRecentPick(
    result: TsRecentPickResult.match,
    homeTeamLabel: 'LA Galaxy',
    awayTeamLabel: 'Seattle',
    homeScoreLabel: '3',
    awayScoreLabel: '2',
    pickedTeamLabel: 'LA Galaxy',
    leagueLabel: 'MLS',
    leagueIcon: TsLeagueIcon('mls', size: TsIconSize.xs),
    dateLabel: '8.12',
  ),
];

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
