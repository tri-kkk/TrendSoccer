import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/soccer_analysis_parser.dart';
import 'package:trendsoccer/features/analysis/models/soccer_match_report_data.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/premium/premium_sections.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/soccer_standard_tab.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/premium/score_box.dart';
import 'package:trendsoccer/shared/widgets/report/match_header.dart';
import 'package:trendsoccer/shared/widgets/report/report_toggle.dart';
import 'package:trendsoccer/shared/widgets/subscribe_sheet.dart';

class SoccerMatchReportPage extends ConsumerStatefulWidget {
  const SoccerMatchReportPage({
    required this.matchId,
    this.matchTimestampUtc,
    super.key,
  });

  final String matchId;
  final DateTime? matchTimestampUtc;

  @override
  ConsumerState<SoccerMatchReportPage> createState() =>
      _SoccerMatchReportPageState();
}

class _SoccerMatchReportPageState extends ConsumerState<SoccerMatchReportPage> {
  ReportTab _selectedTab = ReportTab.standard;

  int? get _numericMatchId => int.tryParse(widget.matchId);

  SoccerMatchReportData get _premiumDummy => soccerMatchReportDummy;

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

  List<H2HMeeting> _h2hMeetings(List<H2HMatchItemData> raw) {
    return raw
        .map(
          (m) => H2HMeeting(
            score: m.score,
            result: _toScoreBoxResult(m.result),
          ),
        )
        .toList();
  }

  Widget _buildPremiumTab(SoccerMatchReportData data) {
    return KeyedSubtree(
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
            const SizedBox(height: 16),
            TeamAnalysisSection(
              title: '홈',
              last10Label: '홈 성적 (최근 10경기)',
              wins: data.homeTeamAnalysis.wins10,
              draws: data.homeTeamAnalysis.draws10,
              losses: data.homeTeamAnalysis.losses10,
              recentForm: _h2hMeetings(data.homeTeamAnalysis.recentForm),
              recordWins: data.homeTeamAnalysis.recordWins,
              recordDraws: data.homeTeamAnalysis.recordDraws,
              recordLosses: data.homeTeamAnalysis.recordLosses,
              winRate: data.homeTeamAnalysis.winRate,
              goalLineO15: data.homeTeamAnalysis.goalLineO15,
              goalLineO15Highlight: data.homeTeamAnalysis.goalLineO15Highlight,
              goalLineO25: data.homeTeamAnalysis.goalLineO25,
              goalLineO25Highlight: data.homeTeamAnalysis.goalLineO25Highlight,
              goalLineO35: data.homeTeamAnalysis.goalLineO35,
              goalLineO35Highlight: data.homeTeamAnalysis.goalLineO35Highlight,
              marketO25: data.homeTeamAnalysis.marketO25,
              marketO25Highlight: data.homeTeamAnalysis.marketO25Highlight,
              marketBtts: data.homeTeamAnalysis.marketBtts,
              marketBttsHighlight: data.homeTeamAnalysis.marketBttsHighlight,
              marketCs: data.homeTeamAnalysis.marketCs,
              marketFts: data.homeTeamAnalysis.marketFts,
              teamInsights: data.homeTeamAnalysis.insights,
            ),
            const SizedBox(height: 16),
            TeamAnalysisSection(
              title: '원정',
              last10Label: '원정 성적 (최근 10경기)',
              wins: data.awayTeamAnalysis.wins10,
              draws: data.awayTeamAnalysis.draws10,
              losses: data.awayTeamAnalysis.losses10,
              recentForm: _h2hMeetings(data.awayTeamAnalysis.recentForm),
              recordWins: data.awayTeamAnalysis.recordWins,
              recordDraws: data.awayTeamAnalysis.recordDraws,
              recordLosses: data.awayTeamAnalysis.recordLosses,
              winRate: data.awayTeamAnalysis.winRate,
              goalLineO15: data.awayTeamAnalysis.goalLineO15,
              goalLineO15Highlight: data.awayTeamAnalysis.goalLineO15Highlight,
              goalLineO25: data.awayTeamAnalysis.goalLineO25,
              goalLineO25Highlight: data.awayTeamAnalysis.goalLineO25Highlight,
              goalLineO35: data.awayTeamAnalysis.goalLineO35,
              goalLineO35Highlight: data.awayTeamAnalysis.goalLineO35Highlight,
              marketO25: data.awayTeamAnalysis.marketO25,
              marketO25Highlight: data.awayTeamAnalysis.marketO25Highlight,
              marketBtts: data.awayTeamAnalysis.marketBtts,
              marketBttsHighlight: data.awayTeamAnalysis.marketBttsHighlight,
              marketCs: data.awayTeamAnalysis.marketCs,
              marketFts: data.awayTeamAnalysis.marketFts,
              teamInsights: data.awayTeamAnalysis.insights,
            ),
            const SizedBox(height: TsSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardTab() {
    final matchId = _numericMatchId;
    if (matchId == null) {
      return SoccerStandardTabError(
        onRetry: () {},
      );
    }

    final analysisAsync = ref.watch(soccerAnalysisProvider(matchId));
    final planType = ref.watch(authProvider).planType;

    return analysisAsync.when(
      loading: () => const KeyedSubtree(
        key: ValueKey<Object>('soccer_report_standard_loading'),
        child: Padding(
          padding: EdgeInsets.all(TsSpacing.lg),
          child: SoccerStandardTabLoading(),
        ),
      ),
      error: (error, stackTrace) => KeyedSubtree(
        key: const ValueKey<Object>('soccer_report_standard_error'),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: SoccerStandardTabError(
            onRetry: () => ref.invalidate(soccerAnalysisProvider(matchId)),
          ),
        ),
      ),
      data: (raw) {
        final parsed = parseSoccerStandardAnalysis(
          raw,
          fallbackMatchTimestamp: widget.matchTimestampUtc,
        );
        return KeyedSubtree(
          key: const ValueKey<Object>('soccer_report_standard'),
          child: Padding(
            padding: const EdgeInsets.all(TsSpacing.lg),
            child: SoccerStandardTabHost(
              parsed: parsed,
              planType: planType,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final premiumData = _premiumDummy;

    final matchId = _numericMatchId;
    final headerParsed = matchId != null
        ? ref.watch(soccerAnalysisProvider(matchId)).maybeWhen(
              data: (raw) => parseSoccerStandardAnalysis(
                raw,
                fallbackMatchTimestamp: widget.matchTimestampUtc,
              ),
              orElse: () => fallbackFromDummy(premiumData),
            )
        : fallbackFromDummy(premiumData);

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: TsAppBar.preferred(
        context,
        location: TsAppBarLocation.backTitle,
        title: '매치 리포트',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: TsSpacing.lg + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          children: [
            MatchHeader(
              leagueId: headerParsed.leagueId,
              matchDate: headerParsed.matchDateDisplay,
              homeTeam: headerParsed.homeTeam,
              awayTeam: headerParsed.awayTeam,
              homeLogoUrl: headerParsed.homeLogoUrl,
              awayLogoUrl: headerParsed.awayLogoUrl,
              selectedTab: _selectedTab,
              onTabChanged: (tab) {
                if (tab == ReportTab.premium) {
                  if (!ref.read(authProvider).hasFullAccess) {
                    showSubscribeSheet(context, SportType.soccer);
                    return;
                  }
                }
                setState(() => _selectedTab = tab);
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _selectedTab == ReportTab.standard
                  ? _buildStandardTab()
                  : _buildPremiumTab(premiumData),
            ),
          ],
        ),
      ),
    );
  }
}
