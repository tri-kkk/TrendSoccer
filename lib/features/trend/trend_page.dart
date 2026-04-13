import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/subscription_state.dart';
import '../../core/providers/subscription_provider.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../shared/widgets/appbar/app_bar_home.dart';
import '../../shared/widgets/banner/banner_event.dart';
import '../../shared/widgets/banner/banner_indicator.dart';
import '../../shared/widgets/banner/banner_subscription.dart';
import '../../shared/widgets/cards/analysis_card.dart';
import '../../shared/widgets/cards/news_card.dart';
import '../../shared/widgets/cards/report_card.dart';
import '../../shared/widgets/section/section_header.dart';

/// The main Trend / Home page of TrendSoccer.
///
/// Renders a vertically scrollable feed containing:
/// 1. Event banner carousel with auto-slide.
/// 2. Subscription CTA (hidden for premium users).
/// 3. Soccer & Baseball analysis cards in horizontal scrolls.
/// 4. Reports section with horizontal scroll.
/// 5. Soccer & Baseball news in vertical lists.
/// 6. Ad placeholder (hidden for premium users).
///
/// Layout follows Figma node `651:49248`.
class TrendPage extends ConsumerStatefulWidget {
  const TrendPage({super.key});

  @override
  ConsumerState<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends ConsumerState<TrendPage> {
  static const _bannerCount = 2;
  static const _autoSlideInterval = Duration(seconds: 3);
  static const _bannerGap = 8.0;

  PageController? _bannerController;
  Timer? _autoSlideTimer;
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _bannerController?.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(_autoSlideInterval, (_) {
      final controller = _bannerController;
      if (controller == null || !controller.hasClients) return;
      final next = (_currentBannerPage + 1) % _bannerCount;
      controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  PageController _ensureBannerController(double availableWidth) {
    if (_bannerController != null) return _bannerController!;
    final contentWidth = availableWidth - 2 * AppSpacing.xl;
    final fraction = (contentWidth + _bannerGap) / availableWidth;
    _bannerController = PageController(viewportFraction: fraction);
    return _bannerController!;
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);
    final isPremium = subscription.type == SubscriptionType.premium;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            const AppBarHome(state: AppBarState.guest),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildBannerSlider(),
                    const SizedBox(height: AppSpacing.xxl),
                    if (!isPremium) ...[
                      _buildSubscriptionBanner(),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    _buildSoccerAnalysis(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildBaseballAnalysis(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildReports(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildSoccerNews(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildBaseballNews(),
                    if (!isPremium) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      _buildAdPlaceholder(),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Banner Slider ──

  Widget _buildBannerSlider() {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final contentWidth = availableWidth - 2 * AppSpacing.xl;
            final controller = _ensureBannerController(availableWidth);

            return SizedBox(
              height: contentWidth,
              child: PageView.builder(
                controller: controller,
                itemCount: _bannerCount,
                onPageChanged: (index) {
                  setState(() => _currentBannerPage = index);
                },
                itemBuilder: (_, __) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: _bannerGap / 2),
                  child: const BannerEvent(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerCount, (index) {
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : AppSpacing.md),
              child: BannerIndicator(isActive: index == _currentBannerPage),
            );
          }),
        ),
      ],
    );
  }

  // ── Subscription Banner ──

  Widget _buildSubscriptionBanner() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: BannerSubscription(),
    );
  }

  // ── Soccer Analysis ──

  Widget _buildSoccerAnalysis() {
    const items = [
      _AnalysisData('EPL', '04.13', 'Chelsea', 'Arsenal', '16:00'),
      _AnalysisData('LALIGA', '04.13', 'Barcelona', 'Real Madrid', '21:00'),
      _AnalysisData('BUNDESLIGA', '04.13', 'Bayern', 'Dortmund', '18:30'),
    ];

    return _buildAnalysisSection('Soccer Analysis', items);
  }

  // ── Baseball Analysis ──

  Widget _buildBaseballAnalysis() {
    const items = [
      _AnalysisData('KBO', '04.13', 'LG Twins', 'KT Wiz', '18:30'),
      _AnalysisData('MLB', '04.13', 'Yankees', 'Red Sox', '07:05'),
      _AnalysisData('NPB', '04.13', 'Giants', 'Tigers', '14:00'),
    ];

    return _buildAnalysisSection('Baseball Analysis', items);
  }

  Widget _buildAnalysisSection(String title, List<_AnalysisData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: SectionHeader(title: title),
        ),
        const SizedBox(height: AppSpacing.xl),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const PageScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(items.length, (index) {
                final d = items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : AppSpacing.lg,
                  ),
                  child: AnalysisCard(
                    leagueCode: d.leagueCode,
                    date: d.date,
                    homeTeam: d.homeTeam,
                    awayTeam: d.awayTeam,
                    time: d.time,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ── Reports ──

  Widget _buildReports() {
    const reports = [
      ('Chelsea vs Arsenal Preview', 'Tactical breakdown of the London derby'),
      ('La Liga Week 32 Recap', 'Barcelona extends lead at the top'),
      ('UCL Quarter-Final Guide', 'Everything you need to know'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: SectionHeader(
            title: 'Reports',
            type: SectionHeaderType.withAction,
            onSeeAllTap: () => debugPrint('Navigate to Reports'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
            itemBuilder: (_, index) {
              final (title, desc) = reports[index];
              return ReportCard(
                size: ReportCardSize.small,
                title: title,
                description: desc,
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Soccer News ──

  Widget _buildSoccerNews() {
    const news = [
      ('ESPN', '04.13', 'Premier League: Weekend Preview and Key Matchups'),
      ('BBC Sport', '04.12', 'Transfer Rumours: Top 5 Summer Deals to Watch'),
      ('Goal.com', '04.12', 'Champions League Draw: What to Expect Next'),
    ];

    return _buildNewsSection('Soccer News', news);
  }

  // ── Baseball News ──

  Widget _buildBaseballNews() {
    const news = [
      ('SPOTV', '04.13', 'KBO Opening Day: Season Preview and Predictions'),
      ('MLB.com', '04.12', 'Yankees vs Red Sox: Rivalry Renewed This Weekend'),
      (
        'Baseball Tonight',
        '04.11',
        'NPB Stars Making Waves in the 2026 Season',
      ),
    ];

    return _buildNewsSection('Baseball News', news);
  }

  Widget _buildNewsSection(
    String title,
    List<(String source, String date, String headline)> news,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(news.length, (index) {
            final (source, date, headline) = news[index];
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : AppSpacing.xl),
              child: NewsCard(source: source, date: date, title: headline),
            );
          }),
        ],
      ),
    );
  }

  // ── Ad Placeholder ──

  Widget _buildAdPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Center(
          child: Text(
            'Advertisement',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal holder for analysis card placeholder data.
class _AnalysisData {
  const _AnalysisData(
    this.leagueCode,
    this.date,
    this.homeTeam,
    this.awayTeam,
    this.time,
  );

  final String leagueCode;
  final String date;
  final String homeTeam;
  final String awayTeam;
  final String time;
}
