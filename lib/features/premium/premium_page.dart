import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/premium/premium_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/pick_direction_badge.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_card.dart';
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

  PickDirection? _pickDirectionFromData(String? raw) {
    return switch (raw) {
      'home' => PickDirection.home,
      'draw' => PickDirection.draw,
      'away' => PickDirection.away,
      _ => null,
    };
  }

  Widget _buildSoccerSection(BuildContext context) {
    if (premiumPickDummy.isEmpty) {
      return const Center(
        child: TsEmptyState(type: TsEmptyStateType.premiumPickEmpty),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumPickCard(
            showCTA: false,
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
          ),
          const SizedBox(height: 16),
          ...premiumPickDummy.asMap().entries.map((entry) {
            final data = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < premiumPickDummy.length - 1 ? 16 : 0,
              ),
              child: AnalysisCard(
                leagueId: data.leagueId,
                leagueName: data.leagueName,
                date: data.date,
                homeTeam: data.homeTeam,
                awayTeam: data.awayTeam,
                matchTime: data.matchTime,
                isPremiumPick: true,
                pickDirection: _pickDirectionFromData(data.pickDirection),
                winRate: data.winRate,
                onAnalyze: () => context.push(
                  '/analysis/soccer/match-report/${data.matchId}',
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
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

    if (!auth.hasFullAccess) {
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
