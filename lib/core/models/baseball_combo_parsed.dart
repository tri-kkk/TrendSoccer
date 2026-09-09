// Pure-data parse of `GET /api/baseball/combo-picks` for reports Multi-Match.
// No BuildContext, localization, or display defaults.

class BaseballComboLegParsed {
  const BaseballComboLegParsed({
    this.pickSide,
    this.pickTeam,
    this.pickTeamKo,
    this.isCorrect,
    this.matchStatus,
    this.homeScore,
    this.awayScore,
    this.homeTeam,
    this.awayTeam,
    this.homeTeamKo,
    this.awayTeamKo,
    this.homeLogo,
    this.awayLogo,
    this.odds,
    this.winProb,
    this.reason,
  });

  final String? pickSide;
  final String? pickTeam;
  final String? pickTeamKo;
  final bool? isCorrect;
  final String? matchStatus;
  final int? homeScore;
  final int? awayScore;
  final String? homeTeam;
  final String? awayTeam;
  final String? homeTeamKo;
  final String? awayTeamKo;
  final String? homeLogo;
  final String? awayLogo;
  final double? odds;
  final double? winProb;
  final String? reason;
}

class BaseballComboParsed {
  const BaseballComboParsed({
    this.id,
    this.pickDate,
    this.league,
    this.result,
    this.foldCount,
    this.totalOdds,
    this.avgConfidence,
    this.aiAnalysis,
    required this.legs,
  });

  final int? id;
  final String? pickDate;
  final String? league;
  final String? result;
  final int? foldCount;
  final double? totalOdds;
  final double? avgConfidence;
  final String? aiAnalysis;
  final List<BaseballComboLegParsed> legs;
}

/// Parses the full `/api/baseball/combo-picks` payload (e.g. `days=30`).
///
/// Does not filter by [pickDate] — the screen selects a day client-side.
List<BaseballComboParsed> parseBaseballComboPicks(Map<String, dynamic> response) {
  final picks = _extractComboMaps(response);
  return picks.map(_parseCombo).toList(growable: false);
}

BaseballComboParsed _parseCombo(Map<String, dynamic> pick) {
  final innerPicks = pick['picks'];
  final legs = innerPicks is List
      ? innerPicks
          .whereType<Map>()
          .map(
            (leg) => _parseLeg(
              leg is Map<String, dynamic> ? leg : Map<String, dynamic>.from(leg),
            ),
          )
          .toList(growable: false)
      : const <BaseballComboLegParsed>[];

  return BaseballComboParsed(
    id: _parseInt(pick['id']),
    pickDate: _readRawString(pick['pick_date'] ?? pick['pickDate']),
    league: _readRawString(pick['league']),
    result: _readRawString(pick['result'] ?? pick['status']),
    foldCount: _parseInt(pick['fold_count'] ?? pick['foldCount']),
    totalOdds: _parseDouble(pick['total_odds'] ?? pick['totalOdd']),
    avgConfidence: _parseDouble(
      pick['avg_confidence'] ?? pick['avgConfidence'],
    ),
    aiAnalysis: _readString(pick, const ['ai_analysis', 'aiAnalysis']),
    legs: legs,
  );
}

BaseballComboLegParsed _parseLeg(Map<String, dynamic> leg) {
  return BaseballComboLegParsed(
    pickSide: _readRawString(leg['pick']),
    pickTeam: _readString(leg, const ['pickTeam', 'pick_team']),
    pickTeamKo: _readString(leg, const ['pickTeamKo', 'pick_team_ko']),
    isCorrect: leg['isCorrect'] is bool
        ? leg['isCorrect'] as bool
        : leg['is_correct'] is bool
            ? leg['is_correct'] as bool
            : null,
    matchStatus: _readRawString(
      leg['matchStatus'] ?? leg['match_status'],
    ),
    homeScore: _parseInt(leg['homeScore'] ?? leg['home_score']),
    awayScore: _parseInt(leg['awayScore'] ?? leg['away_score']),
    homeTeam: _readString(leg, const ['homeTeam', 'home_team']),
    awayTeam: _readString(leg, const ['awayTeam', 'away_team']),
    homeTeamKo: _readString(leg, const ['homeTeamKo', 'home_team_ko']),
    awayTeamKo: _readString(leg, const ['awayTeamKo', 'away_team_ko']),
    homeLogo: _readString(leg, const ['homeLogo', 'home_logo']),
    awayLogo: _readString(leg, const ['awayLogo', 'away_logo']),
    odds: _parseDouble(leg['odds']),
    winProb: _parseDouble(leg['winProb'] ?? leg['win_prob']),
    reason: _readString(leg, const ['reason', 'reason_ko']),
  );
}

List<Map<String, dynamic>> _extractComboMaps(Map<String, dynamic> response) {
  for (final key in const [
    'picks',
    'combos',
    'comboPicks',
    'combo_picks',
    'items',
  ]) {
    final value = response[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
  }

  final data = response['data'];
  if (data is Map) {
    final nested = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data);
    for (final key in const ['picks', 'combos', 'items']) {
      final value = nested[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
    }
  }

  return const [];
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll('%', '').trim());
  return null;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
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
