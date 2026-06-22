import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_combo_provider.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/services/ad_service.dart';
import 'package:trendsoccer/core/services/admob_service.dart';
import 'package:trendsoccer/core/services/announcement_service.dart';
import 'package:trendsoccer/core/services/review_service.dart';
import 'package:trendsoccer/core/utils/api_language_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/shared/widgets/empty/network_error_widget.dart';
import 'package:trendsoccer/shared/widgets/dialogs/announcement_dialog.dart';
import 'package:trendsoccer/shared/widgets/dialogs/exit_dialog.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/baseball_today_combo_card.dart';
import 'package:trendsoccer/shared/widgets/ads/premium_ad_wrapper.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_stats_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

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
  static const double _directAdBannerHeight = 120;

  late final PageController _bannerController;
  late final PageController _bottomBannerController;
  late final PageController _directAdBannerController;
  late final PageController _soccerCardsPageController;
  late final PageController _baseballCardsPageController;
  Timer? _bannerTimer;
  int _currentBannerPage = 0;
  int _currentBottomBannerPage = 0;
  int _currentDirectAdBannerPage = 0;

  List<Map<String, dynamic>> _topBanners = [];
  List<Map<String, dynamic>> _bottomBanners = [];
  List<Map<String, dynamic>> _directAdBanners = [];
  bool _loadingBanners = true;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _bottomBannerController = PageController(viewportFraction: 1.0);
    _directAdBannerController = PageController(viewportFraction: 1.0);
    _soccerCardsPageController =
        PageController(viewportFraction: _analysisCardViewportFraction);
    _baseballCardsPageController =
        PageController(viewportFraction: _analysisCardViewportFraction);
    _loadBanners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_checkAnnouncement());

      Future<void>.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        final prefs = ref.read(sharedPreferencesProvider);
        final reviewService = ReviewService(prefs);
        reviewService.recordLaunch();
        unawaited(reviewService.requestReviewIfEligible());
      });
    });
  }

  Future<void> _checkAnnouncement() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final locale = getApiLanguage(prefs);
    final service = AnnouncementService(prefs);

    final config = await service.fetchAnnouncement(locale);
    if (!mounted || config == null) return;
    if (!service.shouldShow(config)) return;

    await showAnnouncementDialog(context, config, service);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _bottomBannerController.dispose();
    _directAdBannerController.dispose();
    _soccerCardsPageController.dispose();
    _baseballCardsPageController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    final adService = ref.read(adServiceProvider);
    final results = await Future.wait([
      adService.getAds('mobile_app_main_top'),
      adService.getAds('mobile_app_main_bottom'),
      adService.getAds('mobile_app_main_banner'),
    ]);

    final top = results[0];
    final bottom = results[1];
    final direct = results[2];

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
    for (final ad in direct) {
      final id = ad['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        unawaited(adService.trackAd(id, 'impression'));
      }
    }

    if (!mounted) return;
    setState(() {
      _topBanners = top;
      _bottomBanners = bottom;
      _directAdBanners = direct;
      _loadingBanners = false;
      _currentBannerPage = 0;
      _currentBottomBannerPage = 0;
      _currentDirectAdBannerPage = 0;
    });
    _startBannerAutoSlide();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(analysisSoccerMatchesProvider);
    ref.invalidate(baseballAnalysisMatchesProvider);
    ref.invalidate(premiumPickStatsProvider);
    ref.invalidate(baseballComboStatsProvider);

    await _loadBanners();

    await Future.wait([
      ref.read(analysisSoccerMatchesProvider.future),
      ref.read(baseballAnalysisMatchesProvider.future),
      ref.read(premiumPickStatsProvider.future),
      ref.read(baseballComboStatsProvider.future),
    ]);
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
                margin: EdgeInsets.only(right: isLast ? 0 : TsSpacing.sm),
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
          const SizedBox(height: TsSpacing.sm),
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

  Widget _buildDirectAdBanner(Map<String, dynamic> ad) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return GestureDetector(
      onTap: () => _handleAdClick(ad),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TsSpacing.md),
        child: CachedNetworkImage(
          imageUrl: ad['image_url'] as String? ?? '',
          width: double.infinity,
          height: _directAdBannerHeight,
          fit: BoxFit.fitWidth,
          placeholder: (context, url) => Container(
            height: _directAdBannerHeight,
            decoration: BoxDecoration(
              color: semantic.surfaceContainer,
              borderRadius: BorderRadius.circular(TsSpacing.md),
            ),
          ),
          errorWidget: (context, url, error) => const SizedBox.shrink(),
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
          if (i > 0) const SizedBox(width: TsSpacing.sm),
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
          const SizedBox(height: TsSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _bottomBanners.length; i++) ...[
                if (i > 0) const SizedBox(width: TsSpacing.sm),
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

  Widget _buildDirectAdBannerCarousel() {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _directAdBannerHeight,
          child: PageView.builder(
            controller: _directAdBannerController,
            onPageChanged: (index) {
              setState(() => _currentDirectAdBannerPage = index);
            },
            itemCount: _directAdBanners.length,
            itemBuilder: (context, index) =>
                _buildDirectAdBanner(_directAdBanners[index]),
          ),
        ),
        if (_directAdBanners.length > 1) ...[
          const SizedBox(height: TsSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _directAdBanners.length; i++) ...[
                if (i > 0) const SizedBox(width: TsSpacing.sm),
                i == _currentDirectAdBannerPage
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

  Widget _buildDirectAdBannerSection(
    TsSemanticColors semantic,
    bool showAds,
  ) {
    if (!showAds) {
      return const SizedBox.shrink();
    }
    if (_loadingBanners) {
      return SizedBox(
        height: _directAdBannerHeight,
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
    if (_directAdBanners.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildDirectAdBannerCarousel();
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
              context.l10n.seeMore,
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
          ),
      ],
    );
  }

  Widget _buildAnalysisEmptyCard(BuildContext context) {
    final sem = Theme.of(context).extension<TsSemanticColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = sem.surfaceBase.withValues(alpha: isDark ? 0.75 : 0.85);

    return SizedBox(
      height: 207,
      width: double.infinity,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 207,
              width: double.infinity,
              decoration: BoxDecoration(
                color: sem.surfaceBase,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(TsSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: sem.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: TsSpacing.sm),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: sem.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                          color: sem.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: sem.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 50,
                            height: 12,
                            decoration: BoxDecoration(
                              color: sem.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 12,
                            decoration: BoxDecoration(
                              color: sem.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: TsSpacing.xs),
                          Container(
                            width: 32,
                            height: 12,
                            decoration: BoxDecoration(
                              color: sem.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: sem.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 50,
                            height: 12,
                            decoration: BoxDecoration(
                              color: sem.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: sem.interactivePrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                height: 207,
                width: double.infinity,
                color: overlayColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      TsAssets.iconHourglassEmpty,
                      width: 48,
                      height: 48,
                      colorFilter:
                          ColorFilter.mode(sem.textPrimary, BlendMode.srcIn),
                    ),
                    const SizedBox(height: TsSpacing.lg),
                    Text(
                      context.l10n.trendEmptyTitle,
                      style: TsType.headingH3.copyWith(color: sem.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: TsSpacing.sm),
                    Text(
                      context.l10n.trendEmptySubtitle1,
                      style:
                          TsType.labelSRegular.copyWith(color: sem.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      context.l10n.trendEmptySubtitle2,
                      style:
                          TsType.labelSRegular.copyWith(color: sem.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoccerCards() {
    final matchesAsync = ref.watch(analysisSoccerMatchesProvider);

    return SizedBox(
      height: 220,
      child: matchesAsync.when(
        loading: () => _buildAnalysisEmptyCard(context),
        error: (error, stackTrace) => SingleChildScrollView(
          child: NetworkErrorWidget(
            message: context.l10n.loadMatchesFailed,
            onRetry: () => ref.invalidate(analysisSoccerMatchesProvider),
          ),
        ),
        data: (matches) {
          final preview = matches.take(_maxSoccerPreviewCards).toList();
          if (preview.isEmpty) {
            return _buildAnalysisEmptyCard(context);
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
    final matchesAsync = ref.watch(baseballAnalysisMatchesProvider);

    return SizedBox(
      height: 220,
      child: matchesAsync.when(
        loading: () => SizedBox(
          height: 207,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        error: (error, stackTrace) => SingleChildScrollView(
          child: NetworkErrorWidget(
            message: context.l10n.loadMatchesFailed,
            onRetry: () => ref.invalidate(baseballAnalysisMatchesProvider),
          ),
        ),
        data: (matches) {
          final preview = matches.take(_maxBaseballPreviewCards).toList();
          if (preview.isEmpty) {
            return _buildAnalysisEmptyCard(context);
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
    final showDirectAdBannerArea =
        showBottomAds && (_loadingBanners || _directAdBanners.isNotEmpty);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showExitDialog(context);
      },
      child: Scaffold(
      backgroundColor: semantic.surfaceRaised,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: semantic.interactivePrimary,
        backgroundColor: semantic.surfaceBase,
        displacement: 40,
        edgeOffset: 0,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(TsSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTopBannerArea) ...[
                  _buildTopBannerSection(semantic),
                  const SizedBox(height: TsSpacing.lg),
                ],
                if (showBottomBannerArea) ...[
                  _buildBottomBannerSection(semantic, showBottomAds),
                  const SizedBox(height: TsSpacing.lg),
                ],
                _buildSectionHeader(
                  title: context.l10n.trendSoccerAnalysis,
                  onMoreTap: () => context.go('/analysis'),
                ),
                const SizedBox(height: TsSpacing.lg),
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
                const SizedBox(height: TsSpacing.lg),
                _buildSoccerCards(),
                if (showDirectAdBannerArea) ...[
                  const SizedBox(height: TsSpacing.lg),
                  _buildDirectAdBannerSection(semantic, showBottomAds),
                ],
                const SizedBox(height: TsSpacing.lg),
                _buildSectionHeader(
                  title: context.l10n.trendBaseballAnalysis,
                  onMoreTap: () => context.go('/analysis?sport=baseball'),
                ),
                const SizedBox(height: TsSpacing.lg),
                const BaseballTodayComboCard(),
                const SizedBox(height: TsSpacing.lg),
                _buildBaseballCards(),
                const SizedBox(height: TsSpacing.lg),
                PremiumAdWrapper(adUnitId: AdmobService.trendBannerAdUnitId),
                const SizedBox(height: TsSpacing.xl),
              ],
            ),
          ),
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
      homeTeam: localizedTeamName(context, card.homeTeam, card.homeTeamKo),
      awayTeam: localizedTeamName(context, card.awayTeam, card.awayTeamKo),
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
      leagueName: localizedLeagueName(
        context,
        match.league.nameEn,
        match.league.name,
      ),
      leagueLogoUrl: match.league.icon,
      date: formatSoccerCardDate(match.matchDate),
      homeTeam: localizedTeamName(
        context,
        match.homeTeam.name,
        match.homeTeam.nameKo,
      ),
      awayTeam: localizedTeamName(
        context,
        match.awayTeam.name,
        match.awayTeam.nameKo,
      ),
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
