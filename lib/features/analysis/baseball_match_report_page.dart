import 'package:flutter/material.dart' hide Badge;
import 'package:go_router/go_router.dart';

import '../../core/models/baseball_match_report.dart';
import '../../core/models/baseball_premium_data.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../shared/widgets/appbar/match_report_appbar.dart';
import '../../shared/widgets/badge/badge.dart';
import '../../shared/widgets/report/match_report_header.dart';
import 'widgets/baseball/baseball_h2h_section.dart';
import 'widgets/baseball/baseball_odds_section.dart';
import 'widgets/baseball/home_away_record_section.dart';
import 'widgets/baseball/over_under_section.dart';
import 'widgets/baseball/pitcher_analysis_section.dart';
import 'widgets/baseball/season_team_stats_section.dart';
import 'widgets/baseball/starting_pitchers_section.dart';
import 'widgets/baseball/team_production_section.dart';
import 'widgets/baseball/win_probability_section.dart';
import 'widgets/baseball/win_rate_section.dart';

/// Baseball match report (Standard / Premium tabs).
class BaseballMatchReportPage extends StatefulWidget {
  const BaseballMatchReportPage({super.key, required this.matchId});

  /// Route / query parameter; used when wiring real data.
  final String matchId;

  @override
  State<BaseballMatchReportPage> createState() =>
      _BaseballMatchReportPageState();
}

class _BaseballMatchReportPageState extends State<BaseballMatchReportPage> {
  int _selectedTab = 0;

  late final BaseballMatchReport _report;

  @override
  void initState() {
    super.initState();
    _report = _dummyReport(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            MatchReportAppBar(onBackPressed: () => context.pop()),
            MatchReportHeader(
              homeTeam: _report.homeTeam,
              awayTeam: _report.awayTeam,
              leagueId: _report.leagueId,
              matchDateTime: _report.matchDateTime,
              isStandardSelected: _selectedTab == 0,
              onStandardTap: () => setState(() => _selectedTab = 0),
              onPremiumTap: () => setState(() => _selectedTab = 1),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        final offsetAnimation =
                            Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                            );
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                  child: _selectedTab == 0
                      ? Container(
                          key: const ValueKey('standard'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: AppSpacing.xl,
                            children: [
                              StartingPitchersSection(
                                leagueId: _report.leagueId,
                                awayPitcher: _report.awayPitcher,
                                homePitcher: _report.homePitcher,
                              ),
                              PitcherAnalysisSection(
                                paragraphs: _report.pitcherAnalysis,
                              ),
                              BaseballH2hSection(records: _report.h2hRecords),
                              BaseballOddsSection(
                                awayWinOdds: _report.awayWinOdds,
                                homeWinOdds: _report.homeWinOdds,
                                oddsLines: _report.oddsLines,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          key: const ValueKey('premium'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: AppSpacing.xl,
                            children: [
                              // TODO: Add subscription check - show bottom sheet for non-subscribers
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'AI Analysis',
                                    style: AppTypography.titleLarge.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Badge(type: _dummyPremiumData.pickGrade),
                                ],
                              ),
                              WinProbabilitySection(
                                winProbability:
                                    _dummyPremiumData.winProbability,
                              ),
                              OverUnderSection(
                                overUnder: _dummyPremiumData.overUnder,
                              ),
                              HomeAwayRecordSection(
                                homeAwayRecord:
                                    _dummyPremiumData.homeAwayRecord,
                              ),
                              WinRateSection(
                                winRate: _dummyPremiumData.winRate,
                              ),
                              TeamProductionSection(
                                teamProduction:
                                    _dummyPremiumData.teamProduction,
                              ),
                              SeasonTeamStatsSection(
                                seasonStats: _dummyPremiumData.seasonStats,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BaseballMatchReport _dummyReport(String matchId) {
  final id = matchId.isEmpty ? 'baseball-001' : matchId;
  final isMlb = id.toLowerCase().contains('mlb');

  final awayPitcher = PitcherData(
    name: 'Peter Lambert',
    team: 'away',
    handedness: 'Right-hand',
    currentSeason: true,
    era: 7.20,
    whip: 1.60,
    k9: 14.4,
    wl: '1-0',
    ip: 5.0,
    k: 8,
    positiveComments: const [
      'High K/9 rate',
      'Low walk rate',
      'Flashed impressive stuff',
    ],
    negativeComments: const ['Hit hard in zone', 'Command issues', 'High ERA'],
    imageUrl: isMlb
        ? 'https://picsum.photos/seed/pitcher-lambert/400/400'
        : null,
  );

  final homePitcher = PitcherData(
    name: 'Tanner Bibee',
    team: 'home',
    handedness: 'Left-hand',
    currentSeason: true,
    era: 4.81,
    whip: 1.40,
    k9: 8.5,
    wl: '2-2',
    ip: 24.1,
    k: 23,
    positiveComments: const [
      'Deeper experience',
      'Good strikeout stuff',
      'Consistent velocity',
    ],
    negativeComments: const [
      'Struggling with consistency',
      'Elevated ERA',
      'Control lapses',
    ],
    imageUrl: isMlb ? 'https://picsum.photos/seed/pitcher-bibee/400/400' : null,
  );

  const pitcherAnalysis = [
    'Lambert leans on swing-and-miss secondaries when ahead in the count, but contact quality has been loud when he works in the heart of the zone. Bibee offers a longer track record of turning lineups over even when the box score is uneven.',
    'The strikeout upside for Lambert is real—his K/9 sits well above league average—but walk and hard-hit spikes have inflated his ERA early. Bibee’s WHIP profile suggests steadier traffic management, with more innings to absorb variance.',
    'From a sequencing standpoint, expect both pitchers to prioritize early strikes; the side that wins the first-pitch battle is likelier to shorten innings. Bullpen length behind each starter could matter if either labors through the order a second time.',
    'Weather and park factors aside, this matchup tilts on command in leverage counts: Lambert must limit barrels on fastballs in play, while Bibee’s focus will be finishing hitters before deep counts stack pressure on his off-speed.',
  ];

  final h2hRecords = [
    const H2HRecord(
      date: '4.22',
      awayTeam: 'Samsung Lions',
      homeTeam: 'Doosan Bears',
      awayScore: 5,
      homeScore: 3,
      winner: 'away',
    ),
    const H2HRecord(
      date: '4.15',
      awayTeam: 'Doosan Bears',
      homeTeam: 'Samsung Lions',
      awayScore: 2,
      homeScore: 4,
      winner: 'home',
    ),
    const H2HRecord(
      date: '4.08',
      awayTeam: 'Samsung Lions',
      homeTeam: 'Doosan Bears',
      awayScore: 1,
      homeScore: 6,
      winner: 'home',
    ),
    const H2HRecord(
      date: '3.29',
      awayTeam: 'Doosan Bears',
      homeTeam: 'Samsung Lions',
      awayScore: 7,
      homeScore: 7,
      winner: null,
    ),
    const H2HRecord(
      date: '3.22',
      awayTeam: 'Samsung Lions',
      homeTeam: 'Doosan Bears',
      awayScore: 0,
      homeScore: 2,
      winner: 'home',
    ),
  ];

  final oddsLines = [
    const OddsLineData(
      line: '7.5',
      isBaseLine: false,
      overOdds: '1.81',
      underOdds: '2.06',
    ),
    const OddsLineData(
      line: '8',
      isBaseLine: true,
      overOdds: '1.90',
      underOdds: '1.95',
    ),
    const OddsLineData(
      line: '8.5',
      isBaseLine: false,
      overOdds: '2.02',
      underOdds: '1.82',
    ),
  ];

  return BaseballMatchReport(
    matchId: id,
    leagueId: isMlb ? 'MLB' : 'KBO',
    homeTeam: isMlb ? 'Yankees' : 'Doosan Bears',
    awayTeam: isMlb ? 'Red Sox' : 'Samsung Lions',
    matchDateTime: DateTime(2025, 4, 14, 20),
    awayPitcher: awayPitcher,
    homePitcher: homePitcher,
    pitcherAnalysis: pitcherAnalysis,
    h2hRecords: h2hRecords,
    awayWinOdds: '2.20',
    homeWinOdds: '1.71',
    oddsLines: oddsLines,
  );
}

/// Premium tab placeholder data until API wiring.
const BaseballPremiumData _dummyPremiumData = BaseballPremiumData(
  pickGrade: 'PICK',
  winProbability: WinProbability(
    awayWinPercent: '45.5%',
    homeWinPercent: '54.5%',
    description:
        'Home team shows stronger recent performance with 60% win rate in last 10 games. Away team struggling on the road with only 40% success rate.',
  ),
  overUnder: OverUnder(
    baseLine: 'Line 8',
    overPercent: '48.5%',
    underPercent: '51.5%',
    favoredSide: 'under',
  ),
  homeAwayRecord: HomeAwayRecord(awayWinPercent: '40%', homeWinPercent: '60%'),
  winRate: WinRateData(
    awayWinPercent: '50%',
    homeWinPercent: '50%',
    confidence: 'High',
  ),
  teamProduction: TeamProductionData(
    runs: GaugeStat(awayValue: '4.5', homeValue: '5.2', awayRatio: 0.46),
    allowed: GaugeStat(awayValue: '4.8', homeValue: '4.2', awayRatio: 0.53),
    hits: GaugeStat(awayValue: '8.5', homeValue: '9.1', awayRatio: 0.48),
    summary:
        'Home team averaging more runs per game with stronger offensive production',
  ),
  seasonStats: SeasonTeamStatsData(
    avg: GaugeStat(awayValue: '0.265', homeValue: '0.289', awayRatio: 0.48),
    ops: GaugeStat(awayValue: '0.745', homeValue: '0.812', awayRatio: 0.48),
    era: GaugeStat(awayValue: '4.21', homeValue: '3.85', awayRatio: 0.52),
    whip: GaugeStat(awayValue: '1.35', homeValue: '1.22', awayRatio: 0.53),
  ),
);
