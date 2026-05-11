import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
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

  Widget _buildSoccerContent(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumPickCard(
              showCTA: false,
              winRate: '78%',
              countdown: '3h 42m',
              streak: '5 WIN',
              recentWins: const [
                RecentWinData(
                  homeTeam: 'Barcelona',
                  awayTeam: 'Bayern',
                  pickDirection: '홈',
                ),
              ],
            ),
            const SizedBox(height: TsSpacing.lg),
            Container(height: 1, color: Theme.of(context).extension<TsSemanticColors>()!.borderSubtle),
            const SizedBox(height: TsSpacing.lg),
            if (premiumPickDummy.isEmpty)
              TsEmptyState(type: TsEmptyStateType.premiumPickEmpty)
            else
              ...premiumPickDummy.map((data) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: SizedBox(
                      width: double.infinity,
                      child: AnalysisCard(
                        leagueId: data.leagueId,
                        leagueName: data.leagueName,
                        date: data.date,
                        homeTeam: data.homeTeam,
                        awayTeam: data.awayTeam,
                        matchTime: data.matchTime,
                        homeLogoUrl: data.homeLogoUrl,
                        awayLogoUrl: data.awayLogoUrl,
                        isPremiumPick: data.isPremiumPick,
                        pickDirection: _pickDirectionFromData(data.pickDirection),
                        winRate: data.winRate,
                        onAnalyze: () => context.push(
                          '/analysis/soccer/match-report/${data.matchId}',
                        ),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: TsSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseballContent(BuildContext context) {
    final dayData = _selectedComboDateIndex < comboDaysDummy.length
        ? comboDaysDummy[_selectedComboDateIndex]
        : null;

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: TsSpacing.lg),
            if (dayData != null && dayData.combos.isNotEmpty)
              ...dayData.combos.map((combo) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
              TsEmptyState(type: TsEmptyStateType.defaultState),
            const SizedBox(height: TsSpacing.xl),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(TsSpacing.lg, TsSpacing.lg, TsSpacing.lg, 0),
              child: SportsToggle(
                selectedSport: _selectedSport,
                onChanged: (sport) => setState(() {
                  _selectedSport = sport;
                  _selectedComboDateIndex = 0;
                }),
              ),
            ),
            const SizedBox(height: TsSpacing.lg),
            if (_selectedSport == SportType.soccer)
              _buildSoccerContent(context)
            else
              _buildBaseballContent(context),
          ],
        ),
      ),
    );
  }
}
