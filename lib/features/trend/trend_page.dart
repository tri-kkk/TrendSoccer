import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/trend/trend_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/banner/ts_banner.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_card.dart';
import 'package:trendsoccer/shared/widgets/cards/today_combo_card.dart';
import 'package:trendsoccer/shared/widgets/icons/sports_icon.dart';

class TrendPage extends StatefulWidget {
  const TrendPage({super.key});

  @override
  State<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  static const int _bannerCount = 3;
  static const double _analysisCardViewportFraction = 0.96;

  late final PageController _bannerController;
  late final PageController _soccerCardsPageController;
  late final PageController _baseballCardsPageController;
  Timer? _bannerTimer;
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 1.0);
    _soccerCardsPageController =
        PageController(viewportFraction: _analysisCardViewportFraction);
    _baseballCardsPageController =
        PageController(viewportFraction: _analysisCardViewportFraction);
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerController.hasClients) {
        return;
      }
      final next = (_currentBannerPage + 1) % _bannerCount;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _soccerCardsPageController.dispose();
    _baseballCardsPageController.dispose();
    super.dispose();
  }

  Widget _buildEventBanner() {
    final bannerSize = MediaQuery.sizeOf(context).width - 32;
    return SizedBox(
      height: bannerSize,
      child: PageView.builder(
        controller: _bannerController,
        onPageChanged: (index) {
          setState(() => _currentBannerPage = index);
        },
        itemCount: _bannerCount,
        itemBuilder: (context, index) {
          return const TsBanner(type: TsBannerType.event);
        },
      ),
    );
  }

  Widget _buildBannerIndicator() {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _bannerCount; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          i == _currentBannerPage
              ? Container(
                  width: 20,
                  height: 6,
                  decoration: BoxDecoration(
                    color: TsColors.brandPrimary500,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )
              : Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: semantic.textDisabled,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required SportType sportType,
    required String title,
    VoidCallback? onMoreTap,
  }) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              TsSportsIcon(
                sport: sportType,
                size: 32,
                fill: SportsIconFill.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onMoreTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            '더 보기 →',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildSoccerCards() {
    final soccerDummy = soccerAnalysisDummy;
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _soccerCardsPageController,
        padEnds: false,
        itemCount: soccerDummy.length,
        itemBuilder: (context, index) {
          final data = soccerDummy[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: AnalysisCard(
                leagueId: data.leagueId,
                leagueName: data.leagueName,
                date: data.date,
                homeTeam: data.homeTeam,
                awayTeam: data.awayTeam,
                matchTime: data.matchTime,
                homeLogoUrl: data.homeLogoUrl,
                awayLogoUrl: data.awayLogoUrl,
                isPremiumPick: false,
                pickDirection: null,
                winRate: null,
                onAnalyze: () => context
                    .push('/analysis/soccer/match-report/${data.matchId}'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBaseballCards() {
    final baseballDummy = baseballAnalysisDummy;
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _baseballCardsPageController,
        padEnds: false,
        itemCount: baseballDummy.length,
        itemBuilder: (context, index) {
          final data = baseballDummy[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: AnalysisCard(
                leagueId: data.leagueId,
                leagueName: data.leagueName,
                date: data.date,
                homeTeam: data.homeTeam,
                awayTeam: data.awayTeam,
                matchTime: data.matchTime,
                homeLogoUrl: data.homeLogoUrl,
                awayLogoUrl: data.awayLogoUrl,
                isPremiumPick: false,
                pickDirection: null,
                winRate: null,
                onAnalyze: () => context
                    .push('/analysis/baseball/match-report/${data.matchId}'),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                _buildEventBanner(),
                const SizedBox(height: 8),
                _buildBannerIndicator(),
                const SizedBox(height: 16),

                const TsBanner(type: TsBannerType.subscription),
                const SizedBox(height: 16),

                _buildSectionHeader(
                  sportType: SportType.soccer,
                  title: '축구 분석',
                  onMoreTap: () => context.go('/analysis'),
                ),
                const SizedBox(height: 16),
                _buildSoccerCards(),
                const SizedBox(height: 16),

                _buildSectionHeader(
                  sportType: SportType.baseball,
                  title: '야구 분석',
                  onMoreTap: () => context.go('/analysis?sport=baseball'),
                ),
                const SizedBox(height: 16),
                _buildBaseballCards(),
                const SizedBox(height: 16),

                PremiumPickCard(
                  showCTA: true,
                  winRate: '78%',
                  countdown: '3h 42m',
                  streak: '5 WIN',
                  recentWins: const [
                    RecentWinData(
                      homeTeam: '바르셀로나',
                      awayTeam: '바이에른',
                      pickDirection: '홈',
                    ),
                    RecentWinData(
                      homeTeam: '아스날',
                      awayTeam: '첼시',
                      pickDirection: '원정',
                    ),
                    RecentWinData(
                      homeTeam: '레알 마드리드',
                      awayTeam: '아틀레티코',
                      pickDirection: '홈',
                    ),
                  ],
                  onCTATap: () => context.go('/premium'),
                ),
                const SizedBox(height: 16),

                TodayComboCard(
                  comboCount: '20',
                  accuracy: '50%',
                  avgOdds: '4.29',
                  onCTATap: () => context.go('/premium'),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
    );
  }
}
