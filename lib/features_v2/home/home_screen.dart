import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_ai_report_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_h2h_summary.dart';
import 'package:trendsoccer/design_system/widgets/ts_highlight_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_news_hero_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_post_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_preview_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_footer.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_leg_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_match_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_summary_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_accuracy_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_today_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_plan_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/design_system/widgets/ts_stack_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_starting_pitchers_section.dart';

const _lg = 'premier_league';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final leagueIcon = TsLeagueIcon(_lg, size: TsIconSize.xs);
    final comboLeagueIcon = TsLeagueIcon(_lg, size: TsIconSize.md);
    Widget leagueIcon28(String id) => TsLeagueIcon(id, size: 28);
    Widget gap() => const SizedBox(height: TsSpacing.sm);

    return Scaffold(
      backgroundColor: c.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _h(c, 'TsPreviewCard'),
            TsPreviewCard(
              leagueIcon: leagueIcon,
              leagueLabel: 'Premier League',
              dateLabel: 'Aug 14',
              titleLabel: 'Why Arsenal can extend their lead',
              excerptLabel: 'Form, fixtures, and the underlying numbers behind this weekend\'s top pick.',
            ),
            gap(),
            TsPreviewCard(
              leagueIcon: leagueIcon,
              leagueLabel: 'Premier League',
              dateLabel: 'Aug 14',
              titleLabel: 'Premium match breakdown',
              excerptLabel: 'Full AI analysis with method scores and confidence bands.',
              locked: true,
            ),
            _gap24(),
            _h(c, 'TsHighlightCard'),
            TsHighlightCard(
              leagueIcon: leagueIcon,
              metaLabel: 'Premier League · Highlights',
              titleLabel: 'Arsenal 2–1 Chelsea — key moments',
            ),
            gap(),
            TsHighlightCard(
              leagueIcon: leagueIcon,
              metaLabel: 'Premier League · Highlights',
              titleLabel: 'Liverpool 3–0 Spurs — full replay',
              imageUrl: 'https://picsum.photos/640/360',
            ),
            _gap24(),
            _h(c, 'TsNewsHeroCard'),
            const TsNewsHeroCard(
              titleLabel: 'Transfer window winners and losers',
              metaLabel: 'Premier League · 3h ago',
            ),
            _gap24(),
            _h(c, 'TsPostHeader'),
            TsPostHeader(
              authorLabel: 'TrendSoccer Editorial',
              roleLabel: 'Match analysis',
              leagueLogo: TsLeagueLogo(_lg, height: 20),
              dateLabel: 'Aug 14, 2026',
              titleLabel: 'Arsenal vs Chelsea: tactical preview',
            ),
            _gap24(),
            _h(c, 'TsAiReportBlock'),
            TsAiReportBlock(
              titleLabel: 'AI combo report',
              summaryLabel: 'Two-leg accumulator with correlated home edges.',
              cautionLabel: 'Caution',
              caution: 'One leg carries elevated variance from a thin squad rotation.',
              disclaimerLabel: 'AI-generated analysis. Not financial advice.',
              legs: const [
                TsAiReportLeg(label: 'Match 1', body: 'Arsenal home win probability elevated by recent xG trend.'),
                TsAiReportLeg(label: 'Match 2', body: 'Liverpool draw risk lower than market implies.'),
              ],
            ),
            gap(),
            TsAiReportBlock(
              titleLabel: 'AI combo report',
              summaryLabel: 'Three-leg accumulator with correlated home edges.',
              cautionLabel: 'Caution',
              caution: 'One leg carries elevated variance from a thin squad rotation.',
              disclaimerLabel: 'AI-generated analysis. Not financial advice.',
              legs: const [
                TsAiReportLeg(label: 'Match 1', body: 'Arsenal home win probability elevated by recent xG trend.'),
                TsAiReportLeg(label: 'Match 2', body: 'Liverpool draw risk lower than market implies.'),
                TsAiReportLeg(label: 'Match 3', body: 'Tottenham away form supports the underdog line.'),
              ],
            ),
            _gap24(),
            _h(c, 'TsStartingPitchersSection'),
            TsStartingPitchersSection(
              versusLabel: 'vs',
              home: const TsPitcherProfile(
                positionLabel: 'H',
                nameLabel: 'W. Buehler',
                handLabel: 'RHP',
                strengths: ['Elite K rate'],
                weaknesses: ['High pitch count'],
              ),
              away: const TsPitcherProfile(
                positionLabel: 'A',
                nameLabel: 'L. Webb',
                handLabel: 'LHP',
                strengths: ['Ground-ball rate'],
                weaknesses: ['Recent walks'],
              ),
              stats: const [
                TsStatComparison(
                  statLabel: 'ERA',
                  homeValueLabel: '3.24',
                  awayValueLabel: '3.88',
                  homeFraction: 0.55,
                ),
                TsStatComparison(
                  statLabel: 'WHIP',
                  homeValueLabel: '1.08',
                  awayValueLabel: '1.21',
                  homeFraction: 0.53,
                ),
                TsStatComparison(
                  statLabel: 'K/9',
                  homeValueLabel: '9.6',
                  awayValueLabel: '8.2',
                  homeFraction: 0.54,
                ),
              ],
              prevSeasonTitleLabel: 'Previous season',
              prevSeasonSummaryLabel: 'ERA 3.40 vs 3.05',
              prevSeasonStats: const [
                TsStatComparison(
                  statLabel: 'ERA',
                  homeValueLabel: '3.40',
                  awayValueLabel: '3.05',
                  homeFraction: 0.52,
                ),
              ],
            ),
            gap(),
            TsStartingPitchersSection(
              versusLabel: 'vs',
              home: const TsPitcherProfile(
                positionLabel: 'H',
                nameLabel: 'S. Ohtani',
                handLabel: 'RHP',
              ),
              away: const TsPitcherProfile(
                positionLabel: 'A',
                nameLabel: 'G. Cole',
                handLabel: 'RHP',
              ),
              stats: const [
                TsStatComparison(
                  statLabel: 'ERA',
                  homeValueLabel: '2.85',
                  awayValueLabel: '3.10',
                  homeFraction: 0.56,
                ),
              ],
            ),
            _gap24(),
            _h(c, 'TsH2HSummary'),
            TsH2HSummary(
              line: TsStackLine.threeWay,
              homeValueLabel: '5',
              drawValueLabel: '2',
              awayValueLabel: '3',
              homeFraction: 0.5,
              drawFraction: 0.2,
              awayFraction: 0.3,
              homeLabel: 'Arsenal wins',
              drawLabel: 'Draws',
              awayLabel: 'Chelsea wins',
              detailTitleLabel: 'Recent meetings',
              meetings: const [
                TsH2HMeeting(
                  dateLabel: '2024.03.10',
                  homeTeamLabel: 'Arsenal',
                  awayTeamLabel: 'Chelsea',
                  scoreLabel: '2 : 0',
                ),
                TsH2HMeeting(
                  dateLabel: '2023.11.05',
                  homeTeamLabel: 'Chelsea',
                  awayTeamLabel: 'Arsenal',
                  scoreLabel: '1 : 1',
                ),
              ],
            ),
            gap(),
            TsH2HSummary(
              line: TsStackLine.twoWay,
              homeValueLabel: '12',
              awayValueLabel: '8',
              homeFraction: 0.6,
              awayFraction: 0.4,
              homeLabel: 'Yankees wins',
              awayLabel: 'Red Sox wins',
              detailTitleLabel: 'Recent meetings',
              meetings: const [
                TsH2HMeeting(
                  dateLabel: '2024.06.02',
                  homeTeamLabel: 'Yankees',
                  awayTeamLabel: 'Red Sox',
                  scoreLabel: '6 : 4',
                ),
              ],
            ),
            _gap24(),
            _h(c, 'TsComboCard'),
            TsComboCard(
              leagueIcon: comboLeagueIcon,
              leagueLabel: 'Premier League',
              typeBadgeLabel: 'Stable',
              totalIndexLabel: '2.78',
              confidenceLabel: '60%',
              result: TsComboOutcome.hit,
              legs: const [
                TsComboLeg(
                  pick: TsComboPick.home,
                  homeTeamLabel: 'Arsenal',
                  awayTeamLabel: 'Chelsea',
                  timeLabel: 'FT',
                  scoreLabel: '2 : 1',
                  pickTextLabel: 'Arsenal win',
                  indexLabel: '1.58',
                  probabilityLabel: '62%',
                  probability: 0.62,
                  reasonLabel: 'Index prob 61%, home form edge',
                ),
                TsComboLeg(
                  pick: TsComboPick.away,
                  homeTeamLabel: 'Liverpool',
                  awayTeamLabel: 'Spurs',
                  timeLabel: 'FT',
                  scoreLabel: '3 : 0',
                  pickTextLabel: 'Spurs win',
                  indexLabel: '1.42',
                  probabilityLabel: '55%',
                  probability: 0.55,
                ),
              ],
              aiReport: TsAiReportData(
                titleLabel: 'AI combo report',
                summaryLabel: 'Two-leg accumulator with correlated home edges.',
                cautionLabel: 'Caution',
                caution: 'One leg carries elevated variance from a thin squad rotation.',
                disclaimerLabel: 'AI-generated analysis. Not financial advice.',
                legs: const [
                  TsAiReportLeg(
                    label: 'Match 1',
                    body: 'Arsenal home win probability elevated by recent xG trend.',
                  ),
                  TsAiReportLeg(
                    label: 'Match 2',
                    body: 'Spurs away form supports the underdog line.',
                  ),
                ],
              ),
            ),
            gap(),
            TsComboCard(
              leagueIcon: comboLeagueIcon,
              leagueLabel: 'Premier League',
              typeBadgeLabel: 'Stable',
              totalIndexLabel: '3.12',
              confidenceLabel: '58%',
              result: TsComboOutcome.pending,
              legs: const [
                TsComboLeg(
                  pick: TsComboPick.home,
                  homeTeamLabel: 'Arsenal',
                  awayTeamLabel: 'Chelsea',
                  timeLabel: '19:00',
                  scoreLabel: '— : —',
                  pickTextLabel: 'Arsenal win',
                  indexLabel: '1.58',
                  probabilityLabel: '62%',
                  probability: 0.62,
                ),
                TsComboLeg(
                  pick: TsComboPick.home,
                  homeTeamLabel: 'Liverpool',
                  awayTeamLabel: 'Spurs',
                  timeLabel: '19:00',
                  scoreLabel: '— : —',
                  pickTextLabel: 'Liverpool win',
                  indexLabel: '1.45',
                  probabilityLabel: '58%',
                  probability: 0.58,
                ),
                TsComboLeg(
                  pick: TsComboPick.away,
                  homeTeamLabel: 'Man City',
                  awayTeamLabel: 'Newcastle',
                  timeLabel: '19:00',
                  scoreLabel: '— : —',
                  pickTextLabel: 'Newcastle win',
                  indexLabel: '1.72',
                  probabilityLabel: '51%',
                  probability: 0.51,
                ),
              ],
            ),
            gap(),
            TsComboCard(
              leagueIcon: comboLeagueIcon,
              leagueLabel: 'MLB',
              typeBadgeLabel: 'Stable',
              totalIndexLabel: '2.45',
              confidenceLabel: '55%',
              result: TsComboOutcome.partial,
              legs: const [
                TsComboLeg(
                  pick: TsComboPick.home,
                  homeTeamLabel: 'Yankees',
                  awayTeamLabel: 'Red Sox',
                  timeLabel: 'FT',
                  scoreLabel: '6 : 4',
                  pickTextLabel: 'Yankees win',
                  indexLabel: '1.38',
                  probabilityLabel: '64%',
                  probability: 0.64,
                ),
                TsComboLeg(
                  pick: TsComboPick.away,
                  homeTeamLabel: 'Dodgers',
                  awayTeamLabel: 'Giants',
                  timeLabel: 'FT',
                  scoreLabel: '2 : 5',
                  pickTextLabel: 'Giants win',
                  indexLabel: '1.55',
                  probabilityLabel: '57%',
                  probability: 0.57,
                ),
              ],
            ),
            _gap24(),
            _h(c, 'TsComboSummaryCard'),
            TsComboSummaryCard(
              leagueIcon: comboLeagueIcon,
              leagueLabel: 'Premier League',
              typeBadgeLabel: 'Stable',
              totalIndexLabel: '2.78',
              confidenceLabel: '60%',
              matchups: const [
                TsComboMatchup(
                  homeTeamLabel: 'Arsenal',
                  awayTeamLabel: 'Chelsea',
                  homeScoreLabel: '2',
                  awayScoreLabel: '1',
                  timeLabel: 'FT',
                  result: TsComboResult.hit,
                ),
                TsComboMatchup(
                  homeTeamLabel: 'Liverpool',
                  awayTeamLabel: 'Spurs',
                  homeScoreLabel: '3',
                  awayScoreLabel: '0',
                  timeLabel: 'FT',
                  result: TsComboResult.hit,
                ),
              ],
            ),
            gap(),
            TsComboSummaryCard(
              leagueIcon: comboLeagueIcon,
              leagueLabel: 'Premier League',
              typeBadgeLabel: 'Stable',
              totalIndexLabel: '3.12',
              confidenceLabel: '58%',
              matchups: const [
                TsComboMatchup(
                  homeTeamLabel: 'Arsenal',
                  awayTeamLabel: 'Chelsea',
                  homeScoreLabel: '2',
                  awayScoreLabel: '1',
                  timeLabel: 'FT',
                  result: TsComboResult.hit,
                ),
                TsComboMatchup(
                  homeTeamLabel: 'Liverpool',
                  awayTeamLabel: 'Spurs',
                  homeScoreLabel: '1',
                  awayScoreLabel: '1',
                  timeLabel: 'FT',
                  result: TsComboResult.miss,
                ),
                TsComboMatchup(
                  homeTeamLabel: 'Man City',
                  awayTeamLabel: 'Newcastle',
                  homeScoreLabel: '4',
                  awayScoreLabel: '2',
                  timeLabel: 'FT',
                  result: TsComboResult.hit,
                ),
              ],
            ),
            gap(),
            TsComboSummaryCard(
              leagueIcon: comboLeagueIcon,
              leagueLabel: 'Premier League',
              typeBadgeLabel: 'Stable',
              totalIndexLabel: '2.78',
              confidenceLabel: '60%',
              locked: true,
              matchups: const [
                TsComboMatchup(
                  homeTeamLabel: 'Arsenal',
                  awayTeamLabel: 'Chelsea',
                  homeScoreLabel: '2',
                  awayScoreLabel: '1',
                  timeLabel: 'FT',
                  result: TsComboResult.hit,
                ),
                TsComboMatchup(
                  homeTeamLabel: 'Liverpool',
                  awayTeamLabel: 'Spurs',
                  homeScoreLabel: '3',
                  awayScoreLabel: '0',
                  timeLabel: 'FT',
                  result: TsComboResult.hit,
                ),
              ],
            ),
            _gap24(),
            _h(c, 'TsComboTodayCard'),
            TsComboTodayCard(
              countValue: '3',
              countLabel: 'Combos today',
              leagues: [
                TsComboLeagueCount(icon: leagueIcon28('mlb'), countLabel: '3'),
              ],
              stableLabel: 'Stable',
              aggressiveLabel: 'Aggressive',
              stableValueLabel: '2',
              aggressiveValueLabel: '1',
              stableFraction: 0.67,
              accuracyLabel: 'Est. accuracy 58% based on last 30 days',
              ctaLabel: 'View combos',
              onCtaPressed: () {},
            ),
            _gap24(),
            _h(c, 'TsPlanCard'),
            const TsPlanCard(
              tier: TsPlanTier.free,
              titleLabel: 'Free',
              benefits: [
                'Basic match analysis',
                'Limited combo picks',
                'Standard accuracy stats',
                'Community support',
              ],
            ),
            gap(),
            const TsPlanCard(
              tier: TsPlanTier.premium,
              titleLabel: 'Premium',
              benefits: [
                'Full AI match reports',
                'Unlimited combo picks',
                'Advanced accuracy tracking',
                'Priority notifications',
                'Exclusive premium content',
              ],
            ),
            _gap24(),
            _h(c, 'TsAccuracyCard'),
            _AccuracyGallery(leagueIcon28: leagueIcon28),
          ],
        ),
      ),
    );
  }
}

Widget _h(TsThemeColors c, String t) =>
    Text(t, style: TsType.h3.copyWith(color: c.textPrimary));

Widget _gap24() => const SizedBox(height: TsSpacing.xl);

List<TsRecentPick> _accuracyRecentPicks(Widget Function(String) leagueIcon28) =>
    [
      TsRecentPick(
        result: TsRecentPickResult.match,
        homeTeamLabel: 'Arsenal',
        awayTeamLabel: 'Chelsea',
        homeScoreLabel: '2',
        awayScoreLabel: '1',
        pickedTeamLabel: 'Arsenal',
        leagueLabel: 'EPL',
        leagueIcon: leagueIcon28('premier_league'),
        dateLabel: '8.11',
      ),
      TsRecentPick(
        result: TsRecentPickResult.mismatch,
        homeTeamLabel: 'Liverpool',
        awayTeamLabel: 'Spurs',
        homeScoreLabel: '1',
        awayScoreLabel: '3',
        pickedTeamLabel: 'Liverpool',
        leagueLabel: 'EPL',
        leagueIcon: leagueIcon28('premier_league'),
        dateLabel: '8.10',
      ),
      TsRecentPick(
        result: TsRecentPickResult.match,
        homeTeamLabel: 'Man City',
        awayTeamLabel: 'Newcastle',
        homeScoreLabel: '4',
        awayScoreLabel: '0',
        pickedTeamLabel: 'Man City',
        leagueLabel: 'EPL',
        leagueIcon: leagueIcon28('premier_league'),
        dateLabel: '8.09',
      ),
    ];

class _AccuracyGallery extends StatefulWidget {
  const _AccuracyGallery({required this.leagueIcon28});

  final Widget Function(String) leagueIcon28;

  @override
  State<_AccuracyGallery> createState() => _AccuracyGalleryState();
}

class _AccuracyGalleryState extends State<_AccuracyGallery> {
  TsSport _sport = TsSport.soccer;
  TsAccuracyPeriod _period = TsAccuracyPeriod.d30;
  TsAccuracyPeriod _baseballPeriod = TsAccuracyPeriod.d30;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final recent = _accuracyRecentPicks(widget.leagueIcon28);
    final isSoccer = _sport == TsSport.soccer;
    final is7d = _period == TsAccuracyPeriod.d7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selected period: ${is7d ? '7D' : '30D'}',
          style: TsType.bodyMMedium.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        TsAccuracyCard(
          titleLabel: 'Pick accuracy',
          period7Label: '7D',
          period30Label: '30D',
          onPeriodChanged: (period) => setState(() => _period = period),
          sport: _sport,
          onSportChanged: (sport) => setState(() => _sport = sport),
          valueLabel: isSoccer
              ? (is7d ? '48%' : '53%')
              : (is7d ? '41%' : '48%'),
          winLossLabel: isSoccer
              ? (is7d ? '112W · 118L' : '154W · 136L')
              : (is7d ? '38W · 47L' : '92W · 98L'),
          accuracyFraction: isSoccer
              ? (is7d ? 0.48 : 0.53)
              : (is7d ? 0.41 : 0.48),
          baselineFraction: isSoccer ? 0.33 : 0.50,
          sampleLabel: isSoccer
              ? (is7d ? 'n=148' : 'n=290')
              : (is7d ? 'n=85' : 'n=190'),
          baselineNoteLabel: isSoccer
              ? 'Baseline 33% (random 3-way pick)'
              : 'Baseline 50% (random 2-way pick)',
          streakLabel: '3W streak',
          nextUpdateLabel: 'Next update in 2h',
          recentPicks: recent,
          recentLabel: 'Recent picks',
          seeAllLabel: 'See all',
          onSeeAllPressed: () {},
        ),
        const SizedBox(height: TsSpacing.sm),
        TsAccuracyCard(
          titleLabel: 'Pick accuracy',
          period7Label: '7D',
          period30Label: '30D',
          sport: TsSport.soccer,
          valueLabel: '53%',
          winLossLabel: '154W · 136L',
          accuracyFraction: 0.53,
          baselineFraction: 0.33,
          sampleLabel: 'n=290',
          baselineNoteLabel: 'Baseline 33% (random 3-way pick)',
          streakLabel: '3W streak',
          nextUpdateLabel: 'Next update in 2h',
        ),
        const SizedBox(height: TsSpacing.sm),
        TsAccuracyCard(
          titleLabel: 'Pick accuracy',
          period7Label: '7D',
          period30Label: '30D',
          sport: TsSport.baseball,
          onPeriodChanged: (period) => setState(() => _baseballPeriod = period),
          onSportChanged: (_) {},
          valueLabel: _baseballPeriod == TsAccuracyPeriod.d7 ? '41%' : '48%',
          winLossLabel: _baseballPeriod == TsAccuracyPeriod.d7
              ? '38W · 47L'
              : '92W · 98L',
          accuracyFraction:
              _baseballPeriod == TsAccuracyPeriod.d7 ? 0.41 : 0.48,
          baselineFraction: 0.50,
          sampleLabel:
              _baseballPeriod == TsAccuracyPeriod.d7 ? 'n=85' : 'n=190',
          baselineNoteLabel: 'Baseline 50% (random 2-way pick)',
          streakLabel: '2L streak',
          nextUpdateLabel: 'Next update in 2h',
          recentPicks: recent,
          recentLabel: 'Recent picks',
          seeAllLabel: 'See all',
          onSeeAllPressed: () {},
        ),
      ],
    );
  }
}
