import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/premium/premium_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/pick_direction_badge.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_card.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_card.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_dashboard.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/toggle/sports_toggle.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  SportType _selectedSport = SportType.soccer;
  int _selectedComboDateIndex = 0;

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
              RecentWinData(homeTeam: '바르셀로나', awayTeam: '바이에른', pickDirection: '홈'),
              RecentWinData(homeTeam: '아스날', awayTeam: '첼시', pickDirection: '원정'),
              RecentWinData(homeTeam: '레알 마드리드', awayTeam: '아틀레티코', pickDirection: '홈'),
            ],
          ),
          const SizedBox(height: 16),
          ...premiumPickDummy.asMap().entries.map((entry) {
            final data = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key < premiumPickDummy.length - 1 ? 16 : 0),
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
                onAnalyze: () => context.push('/analysis/soccer/match-report/${data.matchId}'),
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ComboDashboard(
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
        ),
        const SizedBox(height: 16),
        if (hasData)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ...dayData.combos.asMap().entries.map((entry) {
                    final combo = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: entry.key < dayData.combos.length - 1 ? 12 : 0),
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
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          )
        else
          const Expanded(
            child: Center(
              child: TsEmptyState(type: TsEmptyStateType.defaultState),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SportsToggle(
                selectedSport: _selectedSport,
                onChanged: (sport) => setState(() {
                  _selectedSport = sport;
                  _selectedComboDateIndex = 0;
                }),
              ),
            ),
            Expanded(
              child: _selectedSport == SportType.soccer
                  ? _buildSoccerSection(context)
                  : _buildBaseballSection(),
            ),
          ],
        ),
      ),
    );
  }
}
