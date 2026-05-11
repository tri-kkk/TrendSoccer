import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/soccer_match_report_data.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/premium/premium_sections.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/standard_sections.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/premium/score_box.dart';
import 'package:trendsoccer/shared/widgets/report/match_header.dart';
import 'package:trendsoccer/shared/widgets/report/report_toggle.dart';

class SoccerMatchReportPage extends StatefulWidget {
  const SoccerMatchReportPage({
    required this.matchId,
    super.key,
  });

  final String matchId;

  @override
  State<SoccerMatchReportPage> createState() => _SoccerMatchReportPageState();
}

class _SoccerMatchReportPageState extends State<SoccerMatchReportPage> {
  ReportTab _selectedTab = ReportTab.standard;

  SoccerMatchReportData get _data => soccerMatchReportDummy;

  ScoreBoxResult _toScoreBoxResult(String result) {
    switch (result) {
      case 'win':
        return ScoreBoxResult.win;
      case 'draw':
        return ScoreBoxResult.draw;
      case 'lose':
        return ScoreBoxResult.lose;
      default:
        return ScoreBoxResult.draw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final data = _data;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: TsAppBar(
        location: TsAppBarLocation.backTitle,
        title: '매치 리포트',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MatchHeader(
              leagueId: data.leagueId,
              matchDate: data.matchDate,
              homeTeam: data.homeTeam,
              awayTeam: data.awayTeam,
              homeLogoUrl: data.homeLogoUrl,
              awayLogoUrl: data.awayLogoUrl,
              selectedTab: _selectedTab,
              onTabChanged: (tab) => setState(() => _selectedTab = tab),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _selectedTab == ReportTab.standard
                  ? KeyedSubtree(
                      key: const ValueKey<Object>('soccer_report_standard'),
                      child: Padding(
                        padding: const EdgeInsets.all(TsSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AnalysisResultSection(
                              prediction: data.prediction,
                              winProbability: data.winProbability,
                              powerDiff: data.powerDiff,
                              analyzedMatches: data.analyzedMatches,
                              patternStats: data.patternStats,
                              gradeBadgeType: data.gradeBadge,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            ReasoningSection(items: data.reasoningItems),
                            const SizedBox(height: TsSpacing.xl),
                            OddsSection(
                              homeOdds: data.homeOdds,
                              drawOdds: data.drawOdds,
                              awayOdds: data.awayOdds,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            PowerIndexSection(homeRatio: data.homePowerRatio),
                            const SizedBox(height: TsSpacing.xl),
                            FinalProbabilitySection(
                              homeProb: data.homeProb,
                              drawProb: data.drawProb,
                              awayProb: data.awayProb,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            TeamStatisticsSection(
                              stats: data.teamStats
                                  .map(
                                    (s) => TeamStatItem(
                                      label: s.label,
                                      homeValue: s.homeValue,
                                      awayValue: s.awayValue,
                                      homeDisplay: s.homeDisplay,
                                      awayDisplay: s.awayDisplay,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            ThreeMethodAnalysisSection(
                              paPercent:
                                  '${(data.paHomeRatio * 100).round()}%',
                              paHomeRatio: data.paHomeRatio,
                              minMaxPercent:
                                  '${(data.minMaxHomeRatio * 100).round()}%',
                              minMaxHomeRatio: data.minMaxHomeRatio,
                              firstGoalPercent:
                                  '${(data.firstGoalHomeRatio * 100).round()}%',
                              firstGoalHomeRatio: data.firstGoalHomeRatio,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                          ],
                        ),
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey<Object>('soccer_report_premium'),
                      child: Padding(
                        padding: const EdgeInsets.all(TsSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            H2HSection(
                              totalMatches: data.h2hTotalMatches,
                              homeWins: data.h2hHomeWins,
                              draws: data.h2hDraws,
                              awayWins: data.h2hAwayWins,
                              recentMeetings: data.h2hMatches
                                  .map(
                                    (m) => H2HMeeting(
                                      score: m.score,
                                      result: _toScoreBoxResult(m.result),
                                    ),
                                  )
                                  .toList(),
                              avgGoals: data.h2hAvgGoals,
                              over25: data.h2hOver25,
                              over25Highlight: data.h2hOver25Highlight,
                              btts: data.h2hBtts,
                              mostCommonScores: data.h2hMostCommonScores
                                  .map(
                                    (e) => MostCommonScore(
                                      count: e.count,
                                      score: e.score,
                                    ),
                                  )
                                  .toList(),
                              insights: data.h2hInsights,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            TeamAnalysisSection(
                              teamName: data.homeAnalysis.teamName,
                              overallForm: data.homeAnalysis.overallForm,
                              homeAwayForm: data.homeAnalysis.homeAwayForm,
                              goalStats: data.homeAnalysis.goalStats,
                              recentResults: data.homeAnalysis.recentResults,
                              strengthText: data.homeAnalysis.strengthText,
                              weaknessText: data.homeAnalysis.weaknessText,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            TeamAnalysisSection(
                              teamName: data.awayAnalysis.teamName,
                              overallForm: data.awayAnalysis.overallForm,
                              homeAwayForm: data.awayAnalysis.homeAwayForm,
                              goalStats: data.awayAnalysis.goalStats,
                              recentResults: data.awayAnalysis.recentResults,
                              strengthText: data.awayAnalysis.strengthText,
                              weaknessText: data.awayAnalysis.weaknessText,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                          ],
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
