// Pure-data parse of `GET /api/h2h-analysis` for report block 08.

class SoccerH2HOverallParsed {
  const SoccerH2HOverallParsed({
    this.homeWins,
    this.draws,
    this.awayWins,
  });

  final int? homeWins;
  final int? draws;
  final int? awayWins;

  bool get hasData =>
      homeWins != null || draws != null || awayWins != null;

  double get homeFraction => _fraction(homeWins);

  double get drawFraction => _fraction(draws);

  double get awayFraction => _fraction(awayWins);

  double _fraction(int? value) {
    final home = homeWins ?? 0;
    final draw = draws ?? 0;
    final away = awayWins ?? 0;
    final total = home + draw + away;
    if (total <= 0) return 0;
    return ((value ?? 0) / total).clamp(0.0, 1.0);
  }
}

class SoccerH2HMatchParsed {
  const SoccerH2HMatchParsed({
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
  });

  final String date;
  final String homeTeam;
  final String awayTeam;
  final int? homeScore;
  final int? awayScore;

  String get scoreLabel {
    if (homeScore == null || awayScore == null) return '-';
    return '$homeScore-$awayScore';
  }
}

class SoccerH2HAnalysisParsed {
  const SoccerH2HAnalysisParsed({
    required this.overall,
    required this.recentMatches,
    required this.insights,
  });

  static const empty = SoccerH2HAnalysisParsed(
    overall: SoccerH2HOverallParsed(),
    recentMatches: [],
    insights: [],
  );

  final SoccerH2HOverallParsed overall;
  final List<SoccerH2HMatchParsed> recentMatches;
  final List<String> insights;

  bool get hasData => overall.hasData || recentMatches.isNotEmpty;
}

SoccerH2HAnalysisParsed parseSoccerH2HAnalysis(Map<String, dynamic> raw) {
  final data = _readMap(raw, const ['data']) ?? raw;
  final overallMap = _readMap(data, const ['overall']) ?? {};
  final matchesRaw = data['recentMatches'] ?? data['recent_matches'];
  final matches = <SoccerH2HMatchParsed>[];

  if (matchesRaw is List) {
    for (final item in matchesRaw) {
      if (item is! Map) continue;
      final map = item is Map<String, dynamic>
          ? item
          : Map<String, dynamic>.from(item);
      matches.add(
        SoccerH2HMatchParsed(
          date: map['date']?.toString() ?? '',
          homeTeam: map['homeTeam']?.toString() ??
              map['home_team']?.toString() ??
              '',
          awayTeam: map['awayTeam']?.toString() ??
              map['away_team']?.toString() ??
              '',
          homeScore: _parseInt(map['homeScore'] ?? map['home_score']),
          awayScore: _parseInt(map['awayScore'] ?? map['away_score']),
        ),
      );
    }
  }

  return SoccerH2HAnalysisParsed(
    overall: SoccerH2HOverallParsed(
      homeWins: _parseInt(overallMap['homeWins'] ?? overallMap['home_wins']),
      draws: _parseInt(overallMap['draws'] ?? overallMap['draw']),
      awayWins: _parseInt(overallMap['awayWins'] ?? overallMap['away_wins']),
    ),
    recentMatches: matches,
    insights: _parseStringList(data['insights']),
  );
}

List<String> _parseStringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
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
