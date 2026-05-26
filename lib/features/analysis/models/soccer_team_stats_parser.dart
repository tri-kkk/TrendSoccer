class TeamStatsParsed {
  const TeamStatsParsed({
    required this.last10Wins,
    required this.last10Draws,
    required this.last10Losses,
    required this.last5Results,
    required this.recentMatches,
    required this.recordWins,
    required this.recordDraws,
    required this.recordLosses,
    required this.recordWinRate,
    required this.over15Rate,
    required this.over25Rate,
    required this.over35Rate,
    required this.bttsRate,
    required this.cleanSheetRate,
    required this.scorelessRate,
    required this.strengths,
    required this.weaknesses,
  });

  factory TeamStatsParsed.fromResponse(
    Map<String, dynamic> response, {
    required bool isHome,
  }) {
    final data = _readMap(response, const ['data']) ?? response;
    final recentForm = _readMap(data, const ['recentForm']) ?? {};
    final last10 = _readMap(recentForm, const ['last10']) ?? {};
    final last5 = _readMap(recentForm, const ['last5']) ?? {};
    final record = isHome
        ? (_readMap(data, const ['homeStats']) ?? {})
        : (_readMap(data, const ['awayStats']) ?? {});
    final markets = _readMap(data, const ['markets']) ?? {};
    final matchesRaw = data['recentMatches'];
    final matches = <TeamRecentMatch>[];
    if (matchesRaw is List) {
      for (final item in matchesRaw) {
        if (item is Map) {
          matches.add(TeamRecentMatch.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    int calcOverRate(List<TeamRecentMatch> matchList, double threshold) {
      if (matchList.isEmpty) return 0;
      final count = matchList
          .where((m) => (m.goalsFor + m.goalsAgainst) > threshold)
          .length;
      return (count / matchList.length * 100).round();
    }

    final last10Matches = matches.take(10).toList();

    return TeamStatsParsed(
      last10Wins: _toInt(last10['wins']),
      last10Draws: _toInt(last10['draws']),
      last10Losses: _toInt(last10['losses']),
      last5Results: _toStringList(last5['results']),
      recentMatches: matches.take(5).toList(),
      recordWins: _toInt(record['wins']),
      recordDraws: _toInt(record['draws']),
      recordLosses: _toInt(record['losses']),
      recordWinRate: _toInt(record['winRate'] ?? record['win_rate']),
      over15Rate: calcOverRate(last10Matches, 1.5),
      over25Rate: _toInt(markets['over25Rate'] ?? markets['over_25_rate']),
      over35Rate: calcOverRate(last10Matches, 3.5),
      bttsRate: _toInt(markets['bttsRate'] ?? markets['btts_rate']),
      cleanSheetRate:
          _toInt(markets['cleanSheetRate'] ?? markets['clean_sheet_rate']),
      scorelessRate:
          _toInt(markets['scorelessRate'] ?? markets['scoreless_rate']),
      strengths: _toStringList(data['strengths']),
      weaknesses: _toStringList(data['weaknesses']),
    );
  }

  static const empty = TeamStatsParsed(
    last10Wins: 0,
    last10Draws: 0,
    last10Losses: 0,
    last5Results: [],
    recentMatches: [],
    recordWins: 0,
    recordDraws: 0,
    recordLosses: 0,
    recordWinRate: 0,
    over15Rate: 0,
    over25Rate: 0,
    over35Rate: 0,
    bttsRate: 0,
    cleanSheetRate: 0,
    scorelessRate: 0,
    strengths: [],
    weaknesses: [],
  );

  final int last10Wins;
  final int last10Draws;
  final int last10Losses;
  final List<String> last5Results;
  final List<TeamRecentMatch> recentMatches;
  final int recordWins;
  final int recordDraws;
  final int recordLosses;
  final int recordWinRate;
  final int over15Rate;
  final int over25Rate;
  final int over35Rate;
  final int bttsRate;
  final int cleanSheetRate;
  final int scorelessRate;
  final List<String> strengths;
  final List<String> weaknesses;

  bool get hasData =>
      last10Wins + last10Draws + last10Losses > 0 ||
      recentMatches.isNotEmpty ||
      strengths.isNotEmpty ||
      weaknesses.isNotEmpty;

  List<String> get teamInsights {
    final combined = [...strengths, ...weaknesses];
    if (combined.isEmpty) return const ['-'];
    return combined.take(3).toList();
  }
}

class TeamRecentMatch {
  const TeamRecentMatch({
    required this.date,
    required this.opponent,
    required this.opponentKo,
    required this.result,
    required this.isHome,
    required this.goalsFor,
    required this.goalsAgainst,
    this.opponentLogo,
    this.opponentTeamId,
  });

  factory TeamRecentMatch.fromJson(Map<String, dynamic> json) {
    return TeamRecentMatch(
      date: json['date']?.toString() ?? '',
      opponent: json['opponent']?.toString() ?? '',
      opponentKo: json['opponentKo']?.toString() ??
          json['opponent_ko']?.toString() ??
          '',
      result: json['result']?.toString().toUpperCase() ?? '',
      isHome: json['isHome'] == true || json['is_home'] == true,
      goalsFor: _toInt(json['goalsFor'] ?? json['goals_for']),
      goalsAgainst: _toInt(json['goalsAgainst'] ?? json['goals_against']),
      opponentLogo: _nonEmptyOrNull(json['opponentLogo'] ?? json['opponent_logo']),
      opponentTeamId: _toNullableInt(
        json['opponentTeamId'] ?? json['opponent_team_id'],
      ),
    );
  }

  final String date;
  final String opponent;
  final String opponentKo;
  final String result;
  final bool isHome;
  final int goalsFor;
  final int goalsAgainst;
  final String? opponentLogo;
  final int? opponentTeamId;

  String get scoreDisplay => '$goalsFor-$goalsAgainst';
}

Map<String, dynamic>? _readMap(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
}

int _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _toNullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _nonEmptyOrNull(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

List<String> _toStringList(Object? value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
}
