import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/fixture/fixture_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';
import 'package:trendsoccer/shared/widgets/fixture/date_nav_chip.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_header.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_match_row.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_status.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_matches_card.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';
import 'package:trendsoccer/shared/widgets/toggle/sports_toggle.dart';

class FixturePage extends StatefulWidget {
  const FixturePage({super.key});

  static final DateTime _anchorToday = DateTime(2026, 5, 11);

  @override
  State<FixturePage> createState() => _FixturePageState();
}

class _FixturePageState extends State<FixturePage> {
  SportType _selectedSport = SportType.soccer;
  DateTime _selectedDate = FixturePage._anchorToday;
  String _selectedLeagueId = 'all';
  bool _isLiveFilter = false;

  static final _md = DateFormat('M.d');
  static final _eee = DateFormat('EEE');

  static final List<Map<String, String>> _soccerLeagueFilters = [
    {'id': 'all', 'name': 'All'},
    {'id': 'epl', 'name': 'EPL'},
    {'id': 'ucl', 'name': 'UCL'},
    {'id': 'laliga', 'name': 'La Liga'},
    {'id': 'bundesliga', 'name': 'Bundesliga'},
    {'id': 'seriea', 'name': 'Serie A'},
    {'id': 'ligue1', 'name': 'Ligue 1'},
  ];

  static final List<Map<String, String>> _baseballLeagueFilters = [
    {'id': 'all', 'name': 'All'},
    {'id': 'kbo', 'name': 'KBO'},
    {'id': 'mlb', 'name': 'MLB'},
    {'id': 'npb', 'name': 'NPB'},
    {'id': 'cpbl', 'name': 'CPBL'},
  ];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  FixtureMatchStatus _toFixtureStatus(String status) {
    switch (status) {
      case 'live':
        return FixtureMatchStatus.live;
      case 'finished':
        return FixtureMatchStatus.finished;
      default:
        return FixtureMatchStatus.scheduled;
    }
  }

  List<FixtureMatchData> _sourceMatches() {
    return _selectedSport == SportType.soccer ? soccerFixtureDummy : baseballFixtureDummy;
  }

  List<FixtureMatchData> _applyFilters() {
    var list = _sourceMatches();
    if (!_isLiveFilter) {
      list = list.where((m) => _isSameDay(m.matchDate, _selectedDate)).toList();
    } else {
      list = list.where((m) => m.status == 'live').toList();
    }
    if (_selectedLeagueId != 'all') {
      list = list.where((m) => m.leagueId == _selectedLeagueId).toList();
    }
    return list;
  }

  Widget _buildDateNavStrip() {
    final anchor = FixturePage._anchorToday;
    final yesterday = DateTime(anchor.year, anchor.month, anchor.day)
        .subtract(const Duration(days: 1));
    final children = <Widget>[
      DateNavChip(
        type: DateNavChipType.live,
        isActive: _isLiveFilter,
        onTap: () => setState(() => _isLiveFilter = !_isLiveFilter),
      ),
      const SizedBox(width: TsSpacing.sm),
      DateNavChip(
        type: DateNavChipType.date,
        dayLabel: _eee.format(yesterday),
        dateLabel: _md.format(yesterday),
        isActive: !_isLiveFilter && _isSameDay(_selectedDate, yesterday),
        onTap: () => setState(() {
          _selectedDate = yesterday;
          _isLiveFilter = false;
        }),
      ),
      const SizedBox(width: TsSpacing.sm),
      DateNavChip(
        type: DateNavChipType.today,
        dayLabel: 'Today',
        dateLabel: _md.format(anchor),
        isActive: !_isLiveFilter && _isSameDay(_selectedDate, anchor),
        onTap: () => setState(() {
          _selectedDate = anchor;
          _isLiveFilter = false;
        }),
      ),
    ];

    for (var i = 1; i <= 5; i++) {
      final d = DateTime(anchor.year, anchor.month, anchor.day).add(Duration(days: i));
      children
        ..add(const SizedBox(width: TsSpacing.sm))
        ..add(
          DateNavChip(
            type: DateNavChipType.date,
            dayLabel: _eee.format(d),
            dateLabel: _md.format(d),
            isActive: !_isLiveFilter && _isSameDay(_selectedDate, d),
            onTap: () => setState(() {
              _selectedDate = d;
              _isLiveFilter = false;
            }),
          ),
        );
    }

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        children: children,
      ),
    );
  }

  Widget _buildLeagueFilters() {
    final filters =
        _selectedSport == SportType.soccer ? _soccerLeagueFilters : _baseballLeagueFilters;
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) {
          final f = filters[index];
          final id = f['id']!;
          final name = f['name']!;
          return TsFilterChip(
            label: name,
            isSelected: _selectedLeagueId == id,
            type: id == 'all' ? FilterChipType.textOnly : FilterChipType.withIcon,
            iconWidget: id != 'all' ? TsLeagueIcon(leagueId: id, size: 16) : null,
            onTap: () => setState(() => _selectedLeagueId = id),
          );
        },
      ),
    );
  }

  Widget _buildMatchesList() {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final filtered = _applyFilters();

    if (filtered.isEmpty && _isLiveFilter) {
      return Column(
        children: [
          const SizedBox(height: 48),
          Text(
            'No Active Live Matches',
            style: TsType.bodyLBold.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Center(
            child: TsButton(
              label: 'Show All Matches',
              variant: TsButtonVariant.secondary,
              size: TsButtonSize.small,
              onPressed: () => setState(() => _isLiveFilter = false),
            ),
          ),
        ],
      );
    }

    if (filtered.isEmpty) {
      return TsEmptyState(type: TsEmptyStateType.defaultState);
    }

    final groups = groupByLeague(filtered);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var gi = 0; gi < groups.length; gi++) ...[
            FixtureLeagueHeader(
              leagueId: groups[gi].leagueId,
              leagueName: groups[gi].leagueName,
              leagueLogoUrl: groups[gi].leagueLogoUrl,
            ),
            const SizedBox(height: TsSpacing.sm),
            FixtureMatchesCard(
              children: [
                for (final match in groups[gi].matches)
                  FixtureMatchRow(
                    status: _toFixtureStatus(match.status),
                    timeText: match.status == 'scheduled'
                        ? match.matchTime
                        : match.status == 'finished'
                            ? match.matchTime
                            : null,
                    homeTeam: match.homeTeam,
                    awayTeam: match.awayTeam,
                    homeLogoUrl: match.homeLogoUrl,
                    awayLogoUrl: match.awayLogoUrl,
                    homeScore: match.homeScore,
                    awayScore: match.awayScore,
                    isNotificationOn: false,
                    onNotificationTap: null,
                  ),
              ],
            ),
            if (gi < groups.length - 1) const SizedBox(height: TsSpacing.lg),
          ],
        ],
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
                  _selectedLeagueId = 'all';
                  _isLiveFilter = false;
                  _selectedDate = FixturePage._anchorToday;
                }),
              ),
            ),
            const SizedBox(height: TsSpacing.md),
            _buildDateNavStrip(),
            const SizedBox(height: TsSpacing.md),
            _buildLeagueFilters(),
            const SizedBox(height: TsSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                child: _buildMatchesList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
