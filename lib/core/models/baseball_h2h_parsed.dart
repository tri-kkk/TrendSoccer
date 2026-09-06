// Pure-data parse of `GET /api/baseball/h2h` for report block 08.

enum BaseballH2HWinner { home, away, draw }

class BaseballH2HOverallParsed {
  const BaseballH2HOverallParsed({
    this.homeWins,
    this.draws,
    this.awayWins,
  });

  final int? homeWins;
  final int? draws;
  final int? awayWins;

  bool get hasData =>
      homeWins != null || draws != null || awayWins != null;
}

class BaseballH2HMatchParsed {
  const BaseballH2HMatchParsed({
    this.date,
    this.homeTeam,
    this.awayTeam,
    this.homeTeamKo,
    this.awayTeamKo,
    this.homeScore,
    this.awayScore,
    this.score,
    this.winner,
  });

  final String? date;
  final String? homeTeam;
  final String? awayTeam;
  final String? homeTeamKo;
  final String? awayTeamKo;
  final int? homeScore;
  final int? awayScore;
  final String? score;
  final BaseballH2HWinner? winner;
}

class BaseballH2HAnalysisParsed {
  const BaseballH2HAnalysisParsed({
    required this.overall,
    required this.recentMatches,
  });

  static const empty = BaseballH2HAnalysisParsed(
    overall: BaseballH2HOverallParsed(),
    recentMatches: [],
  );

  final BaseballH2HOverallParsed overall;
  final List<BaseballH2HMatchParsed> recentMatches;

  bool get hasData => overall.hasData || recentMatches.isNotEmpty;
}

/// Parses `GET /api/baseball/h2h` for v2 report block 08.
BaseballH2HAnalysisParsed parseBaseballH2H(Map<String, dynamic> raw) {
  final overallMap = _readMap(raw, const ['overall']) ?? const {};
  final matches = _parseRecentMatches(raw);

  return BaseballH2HAnalysisParsed(
    overall: BaseballH2HOverallParsed(
      homeWins: _parseInt(
        overallMap['homeWins'] ??
            overallMap['home_wins'] ??
            raw['homeWins'] ??
            raw['home_wins'],
      ),
      draws: _parseInt(
        overallMap['draws'] ??
            overallMap['draw'] ??
            raw['draws'] ??
            raw['draw'],
      ),
      awayWins: _parseInt(
        overallMap['awayWins'] ??
            overallMap['away_wins'] ??
            raw['awayWins'] ??
            raw['away_wins'],
      ),
    ),
    recentMatches: matches,
  );
}

List<BaseballH2HMatchParsed> _parseRecentMatches(Map<String, dynamic> raw) {
  final rawMatches = raw['matches'] as List? ??
      raw['data'] as List? ??
      raw['items'] as List?;
  if (rawMatches == null || rawMatches.isEmpty) {
    return const [];
  }

  final matches = <BaseballH2HMatchParsed>[];
  for (final item in rawMatches) {
    if (item is! Map) continue;
    final map = item is Map<String, dynamic>
        ? item
        : Map<String, dynamic>.from(item);
    matches.add(_parseMatch(map));
    if (matches.length >= 5) break;
  }
  return matches;
}

BaseballH2HMatchParsed _parseMatch(Map<String, dynamic> map) {
  final homeScore = _parseInt(map['homeScore'] ?? map['home_score']);
  final awayScore = _parseInt(map['awayScore'] ?? map['away_score']);

  return BaseballH2HMatchParsed(
    date: _readString(map, const ['date', 'matchDate', 'match_date']),
    homeTeam: _extractTeamEn(map, isHome: true),
    awayTeam: _extractTeamEn(map, isHome: false),
    homeTeamKo: _extractTeamKo(map, isHome: true),
    awayTeamKo: _extractTeamKo(map, isHome: false),
    homeScore: homeScore,
    awayScore: awayScore,
    score: _readString(map, const ['score', 'result']),
    winner: _parseWinner(
      map,
      homeScore: homeScore,
      awayScore: awayScore,
    ),
  );
}

BaseballH2HWinner? _parseWinner(
  Map<String, dynamic> map, {
  required int? homeScore,
  required int? awayScore,
}) {
  final winnerRaw =
      _readString(map, const ['winner', 'winnerSide', 'winner_side'])
          ?.toLowerCase()
          .trim();
  if (winnerRaw == 'home' || winnerRaw == 'h') {
    return BaseballH2HWinner.home;
  }
  if (winnerRaw == 'away' || winnerRaw == 'a') {
    return BaseballH2HWinner.away;
  }
  if (winnerRaw == 'draw' || winnerRaw == 'd') {
    return BaseballH2HWinner.draw;
  }

  if (homeScore != null && awayScore != null) {
    if (homeScore > awayScore) return BaseballH2HWinner.home;
    if (awayScore > homeScore) return BaseballH2HWinner.away;
    if (homeScore == awayScore) return BaseballH2HWinner.draw;
  }

  return null;
}

String? _extractTeamKo(Map<String, dynamic> map, {required bool isHome}) {
  final prefix = isHome ? 'home' : 'away';
  final flatKo = map['${prefix}TeamKo'] ?? map['${prefix}_team_ko'];
  if (flatKo is String) {
    final trimmed = flatKo.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }

  final side = map[prefix];
  if (side is Map) {
    final nested = side['teamKo'] ?? side['team_ko'];
    if (nested is String) {
      final trimmed = nested.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }

  return null;
}

String? _extractTeamEn(Map<String, dynamic> map, {required bool isHome}) {
  final prefix = isHome ? 'home' : 'away';
  final flatEn = map['${prefix}Team'] ?? map['${prefix}_team'];
  if (flatEn is String) {
    final trimmed = flatEn.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }

  final side = map[prefix];
  if (side is Map) {
    final nested = side['team'] ?? side['name'];
    if (nested is String) {
      final trimmed = nested.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }

  return null;
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value.trim());
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

String? _readString(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;
  for (final key in keys) {
    final value = json[key];
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }
  return null;
}
