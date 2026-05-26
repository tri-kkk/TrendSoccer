class SoccerPremiumParsed {
  const SoccerPremiumParsed({
    this.overall,
    this.recent5,
    this.firstGoal,
    this.scorePatterns,
    this.recentMatches = const [],
    this.insights = const [],
    this.calcAvgTotalGoals = '-',
    this.calcOver25Rate = 0,
    this.calcBttsRate = 0,
  });

  factory SoccerPremiumParsed.fromResponse(Map<String, dynamic> response) {
    final data = _readMap(response, const ['data']) ?? response;
    final recentMatches = _parseRecentMatches(data['recentMatches']);
    final n = recentMatches.length;

    var calcAvgTotalGoals = '-';
    var calcOver25Rate = 0;
    var calcBttsRate = 0;
    if (n > 0) {
      final totalGoals = recentMatches.fold<int>(
        0,
        (sum, match) => sum + match.homeScore + match.awayScore,
      );
      calcAvgTotalGoals = (totalGoals / n).toStringAsFixed(1);
      calcOver25Rate = (recentMatches
                  .where((match) => (match.homeScore + match.awayScore) > 2.5)
                  .length /
              n *
              100)
          .round();
      calcBttsRate = (recentMatches
                  .where((match) => match.homeScore > 0 && match.awayScore > 0)
                  .length /
              n *
              100)
          .round();
    }

    return SoccerPremiumParsed(
      overall: H2HOverall.fromJson(_readMap(data, const ['overall'])),
      recent5: H2HRecent5.fromJson(_readMap(data, const ['recent5'])),
      firstGoal: H2HFirstGoal.fromJson(
        _readMap(data, const ['firstGoalAnalysis', 'firstGoal', 'first_goal']),
      ),
      scorePatterns: H2HScorePatterns.fromJson(
        _readMap(data, const ['scorePatterns', 'score_patterns']),
      ),
      recentMatches: recentMatches,
      insights: _parseStringList(data['insights']),
      calcAvgTotalGoals: calcAvgTotalGoals,
      calcOver25Rate: calcOver25Rate,
      calcBttsRate: calcBttsRate,
    );
  }

  final H2HOverall? overall;
  final H2HRecent5? recent5;
  final H2HFirstGoal? firstGoal;
  final H2HScorePatterns? scorePatterns;
  final List<H2HMatch> recentMatches;
  final List<String> insights;
  final String calcAvgTotalGoals;
  final int calcOver25Rate;
  final int calcBttsRate;
}

class H2HOverall {
  const H2HOverall({
    required this.totalMatches,
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    required this.homeWinRate,
    required this.drawRate,
    required this.awayWinRate,
    required this.homeGoals,
    required this.awayGoals,
    required this.avgTotalGoals,
  });

  factory H2HOverall.fromJson(Map<String, dynamic>? json) {
    if (json == null) return H2HOverall.empty;
    return H2HOverall(
      totalMatches: _parseInt(json['totalMatches'] ?? json['total_matches']) ?? 0,
      homeWins: _parseInt(json['homeWins'] ?? json['home_wins']) ?? 0,
      draws: _parseInt(json['draws'] ?? json['draw']) ?? 0,
      awayWins: _parseInt(json['awayWins'] ?? json['away_wins']) ?? 0,
      homeWinRate: _parseInt(json['homeWinRate'] ?? json['home_win_rate']) ?? 0,
      drawRate: _parseInt(json['drawRate'] ?? json['draw_rate']) ?? 0,
      awayWinRate: _parseInt(json['awayWinRate'] ?? json['away_win_rate']) ?? 0,
      homeGoals: _parseInt(json['homeGoals'] ?? json['home_goals']) ?? 0,
      awayGoals: _parseInt(json['awayGoals'] ?? json['away_goals']) ?? 0,
      avgTotalGoals: _parseInt(json['avgTotalGoals'] ?? json['avg_total_goals']) ?? 0,
    );
  }

  static const empty = H2HOverall(
    totalMatches: 0,
    homeWins: 0,
    draws: 0,
    awayWins: 0,
    homeWinRate: 0,
    drawRate: 0,
    awayWinRate: 0,
    homeGoals: 0,
    awayGoals: 0,
    avgTotalGoals: 0,
  );

  final int totalMatches;
  final int homeWins;
  final int draws;
  final int awayWins;
  final int homeWinRate;
  final int drawRate;
  final int awayWinRate;
  final int homeGoals;
  final int awayGoals;
  final int avgTotalGoals;
}

class H2HRecent5 {
  const H2HRecent5({
    required this.matches,
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    required this.homeWinRate,
    required this.trend,
    required this.trendDescription,
  });

  factory H2HRecent5.fromJson(Map<String, dynamic>? json) {
    if (json == null) return H2HRecent5.empty;
    return H2HRecent5(
      matches: _parseInt(json['matches']) ?? 0,
      homeWins: _parseInt(json['homeWins'] ?? json['home_wins']) ?? 0,
      draws: _parseInt(json['draws'] ?? json['draw']) ?? 0,
      awayWins: _parseInt(json['awayWins'] ?? json['away_wins']) ?? 0,
      homeWinRate: _parseInt(json['homeWinRate'] ?? json['home_win_rate']) ?? 0,
      trend: json['trend']?.toString() ?? '',
      trendDescription: json['trendDescription']?.toString() ??
          json['trend_description']?.toString() ??
          '',
    );
  }

  static const empty = H2HRecent5(
    matches: 0,
    homeWins: 0,
    draws: 0,
    awayWins: 0,
    homeWinRate: 0,
    trend: '',
    trendDescription: '',
  );

  final int matches;
  final int homeWins;
  final int draws;
  final int awayWins;
  final int homeWinRate;
  final String trend;
  final String trendDescription;
}

class H2HFirstGoal {
  const H2HFirstGoal({
    required this.homeFirstGoalWinRate,
    required this.awayFirstGoalWinRate,
  });

  factory H2HFirstGoal.fromJson(Map<String, dynamic>? json) {
    if (json == null) return H2HFirstGoal.empty;
    return H2HFirstGoal(
      homeFirstGoalWinRate: _parseDouble(
            json['homeFirstGoalWinRate'] ?? json['home_first_goal_win_rate'],
          ) ??
          0,
      awayFirstGoalWinRate: _parseDouble(
            json['awayFirstGoalWinRate'] ?? json['away_first_goal_win_rate'],
          ) ??
          0,
    );
  }

  static const empty = H2HFirstGoal(
    homeFirstGoalWinRate: 0,
    awayFirstGoalWinRate: 0,
  );

  final double homeFirstGoalWinRate;
  final double awayFirstGoalWinRate;
}

class H2HScorePatterns {
  const H2HScorePatterns({
    required this.mostCommon,
    required this.avgHomeGoals,
    required this.avgAwayGoals,
    required this.over25Rate,
    required this.bttsRate,
  });

  factory H2HScorePatterns.fromJson(Map<String, dynamic>? json) {
    if (json == null) return H2HScorePatterns.empty;
    final mostCommonRaw = json['mostCommon'] ?? json['most_common'];
    final mostCommon = <Map<String, dynamic>>[];
    if (mostCommonRaw is List) {
      for (final item in mostCommonRaw) {
        if (item is Map) {
          mostCommon.add(Map<String, dynamic>.from(item));
        }
      }
    }
    return H2HScorePatterns(
      mostCommon: mostCommon,
      avgHomeGoals: _parseDouble(json['avgHomeGoals'] ?? json['avg_home_goals']) ?? 0,
      avgAwayGoals: _parseDouble(json['avgAwayGoals'] ?? json['avg_away_goals']) ?? 0,
      over25Rate: _parseInt(json['over25Rate'] ?? json['over_25_rate']) ?? 0,
      bttsRate: _parseInt(json['bttsRate'] ?? json['btts_rate']) ?? 0,
    );
  }

  static const empty = H2HScorePatterns(
    mostCommon: [],
    avgHomeGoals: 0,
    avgAwayGoals: 0,
    over25Rate: 0,
    bttsRate: 0,
  );

  final List<Map<String, dynamic>> mostCommon;
  final double avgHomeGoals;
  final double avgAwayGoals;
  final int over25Rate;
  final int bttsRate;
}

class H2HMatch {
  const H2HMatch({
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.venue,
    required this.result,
    required this.homeScore,
    required this.awayScore,
  });

  factory H2HMatch.fromJson(Map<String, dynamic> json) {
    return H2HMatch(
      date: json['date']?.toString() ?? '',
      homeTeam: json['homeTeam']?.toString() ?? json['home_team']?.toString() ?? '',
      awayTeam: json['awayTeam']?.toString() ?? json['away_team']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
      result: json['result']?.toString().toUpperCase() ?? '',
      homeScore: _parseInt(json['homeScore'] ?? json['home_score']) ?? 0,
      awayScore: _parseInt(json['awayScore'] ?? json['away_score']) ?? 0,
    );
  }

  final String date;
  final String homeTeam;
  final String awayTeam;
  final String venue;
  final String result;
  final int homeScore;
  final int awayScore;

  String get scoreDisplay => '$homeScore-$awayScore';
}

List<H2HMatch> _parseRecentMatches(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => H2HMatch.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<String> _parseStringList(Object? value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
}

Map<String, dynamic>? _readMap(
  Map<String, dynamic>? json,
  List<String> keys,
) {
  if (json == null) return null;
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String formatPremiumPercent(double value) {
  if (value <= 0) return '0%';
  if (value <= 1) return '${(value * 100).round()}%';
  return '${value.round()}%';
}

String formatPremiumNumber(num? value, {int fractionDigits = 1}) {
  if (value == null) return '-';
  if (value is int) return value.toString();
  return value.toStringAsFixed(fractionDigits);
}
