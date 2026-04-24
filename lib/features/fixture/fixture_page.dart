import 'package:flutter/material.dart' hide FilterChip;

import '../../core/models/fixture_models.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../shared/widgets/appbar/app_bar_home.dart'
    show AppBarHome, AppBarState;
import '../../shared/widgets/filter/filter_chip.dart';
import '../../shared/widgets/fixture/date_nav_chip.dart';
import '../../shared/widgets/fixture/fixture_league_header.dart';
import '../../shared/widgets/fixture/fixture_matches_card.dart';
import '../../shared/widgets/toggle/sport_toggle.dart';
import 'fixture_dummy_data.dart';

const String _kAll = 'all';

class _LeagueFilterDef {
  const _LeagueFilterDef({
    required this.id,
    required this.label,
    this.logoUrl,
  });

  final String id;
  final String label;
  final String? logoUrl;
}

List<_LeagueFilterDef> get _soccerLeagueFilters => const [
      _LeagueFilterDef(id: _kAll, label: 'All'),
      _LeagueFilterDef(
        id: 'ucl',
        label: 'Champions League',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'uel',
        label: 'Europa League',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'epl',
        label: 'Premier League',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'laliga',
        label: 'La Liga',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'bundesliga',
        label: 'Bundesliga',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'seriea',
        label: 'Serie A',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'ligue1',
        label: 'Ligue 1',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'eredivisie',
        label: 'Eredivisie',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'mls',
        label: 'MLS',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'kleague',
        label: 'K League',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'jleague',
        label: 'J League',
        logoUrl: kFixturePlaceholderLogo,
      ),
    ];

List<_LeagueFilterDef> get _baseballLeagueFilters => const [
      _LeagueFilterDef(id: _kAll, label: 'All'),
      _LeagueFilterDef(
        id: 'kbo',
        label: 'KBO',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'mlb',
        label: 'MLB',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'npb',
        label: 'NPB',
        logoUrl: kFixturePlaceholderLogo,
      ),
      _LeagueFilterDef(
        id: 'cpbl',
        label: 'CPBL',
        logoUrl: kFixturePlaceholderLogo,
      ),
    ];

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Fixtures: date rail (LIVE + 7 days), sport & league filters, league-grouped matches.
class FixturePage extends StatefulWidget {
  const FixturePage({super.key});

  @override
  State<FixturePage> createState() => _FixturePageState();
}

class _FixturePageState extends State<FixturePage> {
  SportType _selectedSport = SportType.soccer;
  late DateTime _selectedDate;
  String _selectedLeagueId = _kAll;
  bool _dateNavLive = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  List<FixtureLeague> get _rawLeagues {
    return _selectedSport == SportType.soccer
        ? dummySoccerFixtureLeagues()
        : dummyBaseballFixtureLeagues();
  }

  List<_LeagueFilterDef> get _leagueFilterDefs {
    return _selectedSport == SportType.soccer
        ? _soccerLeagueFilters
        : _baseballLeagueFilters;
  }

  List<FixtureLeague> _applyLeagueIdFilter(List<FixtureLeague> leagues) {
    if (_selectedLeagueId == _kAll) {
      return leagues;
    }
    return leagues.where((l) => l.leagueId == _selectedLeagueId).toList();
  }

  List<FixtureLeague> get _visibleLeagues {
    final raw = _rawLeagues;
    if (_dateNavLive) {
      final liveOnly = raw
          .map(
            (l) => l.copyWith(
              matches: l.matches
                  .where((m) => m.status.toLowerCase() == 'live')
                  .toList(),
            ),
          )
          .where((l) => l.matches.isNotEmpty)
          .toList();
      return _applyLeagueIdFilter(liveOnly);
    }
    final day = _dateOnly(_selectedDate);
    final byDay = raw
        .map(
          (l) => l.copyWith(
            matches: l.matches
                .where((m) => _dateOnly(m.matchDateTime) == day)
                .toList(),
          ),
        )
        .where((l) => l.matches.isNotEmpty)
        .toList();
    return _applyLeagueIdFilter(byDay);
  }

  void _onSportChanged(SportType sport) {
    setState(() {
      _selectedSport = sport;
      _selectedLeagueId = _kAll;
      _dateNavLive = false;
      _selectedDate = _dateOnly(DateTime.now());
    });
  }

  void _onMatchTap(FixtureMatch match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Match detail (stub): ${match.matchId}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarToday = _dateOnly(DateTime.now());
    final rangeStart = calendarToday.subtract(const Duration(days: 1));
    final days =
        List.generate(7, (i) => _dateOnly(rangeStart.add(Duration(days: i))));

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBarHome(state: AppBarState.guest),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        SportToggle(
                          selectedSport: _selectedSport,
                          onSportChanged: _onSportChanged,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              DateNavChip(
                                type: DateNavChipType.live,
                                isSelected: _dateNavLive,
                                onTap: () => setState(() {
                                  _dateNavLive = true;
                                }),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              for (var i = 0; i < days.length; i++) ...[
                                if (i > 0) const SizedBox(width: AppSpacing.md),
                                DateNavChip(
                                  type: DateNavChipType.day,
                                  date: days[i],
                                  isToday: days[i] == calendarToday,
                                  isSelected: !_dateNavLive &&
                                      _dateOnly(_selectedDate) == days[i],
                                  onTap: () => setState(() {
                                    _dateNavLive = false;
                                    _selectedDate = days[i];
                                  }),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0;
                                  i < _leagueFilterDefs.length;
                                  i++) ...[
                                if (i > 0) const SizedBox(width: 12),
                                _buildLeagueFilterChip(
                                  _leagueFilterDefs[i],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: _buildLeagueList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueFilterChip(_LeagueFilterDef def) {
    final isAll = def.id == _kAll;
    return FilterChip(
      text: def.label,
      isSelected: _selectedLeagueId == def.id,
      onTap: () => setState(() => _selectedLeagueId = def.id),
      type: isAll
          ? FilterChipType.textOnly
          : FilterChipType.withAPI,
      logoUrl: isAll ? null : def.logoUrl,
    );
  }

  Widget _buildLeagueList() {
    final leagues = _visibleLeagues;
    if (leagues.isEmpty) {
      return const Center(
        child: Text(
          'No matches for this selection',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      itemCount: leagues.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xl),
      itemBuilder: (context, index) {
        final league = leagues[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FixtureLeagueHeader(
              leagueName: league.leagueName,
              logoUrl: league.logoUrl,
            ),
            const SizedBox(height: AppSpacing.md),
            FixtureMatchesCard(
              matches: league.matches,
              onMatchTap: _onMatchTap,
            ),
          ],
        );
      },
    );
  }
}
