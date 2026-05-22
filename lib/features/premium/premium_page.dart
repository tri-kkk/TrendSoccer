import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/utils/access_gate.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/premium/premium_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_stats_card.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_card.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_dashboard.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/toggle/sports_toggle.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  SportType _selectedSport = SportType.soccer;
  int _selectedComboDateIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sportParam = GoRouterState.of(context).uri.queryParameters['sport'];
    if (sportParam == 'baseball' && _selectedSport != SportType.baseball) {
      setState(() {
        _selectedSport = SportType.baseball;
        _selectedComboDateIndex = 0;
      });
    }
  }

  Widget _buildSoccerSection(BuildContext context) {
    final date = ref.watch(todayDateProvider);
    final picksAsync = ref.watch(premiumPicksProvider(date));

    ref.listen(premiumPicksProvider(date), (previous, next) {
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasError && context.mounted) {
        TsToast.error(context, '프리미엄 픽 목록을 불러오지 못했습니다.');
      }
    });

    return picksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '프리미엄 픽 목록을 불러오지 못했습니다.',
              style: TsType.bodyLRegular.copyWith(
                color: Theme.of(context)
                    .extension<TsSemanticColors>()!
                    .textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TsButton(
              label: '다시 시도',
              variant: TsButtonVariant.primary,
              size: TsButtonSize.small,
              onPressed: () => ref.invalidate(premiumPicksProvider(date)),
            ),
          ],
        ),
      ),
      data: (picks) {
        if (picks.isEmpty) {
          return const Center(
            child: TsEmptyState(
              type: TsEmptyStateType.premiumPickEmpty,
              title: 'No High-Confidence Picks Today',
              subtitle: '오전 6시 또는 오후 6시에 다시 확인해 주세요.',
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PremiumPickStatsCard(showCTA: false),
              const SizedBox(height: 16),
              ...picks.asMap().entries.map((entry) {
                final card = entry.value;
                final match = card.match;
                final leagueId = leagueIdForCard(match.league);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key < picks.length - 1 ? 16 : 0,
                  ),
                  child: AnalysisCard(
                    leagueId: leagueId,
                    leagueName: match.league.name,
                    leagueLogoUrl: match.league.icon,
                    date: formatSoccerCardDate(match.matchDate),
                    homeTeam: match.homeTeam.name,
                    awayTeam: match.awayTeam.name,
                    matchTime: match.matchTime,
                    homeLogoUrl: match.homeTeam.logo,
                    awayLogoUrl: match.awayTeam.logo,
                    isPremiumPick: true,
                    pickDirection: pickDirectionFromCard(card),
                    winRate: winRateLabelFromCard(card),
                    onAnalyze: () => context.push(
                      '/analysis/soccer/match-report/${match.matchId}',
                      extra: MatchHeaderData.fromSoccerCard(card),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBaseballSection() {
    final dayData = _selectedComboDateIndex < comboDaysDummy.length
        ? comboDaysDummy[_selectedComboDateIndex]
        : null;

    final hasData = dayData != null && dayData.combos.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ComboDashboard(
            dateTitle: dayData?.dateTitle ?? '',
            comboCountText: dayData?.comboCountText ?? '',
            dateTabs: comboDateLabels,
            selectedDateIndex: _selectedComboDateIndex,
            onDateSelected: (i) => setState(() => _selectedComboDateIndex = i),
            comboCount: dayData?.comboCount ?? 0,
            accuracy: dayData?.accuracy ?? '0%',
            avgOdds: dayData?.avgOdds ?? '0.00',
            safeHitRate: dayData?.safeHitRate ?? '0%',
            safeHitDetail: dayData?.safeHitDetail ?? '(0/0)',
            highOddsHitRate: dayData?.highOddsHitRate ?? '0%',
            highOddsHitDetail: dayData?.highOddsHitDetail ?? '(0/0)',
          ),
          const SizedBox(height: 16),
          if (hasData)
            ...dayData.combos.asMap().entries.map((entry) {
              final combo = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < dayData.combos.length - 1 ? 12 : 0,
                ),
                child: ComboCard(
                  leagueId: combo.leagueId,
                  comboCount: combo.comboCount,
                  comboType: combo.comboType,
                  status: combo.status,
                  matches: combo.matches,
                  aiReport: combo.aiReport,
                  totalOdds: combo.totalOdds,
                  confidence: combo.confidence,
                ),
              );
            })
          else
            const TsEmptyState(type: TsEmptyStateType.defaultState),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(TsSemanticColors semantic, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          TsAssets.iconCheckSmall,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            semantic.interactivePrimary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final auth = ref.watch(authProvider);

    if (!AccessGate.canViewPremiumContent(planType: auth.planType)) {
      return Scaffold(
        backgroundColor: semantic.surfaceBase,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    TsAssets.iconPremium,
                    width: 80,
                    height: 80,
                    colorFilter: ColorFilter.mode(
                      semantic.interactivePrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '프리미엄 전용 콘텐츠',
                        style: TsType.displayHero.copyWith(
                          color: semantic.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PREMIUM PICK과 야구 AI 조합 분석을',
                        style: TsType.bodyLBold.copyWith(
                          color: semantic.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '구독 후 이용하실 수 있습니다.',
                        style: TsType.bodyLBold.copyWith(
                          color: semantic.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: semantic.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '프리미엄 혜택',
                          style: TsType.bodyLRegular.copyWith(
                            color: semantic.interactivePrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBenefitRow(semantic, '24시간 우선 분석 접근'),
                        const SizedBox(height: 16),
                        _buildBenefitRow(semantic, 'PREMIUM PICK 무제한'),
                        const SizedBox(height: 16),
                        _buildBenefitRow(semantic, '야구 AI Analysis'),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TsButton(
                            label: '지금 구독하기 →',
                            variant: TsButtonVariant.primary,
                            onPressed: () => navigateToSubscribe(context, ref),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SportsToggle(
              selectedSport: _selectedSport,
              onChanged: (sport) => setState(() {
                _selectedSport = sport;
                _selectedComboDateIndex = 0;
              }),
            ),
          ),
          // Matches [AnalysisPage]: SizedBox below SportsToggle before first body block.
          const SizedBox(height: 16),
          if (_selectedSport == SportType.soccer)
            Expanded(child: _buildSoccerSection(context))
          else
            Expanded(child: _buildBaseballSection()),
        ],
      ),
    );
  }
}
