// Pure-data parse of `/api/predict-v2` for match-report blocks 02–05.
// No BuildContext or localization — widgets format labels.

enum SoccerPickDirection { home, draw, away, unknown }

enum SoccerPredictGrade { pick, good, pass }

class SoccerFinalProbabilities {
  const SoccerFinalProbabilities({
    required this.home,
    required this.draw,
    required this.away,
  });

  final double home;
  final double draw;
  final double away;
}

class SoccerMethodProbabilities {
  const SoccerMethodProbabilities({
    this.win,
    this.draw,
    this.lose,
  });

  final double? win;
  final double? draw;
  final double? lose;

  double get winValue => win ?? 0;
  double get drawValue => draw ?? 0;
  double get loseValue => lose ?? 0;
  double get total => winValue + drawValue + loseValue;
}

enum SoccerTeamStatFormat { integerPercent, form, goalRatio }

class SoccerTeamStatRow {
  const SoccerTeamStatRow({
    required this.homeValue,
    required this.awayValue,
    required this.format,
  });

  final double? homeValue;
  final double? awayValue;
  final SoccerTeamStatFormat format;
}

class SoccerPredictV2Parsed {
  const SoccerPredictV2Parsed({
    required this.pickDirection,
    this.pickRaw,
    required this.grade,
    required this.finalProb,
    required this.reasons,
    required this.methods,
    required this.teamStats,
  });

  final SoccerPickDirection pickDirection;
  final String? pickRaw;
  final SoccerPredictGrade grade;
  final SoccerFinalProbabilities finalProb;
  final List<String> reasons;
  final List<SoccerMethodProbabilities> methods;
  final List<SoccerTeamStatRow> teamStats;
}

SoccerPredictV2Parsed parseSoccerPredictV2(Map<String, dynamic> raw) {
  final predictionRoot =
      _readMap(raw, const ['prediction']) ??
      _readMap(raw, const ['data']) ??
      raw;

  final recommendation =
      _readMap(predictionRoot, const ['recommendation']);
  final finalProb =
      _readMap(predictionRoot, const ['finalProb', 'final_prob']);
  final method1 = _readMap(predictionRoot, const ['method1', 'method_1']);
  final method2 = _readMap(predictionRoot, const ['method2', 'method_2']);
  final method3 = _readMap(predictionRoot, const ['method3', 'method_3']);
  final debug = _readMap(predictionRoot, const ['debug']);
  final homePA = _readMap(predictionRoot, const ['homePA', 'home_pa']);
  final awayPA = _readMap(predictionRoot, const ['awayPA', 'away_pa']);

  final pickRaw = _readString(recommendation, const ['pick', 'direction']);

  return SoccerPredictV2Parsed(
    pickDirection: _parsePickDirection(pickRaw),
    pickRaw: pickRaw,
    grade: _normalizeGrade(recommendation?['grade']),
    finalProb: SoccerFinalProbabilities(
      home: _parseProbability(finalProb?['home']),
      draw: _parseProbability(finalProb?['draw']),
      away: _parseProbability(finalProb?['away']),
    ),
    reasons: _parseReasons(recommendation?['reasons']),
    methods: [
      _parseMethodBreakdown(method1),
      _parseMethodBreakdown(method2),
      _parseMethodBreakdown(method3),
    ],
    teamStats: _parseTeamStatsFromDebug(
      debug: debug,
      homePA: homePA,
      awayPA: awayPA,
    ),
  );
}

List<SoccerTeamStatRow> _parseTeamStatsFromDebug({
  required Map<String, dynamic>? debug,
  required Map<String, dynamic>? homePA,
  required Map<String, dynamic>? awayPA,
}) {
  final homeStats = _readMap(debug, const ['homeStats', 'home_stats']);
  final awayStats = _readMap(debug, const ['awayStats', 'away_stats']);

  return [
    SoccerTeamStatRow(
      homeValue: _parseDouble(homeStats?['homeFirstGoalWinRate']),
      awayValue: _parseDouble(awayStats?['awayFirstGoalWinRate']),
      format: SoccerTeamStatFormat.integerPercent,
    ),
    SoccerTeamStatRow(
      homeValue: _parseDouble(homeStats?['homeComebackRate']),
      awayValue: _parseDouble(awayStats?['awayComebackRate']),
      format: SoccerTeamStatFormat.integerPercent,
    ),
    SoccerTeamStatRow(
      homeValue: _parseDouble(homeStats?['form']),
      awayValue: _parseDouble(awayStats?['form']),
      format: SoccerTeamStatFormat.form,
    ),
    SoccerTeamStatRow(
      homeValue: _parsePaAllValue(homePA),
      awayValue: _parsePaAllValue(awayPA),
      format: SoccerTeamStatFormat.goalRatio,
    ),
  ];
}

double? _parsePaAllValue(Map<String, dynamic>? paMap) {
  if (paMap == null) return null;
  return _parseDouble(paMap['all']);
}

List<String> _parseReasons(Object? reasonsRaw) {
  if (reasonsRaw is! List || reasonsRaw.isEmpty) {
    return const [];
  }

  final items = <String>[];
  for (final reason in reasonsRaw) {
    if (items.length >= 5) break;
    if (reason is! String) continue;

    final trimmed = reason.trim();
    if (trimmed.isEmpty) continue;
    if (_shouldSkipReason(trimmed)) continue;

    items.add(trimmed);
  }

  return items;
}

bool _shouldSkipReason(String reason) {
  return reason.toLowerCase().startsWith('data:');
}

SoccerMethodProbabilities _parseMethodBreakdown(Map<String, dynamic>? method) {
  return SoccerMethodProbabilities(
    win: _parseMethodProbability(method?['win']),
    draw: _parseMethodProbability(method?['draw']),
    lose: _parseMethodProbability(method?['lose'] ?? method?['loss']),
  );
}

SoccerPickDirection _parsePickDirection(String? pick) {
  if (pick == null || pick.trim().isEmpty) return SoccerPickDirection.unknown;
  final normalized = pick.trim().toUpperCase();
  if (normalized.contains('HOME') || normalized == 'H' || normalized == '1') {
    return SoccerPickDirection.home;
  }
  if (normalized.contains('DRAW') ||
      normalized.contains('TIE') ||
      normalized == 'X' ||
      normalized == 'D') {
    return SoccerPickDirection.draw;
  }
  if (normalized.contains('AWAY') || normalized == 'A' || normalized == '2') {
    return SoccerPickDirection.away;
  }
  return SoccerPickDirection.unknown;
}

SoccerPredictGrade _normalizeGrade(Object? value) {
  if (value == null) return SoccerPredictGrade.pass;
  final raw = value.toString().toLowerCase();
  if (raw.contains('pick') || raw == 'a') return SoccerPredictGrade.pick;
  if (raw.contains('good') || raw == 'b') return SoccerPredictGrade.good;
  return SoccerPredictGrade.pass;
}

double _parseProbability(Object? value) {
  final d = _parseDouble(value);
  if (d == null) return 0;
  return d > 1 ? d / 100 : d;
}

double? _parseMethodProbability(Object? value) {
  final parsed = _parseDouble(value);
  if (parsed == null) return null;
  return parsed <= 1 ? parsed : parsed / 100;
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
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
