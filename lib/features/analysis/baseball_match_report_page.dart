import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/baseball_match_report_data.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/premium/premium_sections.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/standard/standard_sections.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/confidence_chip.dart';
import 'package:trendsoccer/shared/widgets/report/match_header.dart';
import 'package:trendsoccer/shared/widgets/report/report_toggle.dart';

class BaseballMatchReportPage extends StatefulWidget {
  const BaseballMatchReportPage({
    required this.matchId,
    super.key,
  });

  final String matchId;

  @override
  State<BaseballMatchReportPage> createState() => _BaseballMatchReportPageState();
}

class _BaseballMatchReportPageState extends State<BaseballMatchReportPage> {
  ReportTab _selectedTab = ReportTab.standard;

  BaseballMatchReportData get _data => baseballMatchReportDummy;

  ConfidenceLevel _toConfidence(String level) {
    switch (level) {
      case 'high':
        return ConfidenceLevel.high;
      case 'medium':
        return ConfidenceLevel.medium;
      case 'low':
        return ConfidenceLevel.low;
      default:
        return ConfidenceLevel.medium;
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
                      key: const ValueKey<Object>('baseball_report_standard'),
                      child: Padding(
                        padding: const EdgeInsets.all(TsSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            StartingPitchersSection(
                              awayPitcher: data.awayPitcher,
                              homePitcher: data.homePitcher,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            PitcherAnalysisSection(paragraphs: data.pitcherAnalysis),
                            const SizedBox(height: TsSpacing.xl),
                            BaseballH2HSection(matches: data.h2hMatches),
                            const SizedBox(height: TsSpacing.xl),
                            BaseballOddsSection(
                              awayOdds: data.awayOdds,
                              homeOdds: data.homeOdds,
                              awayTeam: data.awayTeam,
                              homeTeam: data.homeTeam,
                              overUnderLines: data.ouLines,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                          ],
                        ),
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey<Object>('baseball_report_premium'),
                      child: Padding(
                        padding: const EdgeInsets.all(TsSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            WinProbabilitySection(
                              awayProb: data.awayWinProb,
                              homeProb: data.homeWinProb,
                              awayTeam: data.awayTeam,
                              homeTeam: data.homeTeam,
                              description: data.winProbDescription,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            OverUnderSection(
                              baseLine: data.ouBaseLine,
                              overOdds: data.ouOverOdds,
                              underOdds: data.ouUnderOdds,
                              isFavoredUnder: data.isFavoredUnder,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            HomeAwayRecordSection(
                              awayRecord: data.awayRecord,
                              homeRecord: data.homeRecord,
                              awayTeam: data.awayTeam,
                              homeTeam: data.homeTeam,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            WinRateSection(
                              awayWinRate: data.awayWinRate,
                              homeWinRate: data.homeWinRate,
                              confidence: _toConfidence(data.confidenceLevel),
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            TeamProductionSection(
                              items: data.teamProduction,
                              comment: data.teamProductionComment,
                            ),
                            const SizedBox(height: TsSpacing.xl),
                            SeasonTeamStatsSection(
                              items: data.seasonTeamStats,
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
