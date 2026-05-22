import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/banner/ts_banner.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/baseball_today_combo_card.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_stats_card.dart';

class TrendPage extends ConsumerStatefulWidget {
  const TrendPage({super.key});

  @override
  ConsumerState<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends ConsumerState<TrendPage> {
  static const int _maxSoccerPreviewCards = 7;
  static const int _maxBaseballPreviewCards = 7;
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
    required String title,
    VoidCallback? onMoreTap,
  }) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          ),
        ),
        if (onMoreTap != null)
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
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final date = ref.watch(todayDateProvider);
    final matchesAsync = ref.watch(soccerMatchesProvider(date));

    return SizedBox(
      height: 220,
      child: matchesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: semantic.interactivePrimary),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            '경기 목록을 불러오지 못했습니다.',
            style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        data: (matches) {
          final preview = matches.take(_maxSoccerPreviewCards).toList();
          if (preview.isEmpty) {
            return Center(
              child: Text(
                '오늘 예정된 경기가 없습니다.',
                style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
                textAlign: TextAlign.center,
              ),
            );
          }
          return PageView.builder(
            controller: _soccerCardsPageController,
            padEnds: false,
            itemCount: preview.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: _TrendSoccerCard(card: preview[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBaseballCards() {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final matchesAsync = ref.watch(baseballAnalysisMatchesProvider);

    return SizedBox(
      height: 220,
      child: matchesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: semantic.interactivePrimary),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            '경기 목록을 불러오지 못했습니다.',
            style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        data: (matches) {
          final todayMatches = matches
              .where(baseballMatchIsToday)
              .take(_maxBaseballPreviewCards)
              .toList();
          if (todayMatches.isEmpty) {
            return Center(
              child: Text(
                '오늘 예정된 경기가 없습니다.',
                style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
                textAlign: TextAlign.center,
              ),
            );
          }
          return PageView.builder(
            controller: _baseballCardsPageController,
            padEnds: false,
            itemCount: todayMatches.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: _TrendBaseballCard(card: todayMatches[index]),
                ),
              );
            },
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
                  title: '축구 분석',
                  onMoreTap: () => context.go('/analysis'),
                ),
                const SizedBox(height: 16),
                _buildSoccerCards(),
                const SizedBox(height: 16),

                _buildSectionHeader(
                  title: '야구 분석',
                  onMoreTap: () => context.go('/analysis?sport=baseball'),
                ),
                const SizedBox(height: 16),
                _buildBaseballCards(),
                const SizedBox(height: 16),

                _buildSectionHeader(
                  title: '프리미엄 분석',
                ),
                const SizedBox(height: 16),
                PremiumPickStatsCard(
                  showCTA: true,
                  onCTATap: () {
                    final auth = ref.read(authProvider);
                    if (auth.hasFullAccess) {
                      context.go('/premium');
                    } else {
                      navigateToSubscribeIfLoggedIn(context, auth.isLoggedIn);
                    }
                  },
                ),
                const SizedBox(height: 16),

                const BaseballTodayComboCard(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
    );
  }
}

class _TrendBaseballCard extends StatelessWidget {
  const _TrendBaseballCard({required this.card});

  final BaseballAnalysisCard card;

  @override
  Widget build(BuildContext context) {
    return AnalysisCard(
      leagueId: baseballLeagueIconId(card.league),
      leagueName: card.league,
      date: formatBaseballCardDate(card),
      homeTeam: card.homeDisplayTeam,
      awayTeam: card.awayDisplayTeam,
      matchTime: formatBaseballMatchTimeKst(card),
      homeLogoUrl: card.homeTeamLogo,
      awayLogoUrl: card.awayTeamLogo,
      isPremiumPick: false,
      pickDirection: null,
      winRate: null,
      onAnalyze: () => context.push(
        '/analysis/baseball/match-report/${card.matchId}',
        extra: MatchHeaderData.fromBaseballCard(card),
      ),
    );
  }
}

class _TrendSoccerCard extends StatelessWidget {
  const _TrendSoccerCard({required this.card});

  final SoccerAnalysisCard card;

  @override
  Widget build(BuildContext context) {
    final match = card.match;
    final leagueId = leagueIdForCard(match.league);

    return AnalysisCard(
      leagueId: leagueId,
      leagueName: match.league.name,
      leagueLogoUrl: match.league.icon,
      date: formatSoccerCardDate(match.matchDate),
      homeTeam: match.homeTeam.name,
      awayTeam: match.awayTeam.name,
      matchTime: match.matchTime,
      homeLogoUrl: match.homeTeam.logo,
      awayLogoUrl: match.awayTeam.logo,
      isPremiumPick: false,
      pickDirection: null,
      winRate: null,
      onAnalyze: () => context.push(
        '/analysis/soccer/match-report/${match.matchId}',
        extra: MatchHeaderData.fromSoccerCard(card),
      ),
    );
  }
}
