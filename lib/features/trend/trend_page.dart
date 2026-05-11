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
import 'package:trendsoccer/shared/widgets/cards/pick_direction_badge.dart';
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

  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 0.95);
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
    super.dispose();
  }

  Widget _buildEventBanner() {
    return SizedBox(
      height: 380,
      child: PageView.builder(
        controller: _bannerController,
        onPageChanged: (index) {
          setState(() => _currentBannerPage = index);
        },
        itemCount: _bannerCount,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: TsBanner(type: TsBannerType.event),
          );
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
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: soccerAnalysisDummy.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final data = soccerAnalysisDummy[index];
          return SizedBox(
            width: 380,
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
              onAnalyze: () =>
                  context.push('/analysis/soccer/match-report/${data.matchId}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBaseballCards() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: baseballAnalysisDummy.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final data = baseballAnalysisDummy[index];
          return SizedBox(
            width: 380,
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
              onAnalyze: () =>
                  context.push('/analysis/baseball/match-report/${data.matchId}'),
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
      body: SafeArea(
        child: SingleChildScrollView(
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
                  onMoreTap: null,
                ),
                const SizedBox(height: 16),
                _buildSoccerCards(),
                const SizedBox(height: 16),

                _buildSectionHeader(
                  sportType: SportType.baseball,
                  title: '야구 분석',
                  onMoreTap: null,
                ),
                const SizedBox(height: 16),
                _buildBaseballCards(),
                const SizedBox(height: 16),

                const PremiumPickCard(
                  showCTA: true,
                  winRate: '78%',
                  countdown: '3h 42m',
                  streak: '5 WIN',
                  recentHomeTeam: '바르셀로나',
                  recentAwayTeam: '바이에른',
                  recentPick: PickDirection.home,
                  onCTATap: null,
                ),
                const SizedBox(height: 16),

                TodayComboCard(
                  comboCount: '20',
                  accuracy: '50%',
                  avgOdds: '4.29',
                  onCTATap: null,
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
