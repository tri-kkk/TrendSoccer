import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/features/analysis/models/soccer_match_report_data.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/team_statistics_section.dart';

/// Parsed Standard-tab fields from `/api/analysis` (defensive mapping).
class SoccerStandardAnalysisParsed {
  const SoccerStandardAnalysisParsed({
    required this.leagueId,
    required this.matchDateDisplay,
    required this.homeTeam,
    required this.awayTeam,
    this.homeLogoUrl,
    this.awayLogoUrl,
    this.matchTimestampUtc,
    required this.prediction,
    required this.winProbability,
    required this.powerDiff,
    required this.analyzedMatches,
    required this.patternStats,
    required this.gradeBadge,
    required this.reasoningItems,
    required this.homeOdds,
    required this.drawOdds,
    required this.awayOdds,
    required this.homePowerRatio,
    required this.homeProb,
    required this.drawProb,
    required this.awayProb,
    required this.teamStats,
    required this.paHomeRatio,
    required this.minMaxHomeRatio,
    required this.firstGoalHomeRatio,
  });

  final String leagueId;
  final String matchDateDisplay;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final DateTime? matchTimestampUtc;

  final String prediction;
  final String winProbability;
  final String powerDiff;
  final String analyzedMatches;
  final String patternStats;
  final String gradeBadge;

  final List<String> reasoningItems;

  final String homeOdds;
  final String drawOdds;
  final String awayOdds;

  final double homePowerRatio;
  final double homeProb;
  final double drawProb;
  final double awayProb;

  final List<TeamStatItem> teamStats;

  final double paHomeRatio;
  final double minMaxHomeRatio;
  final double firstGoalHomeRatio;
}

SoccerStandardAnalysisParsed parseSoccerStandardAnalysis(
  Map<String, dynamic> raw, {
  DateTime? fallbackMatchTimestamp,
}) {
  final match = _readMap(raw, const ['match', 'fixture', 'game']) ?? raw;
  final odds = _readMap(raw, const ['odds', 'matchOdds', 'match_odds']);
  final prediction = _readMap(raw, const [
    'prediction',
    'analysis',
    'result',
    'analysisResult',
    'analysis_result',
  ]);
  final reasoning = _readMap(raw, const ['reasoning', 'reasons', 'insights']);
  final power = _readMap(raw, const [
    'powerIndex',
    'power_index',
    'power',
  ]);
  final probability = _readMap(raw, const [
    'finalProbability',
    'final_probability',
    'probabilities',
    'probability',
  ]);
  final teamStatsRoot = _readMap(raw, const [
    'teamStats',
    'team_stats',
    'teamStatistics',
    'team_statistics',
    'statistics',
  ]);
  final threeMethod = _readMap(raw, const [
    'threeMethod',
    'three_method',
    'threeMethodAnalysis',
    'three_method_analysis',
    'methods',
  ]);

  final homeTeamMap = _readMap(match, const ['homeTeam', 'home_team', 'home']);
  final awayTeamMap = _readMap(match, const ['awayTeam', 'away_team', 'away']);
  final leagueMap = _readMap(match, const ['league', 'leagueInfo', 'league_info']);

  final homeName = _readString(homeTeamMap, const ['name']) ??
      _readString(match, const ['homeTeamName', 'home_team_name', 'home']) ??
      '';
  final awayName = _readString(awayTeamMap, const ['name']) ??
      _readString(match, const ['awayTeamName', 'away_team_name', 'away']) ??
      '';

  final matchTimestamp = _parseMatchTimestamp(match) ?? fallbackMatchTimestamp;

  return SoccerStandardAnalysisParsed(
    leagueId: leagueMap == null
        ? 'league_0'
        : leagueIdForCard(
            LeagueInfo.fromJson(leagueMap),
          ),
    matchDateDisplay: _formatMatchDateDisplay(match),
    homeTeam: homeName.isEmpty ? '홈' : homeName,
    awayTeam: awayName.isEmpty ? '원정' : awayName,
    homeLogoUrl: _readString(homeTeamMap, const ['logo', 'logoUrl', 'logo_url']),
    awayLogoUrl: _readString(awayTeamMap, const ['logo', 'logoUrl', 'logo_url']),
    matchTimestampUtc: matchTimestamp?.toUtc(),
    prediction: _readString(prediction, const [
          'direction',
          'prediction',
          'pick',
          'result',
        ]) ??
        _readString(raw, const ['prediction', 'pick']) ??
        '-',
    winProbability: _formatPercent(
      prediction?['winRate'] ??
          prediction?['win_rate'] ??
          prediction?['confidence'] ??
          prediction?['winProbability'] ??
          prediction?['win_probability'],
    ),
    powerDiff: _formatPowerDiff(
      prediction?['powerDiff'] ??
          prediction?['power_diff'] ??
          power?['difference'] ??
          power?['diff'],
    ),
    analyzedMatches: _formatCount(
      prediction?['analyzedMatches'] ??
          prediction?['analyzed_matches'] ??
          prediction?['sampleSize'] ??
          prediction?['sample_size'],
    ),
    patternStats: _readString(prediction, const [
          'patternStats',
          'pattern_stats',
          'pattern',
        ]) ??
        '-',
    gradeBadge: _normalizeGrade(
      prediction?['grade'] ??
          prediction?['pickGrade'] ??
          prediction?['pick_grade'] ??
          raw['grade'],
    ),
    reasoningItems: _parseReasoningItems(reasoning, raw),
    homeOdds: _formatOdds(
      odds?['home'] ?? odds?['homeOdds'] ?? odds?['home_odds'],
    ),
    drawOdds: _formatOdds(
      odds?['draw'] ?? odds?['drawOdds'] ?? odds?['draw_odds'],
    ),
    awayOdds: _formatOdds(
      odds?['away'] ?? odds?['awayOdds'] ?? odds?['away_odds'],
    ),
    homePowerRatio: _parseRatio(
      power?['home'] ??
          power?['homeRatio'] ??
          power?['home_ratio'] ??
          power?['homePower'],
    ),
    homeProb: _parseProbability(probability?['home'] ?? probability?['homeProb']),
    drawProb: _parseProbability(probability?['draw'] ?? probability?['drawProb']),
    awayProb: _parseProbability(probability?['away'] ?? probability?['awayProb']),
    teamStats: _parseTeamStats(teamStatsRoot),
    paHomeRatio: _parseRatio(
      _readNested(threeMethod, const ['pa', 'home']) ??
          threeMethod?['paHome'] ??
          threeMethod?['pa_home'] ??
          _readNested(threeMethod, const ['probabilityAdvantage', 'home']),
      fallback: 0.5,
    ),
    minMaxHomeRatio: _parseRatio(
      _readNested(threeMethod, const ['minMax', 'home']) ??
          _readNested(threeMethod, const ['min_max', 'home']) ??
          threeMethod?['minMaxHome'] ??
          threeMethod?['min_max_home'],
      fallback: 0.5,
    ),
    firstGoalHomeRatio: _parseRatio(
      _readNested(threeMethod, const ['firstGoal', 'home']) ??
          _readNested(threeMethod, const ['first_goal', 'home']) ??
          threeMethod?['firstGoalHome'] ??
          threeMethod?['first_goal_home'],
      fallback: 0.5,
    ),
  );
}

Object? _readNested(Map<String, dynamic>? json, List<String> path) {
  Object? current = json;
  for (final key in path) {
    if (current is! Map) return null;
    current = current[key];
  }
  return current;
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

DateTime? _parseMatchTimestamp(Map<String, dynamic> match) {
  final direct = match['matchTimestamp'] ??
      match['match_timestamp'] ??
      match['kickoff'] ??
      match['kickoffTime'] ??
      match['kickoff_time'] ??
      match['timestamp'];
  final parsed = _parseDateTime(direct);
  if (parsed != null) return parsed.toUtc();

  final date = _readString(match, const ['matchDate', 'match_date', 'date']);
  final time = _readString(match, const [
    'matchTime',
    'match_time',
    'time',
    'kickoffTime',
    'kickoff_time',
  ]);
  if (date != null && time != null) {
    final combined = DateTime.tryParse('$date $time') ??
        DateTime.tryParse('${date}T$time');
    return combined?.toUtc();
  }
  if (date != null) {
    return DateTime.tryParse(date)?.toUtc();
  }
  return null;
}

DateTime? _parseDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  if (value is int) {
    final seconds = value > 9999999999 ? value ~/ 1000 : value;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }
  return null;
}

String _formatMatchDateDisplay(Map<String, dynamic> match) {
  final date = _readString(match, const ['matchDate', 'match_date', 'date']);
  final time = _readString(match, const ['matchTime', 'match_time', 'time']);
  if (date != null && time != null) return '$date $time';
  if (date != null) return date;
  final ts = _parseMatchTimestamp(match);
  if (ts != null) {
    final local = ts.toUtc();
    return '${local.month}월 ${local.day}일 ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
  return '-';
}

List<String> _parseReasoningItems(
  Map<String, dynamic>? reasoning,
  Map<String, dynamic> raw,
) {
  final items = <String>[];
  final list = reasoning?['items'] ??
      reasoning?['points'] ??
      reasoning?['bullets'] ??
      raw['reasoningItems'] ??
      raw['reasoning_items'] ??
      raw['reasoning'];
  if (list is List) {
    for (final item in list) {
      if (item is String && item.isNotEmpty) {
        items.add(item);
      } else if (item is Map) {
        final text = item['text'] ?? item['message'] ?? item['reason'];
        if (text is String && text.isNotEmpty) items.add(text);
      }
    }
  }
  if (items.isEmpty) {
    for (final key in const [
      'probabilityAdvantage',
      'probability_advantage',
      'firstGoal',
      'first_goal',
      'patterns',
    ]) {
      final value = reasoning?[key] ?? raw[key];
      if (value is String && value.isNotEmpty) items.add(value);
    }
  }
  return items.isEmpty ? const ['분석 근거 데이터가 없습니다.'] : items;
}

List<TeamStatItem> _parseTeamStats(Map<String, dynamic>? root) {
  if (root == null) return const [];

  final list = root['items'] ?? root['stats'] ?? root['rows'] ?? root['data'];
  if (list is! List) return const [];

  return list
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        final label = _readString(map, const ['label', 'name', 'stat']) ?? '-';
        final homeValue = _parseDouble(map['homeValue'] ?? map['home_value'] ?? map['home']) ?? 0;
        final awayValue = _parseDouble(map['awayValue'] ?? map['away_value'] ?? map['away']) ?? 0;
        return TeamStatItem(
          label: label,
          homeValue: homeValue,
          awayValue: awayValue,
          homeDisplay: _readString(map, const ['homeDisplay', 'home_display']) ??
              _formatStatDisplay(homeValue),
          awayDisplay: _readString(map, const ['awayDisplay', 'away_display']) ??
              _formatStatDisplay(awayValue),
        );
      })
      .toList();
}

String _formatOdds(Object? value) {
  final d = _parseDouble(value);
  if (d == null) return '-';
  return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
}

String _formatPercent(Object? value) {
  final d = _parseDouble(value);
  if (d == null) return '-';
  if (d <= 1) return '${(d * 100).round()}%';
  return '${d.round()}%';
}

String _formatPowerDiff(Object? value) {
  final d = _parseDouble(value);
  if (d == null) return value?.toString() ?? '-';
  return '${d.round()} pts';
}

String _formatCount(Object? value) {
  if (value == null) return '-';
  if (value is num) {
    return value.round().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
  return value.toString();
}

String _normalizeGrade(Object? value) {
  if (value == null) return 'pass';
  final raw = value.toString().toLowerCase();
  if (raw.contains('pick') || raw == 'a') return 'pick';
  if (raw.contains('good') || raw == 'b') return 'good';
  return 'pass';
}

double _parseRatio(Object? value, {double fallback = 0}) {
  return _parseDouble(value) ?? fallback;
}

double _parseProbability(Object? value) {
  final d = _parseDouble(value);
  if (d == null) return 0;
  return d > 1 ? d / 100 : d;
}

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String _formatStatDisplay(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

/// Fallback when API fails — keeps layout with dummy premium data header fields.
SoccerStandardAnalysisParsed fallbackFromDummy(SoccerMatchReportData dummy) {
  return SoccerStandardAnalysisParsed(
    leagueId: dummy.leagueId,
    matchDateDisplay: dummy.matchDate,
    homeTeam: dummy.homeTeam,
    awayTeam: dummy.awayTeam,
    homeLogoUrl: dummy.homeLogoUrl,
    awayLogoUrl: dummy.awayLogoUrl,
    matchTimestampUtc: null,
    prediction: dummy.prediction,
    winProbability: dummy.winProbability,
    powerDiff: dummy.powerDiff,
    analyzedMatches: dummy.analyzedMatches,
    patternStats: dummy.patternStats,
    gradeBadge: dummy.gradeBadge,
    reasoningItems: dummy.reasoningItems,
    homeOdds: dummy.homeOdds,
    drawOdds: dummy.drawOdds,
    awayOdds: dummy.awayOdds,
    homePowerRatio: dummy.homePowerRatio,
    homeProb: dummy.homeProb,
    drawProb: dummy.drawProb,
    awayProb: dummy.awayProb,
    teamStats: dummy.teamStats
        .map(
          (s) => TeamStatItem(
            label: s.label,
            homeValue: s.homeValue,
            awayValue: s.awayValue,
            homeDisplay: s.homeDisplay,
            awayDisplay: s.awayDisplay,
          ),
        )
        .toList(),
    paHomeRatio: dummy.paHomeRatio,
    minMaxHomeRatio: dummy.minMaxHomeRatio,
    firstGoalHomeRatio: dummy.firstGoalHomeRatio,
  );
}
