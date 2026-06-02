import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:trendsoccer/core/services/ad_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/baseball_today_combo_card.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_stats_card.dart';
import 'package:url_launcher/url_launcher.dart';

class TrendPage extends ConsumerStatefulWidget {
  const TrendPage({super.key});

  @override
  ConsumerState<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends ConsumerState<TrendPage> {
  static const int _maxSoccerPreviewCards = 5;
  static const int _maxBaseballPreviewCards = 5;
  static const double _analysisCardViewportFraction = 0.96;
  static const double _topBannerHeight = 380;
  static const double _bottomBannerHeight = 160;

  late final PageController _bannerController;
  late final PageController _bottomBannerController;
  late final PageController _soccerCardsPageController;
  late final PageController _baseballCardsPageController;
  Timer? _bannerTimer;
  int _currentBannerPage = 0;
  int _currentBottomBannerPage = 0;

  List<Map<String, dynamic>> _topBanners = [];
  List<Map<String, dynamic>> _bottomBanners = [];
  bool _loadingBanners = true;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _bottomBannerController = PageController(viewportFraction: 1.0);
    _soccerCardsPageController =
        PageController(viewportFraction: _analysisCardViewportFraction);
    _baseballCardsPageController =
        PageController(viewportFraction: _analysisCardViewportFraction);
    _loadBanners();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _bottomBannerController.dispose();
    _soccerCardsPageController.dispose();
    _baseballCardsPageController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    final adService = ref.read(adServiceProvider);
    final results = await Future.wait([
      adService.getAds('mobile_app_main_top'),
      adService.getAds('mobile_app_main_bottom'),
    ]);

    final top = results[0];
    final bottom = results[1];

    for (final ad in top) {
      final id = ad['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        unawaited(adService.trackAd(id, 'impression'));
      }
    }
    for (final ad in bottom) {
      final id = ad['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        unawaited(adService.trackAd(id, 'impression'));
      }
    }

    if (!mounted) return;
    setState(() {
      _topBanners = top;
      _bottomBanners = bottom;
      _loadingBanners = false;
      _currentBannerPage = 0;
      _currentBottomBannerPage = 0;
    });
    _startBannerAutoSlide();
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    if (_topBanners.length <= 1) return;

    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_bannerController.hasClients || _topBanners.isEmpty) {
        return;
      }
      final next = (_currentBannerPage + 1) % _topBanners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _handleAdClick(Map<String, dynamic> ad) {
    final adService = ref.read(adServiceProvider);
    final id = ad['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      unawaited(adService.trackAd(id, 'click'));
    }

    final linkUrl = ad['link_url'] as String? ?? '';
    if (linkUrl.isEmpty) return;

    if (linkUrl.startsWith('/')) {
      context.push(linkUrl);
    } else if (linkUrl.startsWith('http')) {
      unawaited(
        launchUrl(Uri.parse(linkUrl), mode: LaunchMode.externalApplication),
      );
    }
  }

  Widget _buildTopBannerCarousel() {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _topBannerHeight,
          child: PageView.builder(
            controller: _bannerController,
            padEnds: false,
            onPageChanged: (index) {
              setState(() => _currentBannerPage = index);
            },
            itemCount: _topBanners.length,
            itemBuilder: (context, index) {
              final ad = _topBanners[index];
              final isLast = index == _topBanners.length - 1;
              return Container(
                margin: EdgeInsets.only(right: isLast ? 0 : 8),
                child: GestureDetector(
                  onTap: () => _handleAdClick(ad),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: ad['image_url'] as String? ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: _topBannerHeight,
                      placeholder: (_, _) => Container(
                        color: semantic.surfaceContainer,
                        height: _topBannerHeight,
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: semantic.surfaceContainer,
                        height: _topBannerHeight,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_topBanners.length > 1) ...[
          const SizedBox(height: 8),
          _buildBannerIndicator(),
        ],
      ],
    );
  }

  Widget _buildTopBannerSection(TsSemanticColors semantic) {
    if (_loadingBanners) {
      return SizedBox(
        height: _topBannerHeight,
        child: Container(
          width: double.infinity,
          color: semantic.surfaceContainer,
          child: Center(
            child: CircularProgressIndicator(
              color: semantic.interactivePrimary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    if (_topBanners.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildTopBannerCarousel();
  }

  Widget _buildBottomBanner(Map<String, dynamic> ad) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return GestureDetector(
      onTap: () => _handleAdClick(ad),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: ad['image_url'] as String? ?? '',
          fit: BoxFit.cover,
          width: double.infinity,
          height: _bottomBannerHeight,
          placeholder: (_, _) => Container(
            color: semantic.surfaceContainer,
            height: _bottomBannerHeight,
          ),
          errorWidget: (_, _, _) => Container(
            color: semantic.surfaceContainer,
            height: _bottomBannerHeight,
          ),
        ),
      ),
    );
  }

  Widget _buildBannerIndicator() {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _topBanners.length; i++) ...[
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

  Widget _buildBottomBannerCarousel() {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _bottomBannerHeight,
          child: PageView.builder(
            controller: _bottomBannerController,
            onPageChanged: (index) {
              setState(() => _currentBottomBannerPage = index);
            },
            itemCount: _bottomBanners.length,
            itemBuilder: (context, index) =>
                _buildBottomBanner(_bottomBanners[index]),
          ),
        ),
        if (_bottomBanners.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _bottomBanners.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                i == _currentBottomBannerPage
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
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBannerSection(
    TsSemanticColors semantic,
    bool showBottomAds,
  ) {
    if (!showBottomAds) {
      return const SizedBox.shrink();
    }
    if (_loadingBanners) {
      return SizedBox(
        height: _bottomBannerHeight,
        child: Container(
          width: double.infinity,
          color: semantic.surfaceContainer,
          child: Center(
            child: CircularProgressIndicator(
              color: semantic.interactivePrimary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    if (_bottomBanners.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildBottomBannerCarousel();
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
    final matchesAsync = ref.watch(analysisSoccerMatchesProvider);

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
                '예정된 축구 경기가 없습니다.',
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
          final preview = matches.take(_maxBaseballPreviewCards).toList();
          if (preview.isEmpty) {
            return Center(
              child: Text(
                '예정된 야구 경기가 없습니다.',
                style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
                textAlign: TextAlign.center,
              ),
            );
          }
          return PageView.builder(
            controller: _baseballCardsPageController,
            padEnds: false,
            itemCount: preview.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: _TrendBaseballCard(card: preview[index]),
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
    final auth = ref.watch(authProvider);
    final showBottomAds = !auth.hasFullAccess;
    final showTopBannerArea = _loadingBanners || _topBanners.isNotEmpty;
    final showBottomBannerArea =
        showBottomAds && (_loadingBanners || _bottomBanners.isNotEmpty);

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTopBannerArea) ...[
                _buildTopBannerSection(semantic),
                const SizedBox(height: 16),
              ],
              if (showBottomBannerArea) ...[
                _buildBottomBannerSection(semantic, showBottomAds),
                const SizedBox(height: 16),
              ],
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
        '/analysis/baseball/match-report/${card.detailMatchId}',
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
