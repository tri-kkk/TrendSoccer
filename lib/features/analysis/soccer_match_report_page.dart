import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/premium_models.dart';
import '../../core/models/soccer_match_report.dart';
import '../../core/models/subscription_state.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/subscription_provider.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/component_tokens.dart';
import '../../shared/widgets/appbar/match_report_appbar.dart';
import '../../shared/widgets/navigation/bottom_navigation.dart';
import '../../shared/widgets/report/match_report_header.dart';
import 'widgets/analysis_result_section.dart';
import 'widgets/final_probability_section.dart';
import 'widgets/h2h_section.dart';
import 'widgets/odds_section.dart';
import 'widgets/power_index_section.dart';
import 'widgets/reasoning_section.dart';
import 'widgets/team_analysis_section.dart';
import 'widgets/team_statistics_section.dart';
import 'widgets/three_method_section.dart';

class SoccerMatchReportPage extends ConsumerStatefulWidget {
  const SoccerMatchReportPage({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<SoccerMatchReportPage> createState() =>
      _SoccerMatchReportPageState();
}

class _SoccerMatchReportPageState
    extends ConsumerState<SoccerMatchReportPage> {
  bool _isStandardSelected = true;
  final SoccerMatchReport _report = SoccerMatchReport.dummy();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isBlurred() {
    final now = DateTime.now();
    final diff = _report.matchDateTime.difference(now);
    final status = ref.read(subscriptionProvider);
    if (status.type == SubscriptionType.premium) return diff.inHours >= 24;
    if (status.type == SubscriptionType.free) return diff.inHours >= 2;
    return diff.inHours >= 1; // guest / trial
  }

  String _blurText() {
    final diff = _report.matchDateTime.difference(DateTime.now());
    final status = ref.read(subscriptionProvider);
    final Duration remaining;
    if (status.type == SubscriptionType.premium) {
      remaining = diff - const Duration(hours: 24);
    } else if (status.type == SubscriptionType.free) {
      remaining = diff - const Duration(hours: 2);
    } else {
      remaining = diff - const Duration(hours: 1);
    }
    if (remaining.isNegative) return 'Available now';
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    return 'Opens in ${h}h ${m}m';
  }

  void _onPremiumTap() {
    final status = ref.read(subscriptionProvider);
    if (status.type == SubscriptionType.premium) {
      setState(() => _isStandardSelected = false);
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    _showSubscriptionBottomSheet();
  }

  // ignore: unused_element
  void _showSubscriptionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2120),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF707D7D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Premium Exclusive Content',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF1F7F6),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'H2H · In-depth team analysis\navailable for premium members',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFAACBC4),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/subscribe');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F9A7A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Subscribe Now →',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0A0F0E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1F9A7A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F9A7A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blurred = _isBlurred();
    final blurText = _blurText();

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
              isStandardSelected: _isStandardSelected,
              onStandardTap: () {
                setState(() => _isStandardSelected = true);
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onPremiumTap: () {
                if (_isStandardSelected) _onPremiumTap();
              },
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // ── Page 0: Standard ──────────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        AnalysisResultSection(
                          report: _report,
                          isBlurred: blurred,
                          blurText: blurText,
                        ),
                        ReasoningSection(
                          items: _report.reasoningItems,
                          isBlurred: blurred,
                          blurText: blurText,
                        ),
                        OddsSection(
                          home: _report.homeOdds,
                          draw: _report.drawOdds,
                          away: _report.awayOdds,
                        ),
                        PowerIndexSection(
                          homePower: _report.homePower,
                          awayPower: _report.awayPower,
                          isBlurred: blurred,
                          blurText: blurText,
                        ),
                        FinalProbabilitySection(
                          home: _report.homeProbability,
                          draw: _report.drawProbability,
                          away: _report.awayProbability,
                          isBlurred: blurred,
                          blurText: blurText,
                        ),
                        TeamStatisticsSection(
                          stats: _report.teamStats,
                          isBlurred: blurred,
                          blurText: blurText,
                        ),
                        ThreeMethodSection(
                          methods: _report.methodAnalysis,
                          isBlurred: blurred,
                          blurText: blurText,
                        ),
                      ],
                    ),
                  ),
                  // ── Page 1: Premium ───────────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        H2HSection(
                          homeWins: 8,
                          draws: 7,
                          awayWins: 5,
                          totalMatches: 20,
                          recentScores: const [
                            ScoreData(result: MatchResult.win, homeScore: 1, awayScore: 0),
                            ScoreData(result: MatchResult.draw, homeScore: 1, awayScore: 1),
                            ScoreData(result: MatchResult.lose, homeScore: 0, awayScore: 1),
                            ScoreData(result: MatchResult.draw, homeScore: 1, awayScore: 1),
                            ScoreData(result: MatchResult.lose, homeScore: 0, awayScore: 1),
                          ],
                          avgGoals: 2.7,
                          over25Percent: 60,
                          bttsPercent: 30,
                          mostCommon: const [
                            CommonScore(count: 7, score: '1-0'),
                            CommonScore(count: 2, score: '0-2'),
                            CommonScore(count: 2, score: '4-0'),
                          ],
                          insights: const [
                            'Home team has dominated recent meetings',
                            'Both teams score frequently in this fixture',
                            'Expect goals in this matchup',
                          ],
                        ),
                        TeamAnalysisSection(
                          title: 'Home',
                          wins: 6,
                          draws: 2,
                          loses: 2,
                          recentForm: const [
                            ScoreData(result: MatchResult.win, homeScore: 1, awayScore: 0),
                            ScoreData(result: MatchResult.draw, homeScore: 1, awayScore: 1),
                            ScoreData(result: MatchResult.lose, homeScore: 0, awayScore: 1),
                            ScoreData(result: MatchResult.draw, homeScore: 1, awayScore: 1),
                            ScoreData(result: MatchResult.lose, homeScore: 0, awayScore: 1),
                          ],
                          recordW: 2,
                          recordD: 3,
                          recordL: 5,
                          winPercent: 30,
                          over15: 90,
                          over25: 50,
                          over35: 40,
                          marketO25: 70,
                          marketBTTS: 80,
                          marketCS: 10,
                          marketFTS: 20,
                          insights: const [
                            'Strong home record this season',
                            'Concedes few goals at home',
                            'Key players fit and available',
                          ],
                        ),
                        TeamAnalysisSection(
                          title: 'Away',
                          wins: 2,
                          draws: 3,
                          loses: 5,
                          recentForm: const [
                            ScoreData(result: MatchResult.win, homeScore: 1, awayScore: 0),
                            ScoreData(result: MatchResult.draw, homeScore: 1, awayScore: 1),
                            ScoreData(result: MatchResult.lose, homeScore: 0, awayScore: 1),
                            ScoreData(result: MatchResult.draw, homeScore: 1, awayScore: 1),
                            ScoreData(result: MatchResult.lose, homeScore: 0, awayScore: 1),
                          ],
                          recordW: 2,
                          recordD: 3,
                          recordL: 5,
                          winPercent: 30,
                          over15: 90,
                          over25: 50,
                          over35: 40,
                          marketO25: 70,
                          marketBTTS: 80,
                          marketCS: 10,
                          marketFTS: 20,
                          insights: const [
                            'Struggles on the road',
                            'Weak defensive record away',
                            'Missing key defensive players',
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentTab: NavigationTab.analysis,
        onTabChanged: (tab) => context.go(getRouteFromTab(tab)),
      ),
    );
  }

}
