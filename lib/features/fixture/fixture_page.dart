import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/analysis_dummy_data.dart';
import 'package:trendsoccer/features/fixture/fixture_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';
import 'package:trendsoccer/shared/widgets/fixture/alarm_sheet.dart';
import 'package:trendsoccer/shared/widgets/fixture/date_nav_chip.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_header.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_match_row.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_matches_card.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_status.dart';
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
  final Set<String> _notificationMatchIds = {};

  static final _md = DateFormat('M.d');

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayLabel(DateTime date) {
    final anchor = FixturePage._anchorToday;
    final anchorDay = DateTime(anchor.year, anchor.month, anchor.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final diff = dateDay.difference(anchorDay).inDays;
    if (diff == -1) return '어제';
    if (diff == 0) return '오늘';
    if (diff == 1) return '내일';
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

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
    final anchorDay = DateTime(anchor.year, anchor.month, anchor.day);
    final yesterday = anchorDay.subtract(const Duration(days: 1));
    final tomorrow = anchorDay.add(const Duration(days: 1));
    final weekendStrip =
        [5, 6, 7].map((offset) => anchorDay.add(Duration(days: offset))).toList();

    final children = <Widget>[
      DateNavChip(
        type: DateNavChipType.live,
        isActive: _isLiveFilter,
        onTap: () => setState(() => _isLiveFilter = !_isLiveFilter),
      ),
      const SizedBox(width: 8),
      DateNavChip(
        type: DateNavChipType.date,
        dayLabel: '어제',
        dateLabel: _md.format(yesterday),
        isActive: !_isLiveFilter && _isSameDay(_selectedDate, yesterday),
        onTap: () => setState(() {
          _selectedDate = yesterday;
          _isLiveFilter = false;
        }),
      ),
      const SizedBox(width: 8),
      DateNavChip(
        type: DateNavChipType.today,
        dayLabel: '오늘',
        dateLabel: _md.format(anchor),
        isActive: !_isLiveFilter && _isSameDay(_selectedDate, anchor),
        onTap: () => setState(() {
          _selectedDate = anchor;
          _isLiveFilter = false;
        }),
      ),
      const SizedBox(width: 8),
      DateNavChip(
        type: DateNavChipType.date,
        dayLabel: '내일',
        dateLabel: _md.format(tomorrow),
        isActive: !_isLiveFilter && _isSameDay(_selectedDate, tomorrow),
        onTap: () => setState(() {
          _selectedDate = tomorrow;
          _isLiveFilter = false;
        }),
      ),
    ];

    for (final d in weekendStrip) {
      children
        ..add(const SizedBox(width: 8))
        ..add(
          DateNavChip(
            type: DateNavChipType.date,
            dayLabel: _dayLabel(d),
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
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }

  Widget _buildLeagueFilters() {
    final filters =
        _selectedSport == SportType.soccer ? soccerLeagueFilters : baseballLeagueFilters;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return TsFilterChip(
            label: filter.label,
            isSelected: _selectedLeagueId == filter.id,
            type: filter.hasIcon ? TsFilterChipType.withIcon : TsFilterChipType.textOnly,
            iconWidget: filter.hasIcon ? TsLeagueIcon(leagueId: filter.id, size: 16) : null,
            onTap: () => setState(() => _selectedLeagueId = filter.id),
          );
        },
      ),
    );
  }

  List<Widget> _buildMatchWidgets() {
    final filtered = _applyFilters();
    if (filtered.isEmpty) return [];

    final groups = groupByLeague(filtered);
    return groups.asMap().entries.expand((entry) {
      final gi = entry.key;
      final group = entry.value;
      return [
        FixtureLeagueHeader(
          leagueId: group.leagueId,
          leagueName: group.leagueName,
          leagueLogoUrl: group.leagueLogoUrl,
        ),
        const SizedBox(height: 8),
        FixtureMatchesCard(
          children: [
            for (final match in group.matches)
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
                isNotificationOn: _notificationMatchIds.contains(match.matchId),
                onNotificationTap: (match.status == 'scheduled' || match.status == 'live')
                    ? () => setState(() {
                          final id = match.matchId;
                          if (_notificationMatchIds.contains(id)) {
                            _notificationMatchIds.remove(id);
                          } else {
                            _notificationMatchIds.add(id);
                            showAlarmSheet(context, _selectedSport);
                          }
                        })
                    : null,
              ),
          ],
        ),
        if (gi < groups.length - 1) const SizedBox(height: 16),
      ];
    }).toList();
  }

  Widget _buildLiveFilterEmptyState(TsSemanticColors semantic) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          TsAssets.iconHourglassEmpty,
          width: 48,
          height: 48,
          colorFilter: ColorFilter.mode(
            semantic.textTertiary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: TsSpacing.md),
        Text(
          '데이터가 없습니다.',
          style: TsType.bodyLBold.copyWith(color: semantic.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.md),
        Text(
          '나중에 다시 확인해주세요.',
          style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.md),
        IntrinsicWidth(
          child: GestureDetector(
            onTap: () => setState(() {
              _isLiveFilter = false;
              _selectedDate = FixturePage._anchorToday;
              _selectedLeagueId = 'all';
            }),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: semantic.interactivePrimary,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '오늘 경기 확인하기',
                style: TsType.bodyMBold.copyWith(color: semantic.interactivePrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final filtered = _applyFilters();
    final matchWidgets = _buildMatchWidgets();
    final isLiveEmpty = filtered.isEmpty && _isLiveFilter;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SportsToggle(
                  selectedSport: _selectedSport,
                  onChanged: (sport) => setState(() {
                    _selectedSport = sport;
                    _selectedLeagueId = 'all';
                    _isLiveFilter = false;
                    _selectedDate = FixturePage._anchorToday;
                  }),
                ),
                const SizedBox(height: 16),
                _buildDateNavStrip(),
                const SizedBox(height: 16),
                _buildLeagueFilters(),
              ],
            ),
          ),
          if (matchWidgets.isEmpty)
            Expanded(
              child: Center(
                child: isLiveEmpty
                    ? _buildLiveFilterEmptyState(semantic)
                    : TsEmptyState(type: TsEmptyStateType.defaultState),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...matchWidgets,
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
