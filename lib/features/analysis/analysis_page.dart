import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/analysis_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/pick_direction_badge.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_card.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';
import 'package:trendsoccer/shared/widgets/toggle/sports_toggle.dart';
import 'package:trendsoccer/shared/widgets/toggle/sub_tab_toggle.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  SportType _selectedSport = SportType.soccer;
  int _selectedSubTab = 0;
  String _selectedLeagueId = 'all';

  PickDirection? _pickDirectionFromData(String? raw) {
    return switch (raw) {
      'home' => PickDirection.home,
      'draw' => PickDirection.draw,
      'away' => PickDirection.away,
      _ => null,
    };
  }

  Widget _buildAnalysisView() {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final filters = _selectedSport == SportType.soccer
        ? soccerLeagueFilters
        : baseballLeagueFilters;

    final allCards = _selectedSport == SportType.soccer
        ? soccerAnalysisFullDummy
        : baseballAnalysisFullDummy;
    final filteredCards = _selectedLeagueId == 'all'
        ? allCards
        : allCards.where((c) => c.leagueId == _selectedLeagueId).toList();

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedSport == SportType.soccer) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PremiumPickCard(
                  winRate: '78%',
                  countdown: '3h 42m',
                  streak: '5 WIN',
                  recentHomeTeam: 'Barcelona',
                  recentAwayTeam: 'Bayern',
                  recentPick: PickDirection.home,
                  onCTATap: null,
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final id = filter['id']!;
                  final name = filter['name']!;
                  return TsFilterChip(
                    label: name,
                    isSelected: _selectedLeagueId == id,
                    type: id == 'all'
                        ? FilterChipType.textOnly
                        : FilterChipType.withIcon,
                    iconWidget: id != 'all'
                        ? TsLeagueIcon(leagueId: id, size: 16)
                        : null,
                    onTap: () => setState(() => _selectedLeagueId = id),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (filteredCards.isEmpty)
              TsEmptyState(type: TsEmptyStateType.defaultState)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: filteredCards.map((data) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                        onAnalyze: _selectedSport == SportType.soccer
                            ? () => context.push(
                                  '/analysis/soccer/match-report/${data.matchId}',
                                )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (_selectedSport == SportType.baseball) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'AI 분석은 참고용이며, 실제 경기 결과와 다를 수 있습니다.',
                  style: TsType.labelSRegular.copyWith(
                    color: semantic.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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

  Widget _buildFixtureStubView() {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Expanded(
      child: Center(
        child: Text(
          '일정/결과\n(Fixture 위젯 연동 후 구현)',
          style: TsType.bodyLRegular.copyWith(color: semantic.textTertiary),
          textAlign: TextAlign.center,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SportsToggle(
                selectedSport: _selectedSport,
                onChanged: (sport) {
                  setState(() {
                    _selectedSport = sport;
                    _selectedLeagueId = 'all';
                    _selectedSubTab = 0;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SubTabToggle(
                tabs: const ['분석', '일정/결과'],
                selectedIndex: _selectedSubTab,
                onChanged: (index) => setState(() => _selectedSubTab = index),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedSubTab == 0)
              _buildAnalysisView()
            else
              _buildFixtureStubView(),
          ],
        ),
      ),
    );
  }
}
