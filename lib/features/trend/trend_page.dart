import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/trend/trend_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/banner/ts_banner.dart';
import 'package:trendsoccer/shared/widgets/banner/ts_banner_indicator.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/pick_direction_badge.dart';
import 'package:trendsoccer/shared/widgets/cards/today_combo_card.dart';
import 'package:trendsoccer/shared/widgets/cards/today_pick_card.dart';
import 'package:trendsoccer/shared/widgets/logo/ts_logo.dart';
import 'package:trendsoccer/shared/widgets/section/ts_section_header.dart';

class TrendPage extends StatefulWidget {
  const TrendPage({super.key});

  @override
  State<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  static const int _bannerPageCount = 3;

  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % _bannerPageCount;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  PickDirection? _pickDirectionFromData(String? raw) {
    return switch (raw) {
      'home' => PickDirection.home,
      'draw' => PickDirection.draw,
      'away' => PickDirection.away,
      _ => null,
    };
  }

  Widget _analysisCardFromData(AnalysisCardData data) {
    return AnalysisCard(
      leagueId: data.leagueId,
      leagueName: data.leagueName,
      date: data.date,
      homeTeam: data.homeTeam,
      awayTeam: data.awayTeam,
      matchTime: data.matchTime,
      homeLogoUrl: data.homeLogoUrl,
      awayLogoUrl: data.awayLogoUrl,
      onAnalyze: null,
      isPremiumPick: data.isPremiumPick,
      pickDirection: _pickDirectionFromData(data.pickDirection),
      winRate: data.winRate,
    );
  }

  Widget _horizontalAnalysisList(List<AnalysisCardData> items) {
    return SizedBox(
      height: 400,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isLast = index == items.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: SizedBox(
              width: 380,
              child: _analysisCardFromData(items[index]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final logoColor = Theme.of(context).brightness == Brightness.dark
        ? TsLogoColor.white
        : TsLogoColor.black;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: TsAppBar(
        location: TsAppBarLocation.home,
        leading: TsLogo(
          type: TsLogoType.horizon,
          color: logoColor,
        ),
        trailing: TsButton(
          label: '로그인',
          size: TsButtonSize.small,
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 380,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      children: const [
                        TsBanner(type: TsBannerType.event),
                        TsBanner(type: TsBannerType.event),
                        TsBanner(type: TsBannerType.event),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_bannerPageCount, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TsBannerIndicator(
                          isActive: index == _currentPage,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TsBanner(type: TsBannerType.subscription),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TsSectionHeader(title: '⚽ Soccer Analysis'),
            ),
            const SizedBox(height: 12),
            _horizontalAnalysisList(soccerAnalysisDummy),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TsSectionHeader(title: '⚾ Baseball Analysis'),
            ),
            const SizedBox(height: 12),
            _horizontalAnalysisList(baseballAnalysisDummy),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TodayPickCard(
                pickCount: 3,
                updateTime: '06:00',
                onTap: null,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TodayComboCard(
                comboCount: 20,
                accuracy: '50%',
                avgOdds: '4.29',
                onTap: null,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: semantic.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'AdMob Banner',
                  style: TsType.bodyMRegular.copyWith(
                    color: semantic.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
