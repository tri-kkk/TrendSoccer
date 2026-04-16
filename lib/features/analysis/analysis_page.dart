import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../shared/widgets/appbar/app_bar_home.dart';
import '../../shared/widgets/cards/analysis_card.dart';
import '../../shared/widgets/cards/premium_pick_card.dart';
import '../../shared/widgets/empty/empty_state.dart';
import '../../shared/widgets/filter/filter_chip.dart';
import '../../shared/widgets/league/league_icon.dart';
import '../../shared/widgets/toggle/sport_toggle.dart';

// ── Dummy data ────────────────────────────────────────────────────────────────

const _soccerMatches = <Map<String, String>>[
  {
    'leagueCode': 'EPL',
    'homeTeam': 'Chelsea',
    'awayTeam': 'Arsenal',
    'date': '04.13',
    'time': '21:00',
  },
  {
    'leagueCode': 'LALIGA',
    'homeTeam': 'Barcelona',
    'awayTeam': 'Real Madrid',
    'date': '04.13',
    'time': '22:00',
  },
  {
    'leagueCode': 'BUNDESLIGA',
    'homeTeam': 'Bayern',
    'awayTeam': 'Dortmund',
    'date': '04.14',
    'time': '19:30',
  },
];

const _baseballMatches = <Map<String, String>>[
  {
    'leagueCode': 'KBO',
    'homeTeam': 'Doosan Bears',
    'awayTeam': 'Samsung Lions',
    'date': '04.13',
    'time': '18:30',
  },
  {
    'leagueCode': 'MLB',
    'homeTeam': 'Yankees',
    'awayTeam': 'Red Sox',
    'date': '04.13',
    'time': '20:00',
  },
  {
    'leagueCode': 'NPB',
    'homeTeam': 'Giants',
    'awayTeam': 'Tigers',
    'date': '04.14',
    'time': '14:00',
  },
];

/// Maps display chip labels (Korean / abbreviated) to the leagueCode used in
/// match data. Keys that already match their code are omitted.
const _labelToCode = <String, String>{
  '라리가': 'LALIGA',
  '분데스': 'BUNDESLIGA',
  '세리에A': 'SERIEA',
  '리그1': 'LIGUE1',
};

// ── Page ──────────────────────────────────────────────────────────────────────

/// The Analysis page — lets users toggle between Soccer and Baseball,
/// filter matches by league, and navigate to individual match analysis.
///
/// Local state:
/// - [_selectedSport] — which sport toggle is active.
/// - [_selectedLeague] — which filter chip is selected (`"All"` = all leagues).
///
/// The [PremiumPickCard] is shown only when [SportType.soccer] is active.
/// An AI disclaimer footer is shown only when [SportType.baseball] is active.
///
/// Layout follows Figma node `Analysis Page`.
class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  SportType _selectedSport = SportType.soccer;
  String _selectedLeague = 'All';

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the ordered league filter keys for the currently active sport.
  ///
  /// `'All'` is the sentinel value meaning no filter. All other keys are
  /// resolved to a `leagueCode` via [_resolveCode] before filtering.
  List<String> get _leagueFilters {
    return _selectedSport == SportType.soccer
        ? ['All', 'EPL', '라리가', '분데스', '세리에A', '리그1']
        : ['All', 'KBO', 'MLB', 'NPB', 'CPBL'];
  }

  /// Resolves a chip [label] to the corresponding `leagueCode` in match data.
  String _resolveCode(String label) => _labelToCode[label] ?? label;

  /// Returns matches for the active sport, optionally filtered to a league.
  List<Map<String, String>> _getFilteredMatches() {
    final pool =
        _selectedSport == SportType.soccer ? _soccerMatches : _baseballMatches;
    if (_selectedLeague == 'All') return pool;
    final code = _resolveCode(_selectedLeague);
    return pool.where((m) => m['leagueCode'] == code).toList();
  }

  // ── Sport toggle handler ───────────────────────────────────────────────────

  void _onSportChanged(SportType sport) {
    setState(() {
      _selectedSport = sport;
      _selectedLeague = 'All';
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBarHome(state: AppBarState.guest),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSportToggle(),
                    const SizedBox(height: AppSpacing.xl),
                    if (_selectedSport == SportType.soccer) ...[
                      _buildPremiumPickCard(),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    _buildFilterChips(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildMatchList(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section builders ───────────────────────────────────────────────────────

  Widget _buildSportToggle() {
    return SportToggle(
      selectedSport: _selectedSport,
      onSportChanged: _onSportChanged,
    );
  }

  Widget _buildPremiumPickCard() {
    return PremiumPickCard(
      onCheckTap: () => debugPrint('Navigate to Premium Pick'),
    );
  }

  /// Horizontally scrollable row of [SportFilterChip] widgets.
  ///
  /// "All" chip has no leading icon. All other chips resolve their display
  /// label via [LeagueIcon.getLeagueName] and pass the league code for the
  /// leading icon. The [SportFilterChip] already suppresses the icon when
  /// `leagueCode` is `null`.
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_leagueFilters.length, (index) {
          final league = _leagueFilters[index];
          final isAll = league == 'All';
          final code = isAll ? null : _resolveCode(league);
          final label = isAll ? 'All' : LeagueIcon.getLeagueName(code!);
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
            child: SportFilterChip(
              label: label,
              leagueCode: code,
              isSelected: _selectedLeague == league,
              onTap: () => setState(() => _selectedLeague = league),
            ),
          );
        }),
      ),
    );
  }

  /// Vertical list of [AnalysisCard] widgets, or [EmptyState] when empty.
  Widget _buildMatchList() {
    final matches = _getFilteredMatches();

    if (matches.isEmpty) {
      return const EmptyState(
        icon: Icons.sports_soccer,
        title: 'No matches available',
        description: 'Check back later for analysis',
      );
    }

    return Column(
      children: List.generate(matches.length, (index) {
        final match = matches[index];
        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : AppSpacing.xl),
          child: AnalysisCard(
            leagueCode: match['leagueCode']!,
            date: match['date']!,
            homeTeam: match['homeTeam']!,
            awayTeam: match['awayTeam']!,
            time: match['time']!,
          ),
        );
      }),
    );
  }

}
