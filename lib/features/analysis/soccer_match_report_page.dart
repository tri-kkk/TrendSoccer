import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/soccer_match_report_data.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/premium/premium_sections.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/standard_sections.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/premium/circle_badge.dart';
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

  MatchResult _toMatchResult(String result) {
    switch (result) {
      case 'win':
        return MatchResult.win;
      case 'draw':
        return MatchResult.draw;
      case 'lose':
        return MatchResult.lose;
      default:
        return MatchResult.draw;
    }
  }

  String _probLabel(double p) => '${(p * 100).round()}%';

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
                              homeProbLabel: _probLabel(data.homeProb),
                              drawProbLabel: _probLabel(data.drawProb),
                              awayProbLabel: _probLabel(data.awayProb),
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
                            ThreeMethodSection(
                              paResult: data.paResult,
                              minMaxResult: data.minMaxResult,
                              firstGoalResult: data.firstGoalResult,
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
                              homeWins: data.h2hHomeWins,
                              draws: data.h2hDraws,
                              awayWins: data.h2hAwayWins,
                              recentMatches: data.h2hMatches
                                  .map(
                                    (m) => H2HMatchData(
                                      result: _toMatchResult(m.result),
                                      score: m.score,
                                    ),
                                  )
                                  .toList(),
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
