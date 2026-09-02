// Pure-data parse of `/api/baseball/predict` (+ optional match detail) for
// match-report blocks 02, 05, 06, 07, 09. No BuildContext or localization.

enum BaseballPickDirection { home, away, unknown }

class BaseballWinProbabilities {
  const BaseballWinProbabilities({
    this.home,
    this.away,
  });

  final double? home;
  final double? away;
}

class BaseballTeamProductionSide {
  const BaseballTeamProductionSide({
    this.scored,
    this.conceded,
    this.hits,
  });

  final double? scored;
  final double? conceded;
  final double? hits;
}

class BaseballTeamProduction {
  const BaseballTeamProduction({
    required this.home,
    required this.away,
  });

  final BaseballTeamProductionSide home;
  final BaseballTeamProductionSide away;
}

class BaseballSeasonTeamStatsSide {
  const BaseballSeasonTeamStatsSide({
    this.avg,
    this.ops,
    this.era,
    this.whip,
  });

  final double? avg;
  final double? ops;
  final double? era;
  final double? whip;
}

class BaseballSeasonTeamStats {
  const BaseballSeasonTeamStats({
    this.home,
    this.away,
  });

  final BaseballSeasonTeamStatsSide? home;
  final BaseballSeasonTeamStatsSide? away;
}

class BaseballPredictV2Parsed {
  const BaseballPredictV2Parsed({
    required this.pickDirection,
    this.pickRaw,
    this.grade,
    required this.winProb,
    required this.teamProduction,
    required this.seasonTeamStats,
    this.homeAdvantageRecord,
    this.awayAdvantageRecord,
    this.homeRecentWinRate,
    this.awayRecentWinRate,
    this.confidence,
    this.overUnderLine,
    this.overProb,
    this.underProb,
    this.highlightUnder,
    this.homeTeam,
    this.awayTeam,
    this.homeTeamKo,
    this.awayTeamKo,
    this.league,
  });

  final BaseballPickDirection pickDirection;
  final String? pickRaw;
  final String? grade;
  final BaseballWinProbabilities winProb;
  final BaseballTeamProduction teamProduction;
  final BaseballSeasonTeamStats seasonTeamStats;
  final String? homeAdvantageRecord;
  final String? awayAdvantageRecord;
  final String? homeRecentWinRate;
  final String? awayRecentWinRate;
  final String? confidence;
  final String? overUnderLine;
  final double? overProb;
  final double? underProb;
  final bool? highlightUnder;
  final String? homeTeam;
  final String? awayTeam;
  final String? homeTeamKo;
  final String? awayTeamKo;
  final String? league;
}

/// Parses baseball predict payload for v2 match-report blocks.
///
/// [predict] is the POST `/api/baseball/predict` response.
/// [matchDetail] is the GET `/api/baseball/matches?id=` response (or equivalent
/// wrapped map). It supplies team names, [aiPrediction] win probabilities,
/// [odds.overUnderLine], and [aiPick] when absent from [predict].
BaseballPredictV2Parsed parseBaseballPredictV2(
  Map<String, dynamic> predict, {
  Map<String, dynamic>? matchDetail,
}) {
  final match = matchDetail != null ? _unwrapMatch(matchDetail) : null;
  final homeSide = _readMap(match, const ['home']) ?? const {};
  final awaySide = _readMap(match, const ['away']) ?? const {};

  final homeTeamEn =
      _readString(homeSide, const ['team', 'name']) ??
      _readString(match, const ['homeTeam', 'home_team']);
  final awayTeamEn =
      _readString(awaySide, const ['team', 'name']) ??
      _readString(match, const ['awayTeam', 'away_team']);
  final homeTeamKo =
      _readString(homeSide, const ['teamKo', 'team_ko']) ??
      _readString(match, const ['homeTeamKo', 'home_team_ko']);
  final awayTeamKo =
      _readString(awaySide, const ['teamKo', 'team_ko']) ??
      _readString(match, const ['awayTeamKo', 'away_team_ko']);

  final league = _readString(match, const [
    'league',
    'leagueName',
    'league_name',
  ]);

  final oddsMap = match != null ? _mergeOddsMap(match) : const {};
  final aiPred = _readMap(match, const ['aiPrediction', 'ai_prediction']);
  final prediction = _readMap(predict, const ['prediction']) ?? const {};
  final insights = _readMap(predict, const ['insights']) ?? const {};

  final homeWinProb = _parseProbability(
    aiPred?['homeWinProb'] ?? oddsMap['homeWinProb'],
  );
  final awayWinProb = _parseProbability(
    aiPred?['awayWinProb'] ?? oddsMap['awayWinProb'],
  );

  final pickRaw = _readRawString(
    match?['aiPick'] ?? aiPred?['pick'] ?? prediction['pick'],
  );
  final gradeRaw = _readRawString(
    match?['aiPick'] ?? aiPred?['grade'] ?? prediction['grade'],
  );

  final teamForm =
      _readMap(insights, const ['teamForm', 'team_form']) ?? const {};
  final homeForm = _readMap(teamForm, const ['home']) ?? const {};
  final awayForm = _readMap(teamForm, const ['away']) ?? const {};

  final teamProduction = BaseballTeamProduction(
    home: BaseballTeamProductionSide(
      scored: _parseDouble(homeForm['scored']),
      conceded: _parseDouble(homeForm['conceded']),
      hits: _parseDouble(homeForm['hits']),
    ),
    away: BaseballTeamProductionSide(
      scored: _parseDouble(awayForm['scored']),
      conceded: _parseDouble(awayForm['conceded']),
      hits: _parseDouble(awayForm['hits']),
    ),
  );

  final teamSeason = _readMap(insights, const ['teamSeason', 'team_season']);
  final homeSeason =
      teamSeason != null ? _readMap(teamSeason, const ['home']) : null;
  final awaySeason =
      teamSeason != null ? _readMap(teamSeason, const ['away']) : null;

  final seasonTeamStats = BaseballSeasonTeamStats(
    home: homeSeason == null
        ? null
        : BaseballSeasonTeamStatsSide(
            avg: _parseDouble(homeSeason['avg']),
            ops: _parseDouble(homeSeason['ops']),
            era: _parseDouble(homeSeason['era']),
            whip: _parseDouble(homeSeason['whip']),
          ),
    away: awaySeason == null
        ? null
        : BaseballSeasonTeamStatsSide(
            avg: _parseDouble(awaySeason['avg']),
            ops: _parseDouble(awaySeason['ops']),
            era: _parseDouble(awaySeason['era']),
            whip: _parseDouble(awaySeason['whip']),
          ),
  );

  final recentForm =
      _readMap(insights, const ['recentForm', 'recent_form']) ?? const {};
  final homeAdvantage =
      _readMap(insights, const ['homeAdvantage', 'home_advantage']) ?? const {};

  final homeAdvantageRecord = _readRawString(
    homeAdvantage['homeRecord'] ?? homeAdvantage['home_record'],
  );
  final awayAdvantageRecord = _readRawString(
    homeAdvantage['awayRecord'] ?? homeAdvantage['away_record'],
  );
  final homeRecentWinRate = _readRawString(recentForm['home']);
  final awayRecentWinRate = _readRawString(recentForm['away']);

  final confidence = _readString(prediction, const ['confidence']) ??
      _readString(match, const ['aiPickConfidence', 'ai_pick_confidence']);

  final overUnderLine = _readRawString(
    oddsMap['overUnderLine'] ??
        oddsMap['over_under_line'] ??
        oddsMap['ouLine'],
  );

  final overProb = _parseProbability(prediction['overProb']);
  final underProb = _parseProbability(prediction['underProb']);
  final highlightUnder = overProb != null &&
      underProb != null &&
      overProb > 0 &&
      underProb > 0 &&
      underProb > overProb;

  return BaseballPredictV2Parsed(
    pickDirection: _parsePickDirection(pickRaw),
    pickRaw: pickRaw,
    grade: gradeRaw,
    winProb: BaseballWinProbabilities(
      home: homeWinProb,
      away: awayWinProb,
    ),
    teamProduction: teamProduction,
    seasonTeamStats: seasonTeamStats,
    homeAdvantageRecord: homeAdvantageRecord,
    awayAdvantageRecord: awayAdvantageRecord,
    homeRecentWinRate: homeRecentWinRate,
    awayRecentWinRate: awayRecentWinRate,
    confidence: confidence,
    overUnderLine: overUnderLine,
    overProb: overProb,
    underProb: underProb,
    highlightUnder: highlightUnder,
    homeTeam: homeTeamEn,
    awayTeam: awayTeamEn,
    homeTeamKo: homeTeamKo,
    awayTeamKo: awayTeamKo,
    league: league,
  );
}

BaseballPickDirection _parsePickDirection(String? pick) {
  if (pick == null || pick.trim().isEmpty) return BaseballPickDirection.unknown;
  final normalized = pick.trim().toUpperCase();
  if (normalized.contains('HOME') || normalized == 'H' || normalized == '1') {
    return BaseballPickDirection.home;
  }
  if (normalized.contains('AWAY') || normalized == 'A' || normalized == '2') {
    return BaseballPickDirection.away;
  }
  return BaseballPickDirection.unknown;
}

double? _parseProbability(Object? value) {
  if (value == null) return null;
  final parsed = _parseDouble(value);
  if (parsed == null) return null;
  if (parsed > 1) return parsed / 100;
  return parsed;
}

Map<String, dynamic> _unwrapMatch(Map<String, dynamic> detail) {
  final match = detail['match'];
  if (match is Map<String, dynamic>) return match;
  if (match is Map) return Map<String, dynamic>.from(match);

  if (detail['matches'] is List && (detail['matches'] as List).isNotEmpty) {
    final first = (detail['matches'] as List).first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return Map<String, dynamic>.from(first);
  }

  return detail;
}

Map<String, dynamic> _mergeOddsMap(Map<String, dynamic> match) {
  final odds = match['odds'];
  if (odds is Map<String, dynamic>) return odds;
  if (odds is Map) return Map<String, dynamic>.from(odds);
  return match;
}

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll('%', '').trim());
  return null;
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

String? _readRawString(Object? value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num) return value.toString();
  return null;
}
