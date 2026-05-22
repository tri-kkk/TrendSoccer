import 'package:trendsoccer/features/analysis/widgets/baseball/premium/team_stat_gauge_card.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/confidence_chip.dart';

class BaseballAiWinProbability {
  const BaseballAiWinProbability({
    required this.homePercent,
    required this.awayPercent,
    this.prediction,
  });

  final double homePercent;
  final double awayPercent;
  final String? prediction;

  double get homeRatio => (homePercent / 100).clamp(0.0, 1.0);
  double get awayRatio => (awayPercent / 100).clamp(0.0, 1.0);

  String get homeDisplay => '${homePercent.round()}%';
  String get awayDisplay => '${awayPercent.round()}%';
}

class BaseballAiOverUnder {
  const BaseballAiOverUnder({
    this.line,
    this.prediction,
    this.analysis,
  });

  final double? line;
  final String? prediction;
  final String? analysis;

  bool get favorsUnder {
    final value = prediction?.toLowerCase().trim() ?? '';
    return value.contains('under') || value.contains('언더');
  }

  bool get favorsOver {
    final value = prediction?.toLowerCase().trim() ?? '';
    return value.contains('over') || value.contains('오버');
  }

  String get lineDisplay {
    if (line == null) return '-';
    if (line == line!.roundToDouble()) return line!.toStringAsFixed(0);
    return line!.toStringAsFixed(1);
  }
}

class BaseballTeamRecord {
  const BaseballTeamRecord({
    this.wins,
    this.losses,
    this.display,
  });

  final int? wins;
  final int? losses;
  final String? display;

  String get formatted {
    final preset = display?.trim();
    if (preset != null && preset.isNotEmpty) return preset;
    if (wins != null && losses != null) return '$wins승 $losses패';
    return '-';
  }
}

class BaseballAiAnalysisParsed {
  const BaseballAiAnalysisParsed({
    required this.homeTeam,
    required this.awayTeam,
    required this.winProbability,
    required this.overUnder,
    required this.homeLast10Record,
    required this.awayLast10Record,
    required this.homeLast10WinRate,
    required this.awayLast10WinRate,
    required this.confidence,
    required this.last10TeamProduction,
    required this.seasonTeamStats,
    this.aiSummary,
  });

  final String homeTeam;
  final String awayTeam;
  final BaseballAiWinProbability winProbability;
  final BaseballAiOverUnder overUnder;
  final BaseballTeamRecord homeLast10Record;
  final BaseballTeamRecord awayLast10Record;
  final double? homeLast10WinRate;
  final double? awayLast10WinRate;
  final ConfidenceLevel confidence;
  final List<GaugeData> last10TeamProduction;
  final List<GaugeData> seasonTeamStats;
  final String? aiSummary;

  String get homeLast10WinRateDisplay => _formatPercent(homeLast10WinRate);
  String get awayLast10WinRateDisplay => _formatPercent(awayLast10WinRate);

  String get winProbabilityDescription {
    final summary = aiSummary?.trim();
    if (summary != null && summary.isNotEmpty) return summary;
    final prediction = winProbability.prediction?.trim();
    if (prediction != null && prediction.isNotEmpty) return prediction;
    return 'AI 기반 승리 확률 분석입니다.';
  }
}

bool _loggedAiKeys = false;

BaseballAiAnalysisParsed parseBaseballAiAnalysis(Map<String, dynamic> raw) {
  if (!_loggedAiKeys) {
    _loggedAiKeys = true;
    print('[BASEBALL] AI analysis keys: ${raw.keys.toList()}');
  }

  final data = _unwrapAi(raw);
  if (data.isNotEmpty && data != raw) {
    print('[BASEBALL] AI analysis data keys: ${data.keys.toList()}');
  }

  final homeTeam = _readTeamName(data, isHome: true);
  final awayTeam = _readTeamName(data, isHome: false);

  return BaseballAiAnalysisParsed(
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    winProbability: _parseWinProbability(data),
    overUnder: _parseOverUnder(data),
    homeLast10Record: _parseTeamRecord(data, side: 'home', atHome: true),
    awayLast10Record: _parseTeamRecord(data, side: 'away', atHome: false),
    homeLast10WinRate: _parseLast10WinRate(data, side: 'home'),
    awayLast10WinRate: _parseLast10WinRate(data, side: 'away'),
    confidence: _parseConfidence(data),
    last10TeamProduction: _parseTeamProduction(data),
    seasonTeamStats: _parseSeasonTeamStats(data),
    aiSummary: _parseAiSummary(data),
  );
}

Map<String, dynamic> _unwrapAi(Map<String, dynamic> raw) {
  if (raw['success'] == true) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
  }
  return _readMap(raw, const ['data', 'analysis', 'result']) ?? raw;
}

String _readTeamName(Map<String, dynamic> data, {required bool isHome}) {
  final match = _readMap(data, const ['match', 'game', 'fixture']);
  final source = match ?? data;
  final keys = isHome
      ? const [
          'homeTeamKo',
          'home_team_ko',
          'homeTeam',
          'home_team',
          'homeTeamName',
          'home_team_name',
        ]
      : const [
          'awayTeamKo',
          'away_team_ko',
          'awayTeam',
          'away_team',
          'awayTeamName',
          'away_team_name',
        ];
  return _readString(source, keys) ?? (isHome ? '홈' : '원정');
}

BaseballAiWinProbability _parseWinProbability(Map<String, dynamic> data) {
  final root = _readMap(data, const [
        'winProbability',
        'win_probability',
        'winProb',
        'win_prob',
        'prediction',
        'matchPrediction',
        'match_prediction',
      ]) ??
      data;

  final home = _normalizePercent(
    _parseDouble(
      root['home'] ??
          root['homePercent'] ??
          root['home_percent'] ??
          root['homeProb'] ??
          root['home_prob'] ??
          root['homeWinProb'] ??
          root['home_win_prob'],
    ),
  );
  final away = _normalizePercent(
    _parseDouble(
      root['away'] ??
          root['awayPercent'] ??
          root['away_percent'] ??
          root['awayProb'] ??
          root['away_prob'] ??
          root['awayWinProb'] ??
          root['away_win_prob'],
    ),
  );

  var homePercent = home ?? 50;
  var awayPercent = away ?? 50;
  if (home == null && away != null) {
    homePercent = (100 - awayPercent).clamp(0, 100);
  } else if (away == null && home != null) {
    awayPercent = (100 - homePercent).clamp(0, 100);
  }

  return BaseballAiWinProbability(
    homePercent: homePercent,
    awayPercent: awayPercent,
    prediction: _readString(root, const [
      'prediction',
      'pick',
      'winner',
      'recommended',
      'recommendation',
    ]),
  );
}

BaseballAiOverUnder _parseOverUnder(Map<String, dynamic> data) {
  final root = _readMap(data, const [
        'overUnder',
        'over_under',
        'ou',
        'total',
        'totals',
      ]) ??
      data;

  return BaseballAiOverUnder(
    line: _parseDouble(
      root['line'] ??
          root['baseLine'] ??
          root['base_line'] ??
          root['overUnderLine'] ??
          root['over_under_line'] ??
          root['total'],
    ),
    prediction: _readString(root, const [
      'prediction',
      'pick',
      'recommendation',
      'recommended',
      'direction',
      'side',
    ]),
    analysis: _readString(root, const [
      'analysis',
      'summary',
      'text',
      'insight',
      'reasoning',
      'comment',
    ]),
  );
}

BaseballTeamRecord _parseTeamRecord(
  Map<String, dynamic> data, {
  required String side,
  required bool atHome,
}) {
  final root = _readMap(data, const [
        'last10HomeAwayRecord',
        'last10_home_away_record',
        'homeAwayRecord',
        'home_away_record',
        'last10Record',
        'last10_record',
        'recentRecord',
        'recent_record',
      ]) ??
      data;

  final sideRoot = side == 'home'
      ? _readMap(root, const [
          'home',
          'homeAtHome',
          'home_at_home',
          'homeRecord',
          'home_record',
        ])
      : _readMap(root, const [
          'away',
          'awayOnRoad',
          'away_on_road',
          'awayRecord',
          'away_record',
        ]);

  final map = sideRoot ?? root;
  final wins = _parseInt(
    map[atHome ? 'homeWins' : 'awayWins'] ??
        map['wins'] ??
        map['win'] ??
        map['W'],
  );
  final losses = _parseInt(
    map[atHome ? 'homeLosses' : 'awayLosses'] ??
        map['losses'] ??
        map['loss'] ??
        map['L'],
  );
  final display = _readString(map, const [
    'record',
    'display',
    'label',
    'text',
    'summary',
  ]);

  return BaseballTeamRecord(wins: wins, losses: losses, display: display);
}

double? _parseLast10WinRate(Map<String, dynamic> data, {required String side}) {
  final root = _readMap(data, const [
        'last10WinRate',
        'last10_win_rate',
        'recentWinRate',
        'recent_win_rate',
        'winRate',
        'win_rate',
      ]) ??
      data;

  final value = _parseDouble(
    side == 'home'
        ? root['home'] ??
            root['homePercent'] ??
            root['home_percent'] ??
            root['homeWinRate'] ??
            root['home_win_rate']
        : root['away'] ??
            root['awayPercent'] ??
            root['away_percent'] ??
            root['awayWinRate'] ??
            root['away_win_rate'],
  );
  return _normalizePercent(value);
}

ConfidenceLevel _parseConfidence(Map<String, dynamic> data) {
  final root = _readMap(data, const [
        'last10WinRate',
        'last10_win_rate',
        'confidence',
        'analysisConfidence',
        'analysis_confidence',
      ]) ??
      data;

  final raw = _readString(root, const [
    'confidence',
    'level',
    'confidenceLevel',
    'confidence_level',
  ]) ??
      _readString(data, const [
        'confidence',
        'confidenceLevel',
        'confidence_level',
      ]);

  final value = raw?.toLowerCase().trim() ?? '';
  if (value.contains('high') || value.contains('높')) {
    return ConfidenceLevel.high;
  }
  if (value.contains('low') || value.contains('낮')) {
    return ConfidenceLevel.low;
  }
  return ConfidenceLevel.medium;
}

List<GaugeData> _parseTeamProduction(Map<String, dynamic> data) {
  final root = _readMap(data, const [
        'last10TeamProduction',
        'last10_team_production',
        'teamProduction',
        'team_production',
        'production',
        'offense',
      ]) ??
      data;

  final list = _extractList(
    root['items'] ?? root['stats'] ?? root['metrics'] ?? root['production'],
  );
  if (list.isNotEmpty) {
    return list
        .whereType<Map>()
        .map((item) => _gaugeFromMap(Map<String, dynamic>.from(item)))
        .where((gauge) => gauge.label != '-')
        .toList();
  }

  return [
    _buildGauge(
      '득점',
      _sideValue(root, const ['runs', 'runsScored', 'runs_scored']),
    ),
    _buildGauge(
      '실점',
      _sideValue(root, const ['runsAllowed', 'runs_allowed', 'allowedRuns']),
    ),
    _buildGauge(
      '안타',
      _sideValue(root, const ['hits', 'totalHits', 'total_hits']),
    ),
  ].where((gauge) => gauge.homeValue != '-' || gauge.awayValue != '-').toList();
}

List<GaugeData> _parseSeasonTeamStats(Map<String, dynamic> data) {
  final root = _readMap(data, const [
        'seasonTeamStats',
        'season_team_stats',
        'seasonStats',
        'season_stats',
        'teamStats',
        'team_stats',
      ]) ??
      data;

  final list = _extractList(root['items'] ?? root['stats'] ?? root['metrics']);
  if (list.isNotEmpty) {
    final parsed = list
        .whereType<Map>()
        .map((item) => _gaugeFromMap(Map<String, dynamic>.from(item)))
        .where((gauge) => gauge.label != '-')
        .toList();
    if (parsed.length >= 4) return parsed.take(4).toList();
  }

  final batting = _readMap(root, const ['batting', 'offense']) ?? root;
  final pitching = _readMap(root, const ['pitching', 'defense']) ?? root;

  return [
    _buildGauge(
      '팀 타율',
      _sideValue(batting, const ['avg', 'battingAverage', 'batting_average']),
    ),
    _buildGauge(
      '팀 OPS',
      _sideValue(batting, const ['ops', 'OPS']),
    ),
    _buildGauge(
      '팀 방어율',
      _sideValue(pitching, const ['era', 'ERA']),
    ),
    _buildGauge(
      '팀 WHIP',
      _sideValue(pitching, const ['whip', 'WHIP']),
    ),
  ];
}

String? _parseAiSummary(Map<String, dynamic> data) {
  return _readString(data, const [
    'aiSummary',
    'ai_summary',
    'summary',
    'analysis',
    'overallAnalysis',
    'overall_analysis',
    'insight',
    'text',
    'content',
  ]);
}

GaugeData _gaugeFromMap(Map<String, dynamic> map) {
  return _buildGauge(
    _readString(map, const ['label', 'name', 'stat', 'metric']) ?? '-',
    map,
  );
}

Object? _sideValue(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) return null;
  final nested = _readMap(map, keys);
  if (nested != null) return nested;
  for (final key in keys) {
    final value = map[key];
    if (value != null) return value;
  }
  return null;
}

GaugeData _buildGauge(
  String label,
  Object? source, {
  Object? away,
}) {
  Object? homeValue;
  Object? awayValue;

  if (source is Map) {
    final map = Map<String, dynamic>.from(source);
    homeValue = map['home'] ?? map['homeValue'] ?? map['home_value'];
    awayValue = map['away'] ?? map['awayValue'] ?? map['away_value'];
  } else {
    homeValue = source;
    awayValue = away;
  }

  final homeNum = _parseDouble(homeValue) ?? 0;
  final awayNum = _parseDouble(awayValue) ?? 0;
  final total = homeNum + awayNum;
  final ratio = total > 0 ? (homeNum / total).clamp(0.0, 1.0) : 0.5;

  return GaugeData(
    label: label,
    homeValue: _formatValue(homeValue),
    awayValue: _formatValue(awayValue),
    homeRatio: ratio,
  );
}

double? _normalizePercent(double? value) {
  if (value == null) return null;
  if (value <= 1) return (value * 100).clamp(0, 100);
  return value.clamp(0, 100);
}

String _formatPercent(double? value) {
  if (value == null) return '-';
  return '${value.round()}%';
}

String _formatValue(Object? value) {
  if (value == null) return '-';
  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

List<dynamic> _extractList(Object? value) {
  if (value is List) return value;
  return const [];
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
    if (value is num) return value.toString();
  }
  return null;
}

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
