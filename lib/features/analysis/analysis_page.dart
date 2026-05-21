import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/analysis_dummy_data.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer_matches_section.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_stats_card.dart';
import 'package:trendsoccer/shared/widgets/cards/today_combo_card.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';
import 'package:trendsoccer/shared/widgets/toggle/sports_toggle.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  SportType _selectedSport = SportType.soccer;
  String _selectedLeagueId = 'all';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sportParam = GoRouterState.of(context).uri.queryParameters['sport'];
    if (sportParam == 'baseball' && _selectedSport != SportType.baseball) {
      setState(() {
        _selectedSport = SportType.baseball;
        _selectedLeagueId = 'all';
      });
    }
  }

  Widget _buildFilterChips() {
    final selectedSoccerLeague = ref.watch(selectedLeagueProvider);

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedSport == SportType.soccer
            ? soccerAnalysisLeagueChips.length
            : baseballLeagueFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (_selectedSport == SportType.soccer) {
            final chip = soccerAnalysisLeagueChips[index];
            final isSelected = chip.isAll
                ? selectedSoccerLeague == null
                : selectedSoccerLeague == chip.id;
            return TsFilterChip(
              label: chip.displayLabel,
              isSelected: isSelected,
              type: chip.iconId != null
                  ? TsFilterChipType.withIcon
                  : TsFilterChipType.textOnly,
              iconWidget: chip.iconId != null
                  ? TsLeagueIcon(leagueId: chip.iconId!, size: 16)
                  : null,
              onTap: () {
                ref.read(selectedLeagueProvider.notifier).state =
                    chip.isAll ? null : chip.id;
              },
            );
          }

          final filter = baseballLeagueFilters[index];
          final isSelected = _selectedLeagueId == filter.id;
          return TsFilterChip(
            label: filter.label,
            isSelected: isSelected,
            type: filter.hasIcon
                ? TsFilterChipType.withIcon
                : TsFilterChipType.textOnly,
            iconWidget: filter.hasIcon
                ? TsLeagueIcon(leagueId: filter.id, size: 16)
                : null,
            onTap: () => setState(() => _selectedLeagueId = filter.id),
          );
        },
      ),
    );
  }

  List<Widget> _buildBaseballCardWidgets(BuildContext context) {
    final allCards = baseballAnalysisDummy;

    final filteredCards = _selectedLeagueId == 'all'
        ? allCards
        : allCards.where((c) => c.leagueId == _selectedLeagueId).toList();

    if (filteredCards.isEmpty) {
      return [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.4,
          child: const Center(child: TsEmptyState()),
        ),
      ];
    }

    return filteredCards.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return Padding(
        padding: EdgeInsets.only(
          bottom: index < filteredCards.length - 1 ? 16 : 0,
        ),
        child: AnalysisCard(
          leagueId: data.leagueId,
          leagueName: data.leagueName,
          date: data.date,
          homeTeam: data.homeTeam,
          awayTeam: data.awayTeam,
          matchTime: data.matchTime,
          isPremiumPick: false,
          pickDirection: null,
          winRate: null,
          onAnalyze: () => context.push(
            '/analysis/baseball/match-report/${data.matchId}',
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final auth = ref.watch(authProvider);

    void onPremiumCtaTap({required SportType sport}) {
      if (auth.hasFullAccess) {
        context.go(
          sport == SportType.baseball ? '/premium?sport=baseball' : '/premium',
        );
      } else {
        navigateToSubscribeIfLoggedIn(context, auth.isLoggedIn);
      }
    }

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SportsToggle(
              selectedSport: _selectedSport,
              onChanged: (sport) {
                setState(() {
                  _selectedSport = sport;
                  _selectedLeagueId = 'all';
                });
                if (sport == SportType.soccer) {
                  ref.read(selectedLeagueProvider.notifier).state = null;
                }
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedSport == SportType.soccer)
                    PremiumPickStatsCard(
                      showCTA: true,
                      onCTATap: () => onPremiumCtaTap(sport: SportType.soccer),
                    )
                  else
                    TodayComboCard(
                      comboCount: '20',
                      accuracy: '50%',
                      avgOdds: '4.29',
                      onCTATap: () => onPremiumCtaTap(sport: SportType.baseball),
                    ),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  if (_selectedSport == SportType.soccer)
                    const SoccerMatchesSection()
                  else
                    ..._buildBaseballCardWidgets(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
