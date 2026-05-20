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
import 'package:trendsoccer/shared/widgets/cards/premium_pick_card.dart';
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
    final filters = _selectedSport == SportType.soccer
        ? soccerLeagueFilters
        : baseballLeagueFilters;
    final selectedSoccerLeague = ref.watch(selectedLeagueProvider);

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedSport == SportType.soccer
              ? (filter.id == 'all'
                  ? selectedSoccerLeague == null
                  : selectedSoccerLeague == filter.id)
              : _selectedLeagueId == filter.id;
          return TsFilterChip(
            label: filter.label,
            isSelected: isSelected,
            type: filter.hasIcon
                ? TsFilterChipType.withIcon
                : TsFilterChipType.textOnly,
            iconWidget: filter.hasIcon
                ? TsLeagueIcon(leagueId: filter.id, size: 16)
                : null,
            onTap: () {
              if (_selectedSport == SportType.soccer) {
                ref.read(selectedLeagueProvider.notifier).state =
                    filter.id == 'all' ? null : filter.id;
              } else {
                setState(() => _selectedLeagueId = filter.id);
              }
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildBaseballCardWidgets() {
    final allCards = baseballAnalysisDummy;

    final filteredCards = _selectedLeagueId == 'all'
        ? allCards
        : allCards.where((c) => c.leagueId == _selectedLeagueId).toList();

    if (filteredCards.isEmpty) {
      return [const TsEmptyState()];
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SportsToggle(
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
            const SizedBox(height: 16),
            if (_selectedSport == SportType.soccer) ...[
              PremiumPickCard(
                showCTA: true,
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
                onCTATap: () => onPremiumCtaTap(sport: SportType.soccer),
              ),
              const SizedBox(height: 16),
            ],
            if (_selectedSport == SportType.baseball) ...[
              TodayComboCard(
                comboCount: '20',
                accuracy: '50%',
                avgOdds: '4.29',
                onCTATap: () => onPremiumCtaTap(sport: SportType.baseball),
              ),
              const SizedBox(height: 16),
            ],
            _buildFilterChips(),
            const SizedBox(height: 16),
            if (_selectedSport == SportType.soccer)
              const SoccerMatchesSection()
            else
              ..._buildBaseballCardWidgets(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
