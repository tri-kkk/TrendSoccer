import 'package:flutter/foundation.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/features/analysis/models/soccer_match_report_data.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/reasoning_section.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/team_statistics_section.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/three_method_section.dart';

/// Parsed Standard-tab fields from `/api/predict-v2`.
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
    required this.gradeBadge,
    required this.analysisMatchCount,
    required this.patternMatchCount,
    required this.reasoningItems,
    required this.homeOdds,
    required this.drawOdds,
    required this.awayOdds,
    required this.homePowerDisplay,
    required this.awayPowerDisplay,
    required this.homePowerRatio,
    required this.homeProb,
    required this.drawProb,
    required this.awayProb,
    required this.teamStats,
    required this.threeMethods,
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
  final String gradeBadge;
  final String analysisMatchCount;
  final String patternMatchCount;

  final List<ReasoningDisplayItem> reasoningItems;

  final String homeOdds;
  final String drawOdds;
  final String awayOdds;

  final String homePowerDisplay;
  final String awayPowerDisplay;
  final double homePowerRatio;

  final double homeProb;
  final double drawProb;
  final double awayProb;

  final List<TeamStatItem> teamStats;

  final List<ThreeMethodData> threeMethods;
}

SoccerStandardAnalysisParsed parseSoccerStandardAnalysis(
  Map<String, dynamic> raw, {
  DateTime? fallbackMatchTimestamp,
  MatchHeaderData? headerFallback,
}) {
  final predictionRoot =
      _readMap(raw, const ['prediction']) ?? _readMap(raw, const ['data']) ?? raw;

  _logPredictV2Structure(predictionRoot);

  final recommendation =
      _readMap(predictionRoot, const ['recommendation']);
  final finalProb =
      _readMap(predictionRoot, const ['finalProb', 'final_prob']);
  final patternStats =
      _readMap(predictionRoot, const ['patternStats', 'pattern_stats']);
  final debug = _readMap(predictionRoot, const ['debug']);
  final homePA = _readMap(predictionRoot, const ['homePA', 'home_pa']);
  final awayPA = _readMap(predictionRoot, const ['awayPA', 'away_pa']);
  final method1 = _readMap(predictionRoot, const ['method1', 'method_1']);
  final method2 = _readMap(predictionRoot, const ['method2', 'method_2']);
  final method3 = _readMap(predictionRoot, const ['method3', 'method_3']);

  final match = _readMap(raw, const ['match', 'fixture', 'game']) ?? raw;
  final odds = _readMap(raw, const ['odds', 'matchOdds', 'match_odds']);

  final homeTeamMap = _readMap(match, const ['homeTeam', 'home_team', 'home']);
  final awayTeamMap = _readMap(match, const ['awayTeam', 'away_team', 'away']);
  final leagueMap = _readMap(match, const ['league', 'leagueInfo', 'league_info']);

  final homeName = headerFallback?.homeTeam ??
      _readString(homeTeamMap, const ['name']) ??
      _readString(match, const ['homeTeamName', 'home_team_name', 'home']) ??
      '';
  final awayName = headerFallback?.awayTeam ??
      _readString(awayTeamMap, const ['name']) ??
      _readString(match, const ['awayTeamName', 'away_team_name', 'away']) ??
      '';

  final matchTimestamp =
      headerFallback?.matchTimestamp ?? _parseMatchTimestamp(match) ?? fallbackMatchTimestamp;

  final homePower = _parseDouble(
    predictionRoot['homePower'] ?? predictionRoot['home_power'],
  );
  final awayPower = _parseDouble(
    predictionRoot['awayPower'] ?? predictionRoot['away_power'],
  );
  final totalPower = (homePower ?? 0) + (awayPower ?? 0);
  final homePowerRatioFromApi = totalPower > 0 && homePower != null && awayPower != null
      ? homePower / totalPower
      : null;

  final homeProbValue = _parseProbability(finalProb?['home']);
  final drawProbValue = _parseProbability(finalProb?['draw']);
  final awayProbValue = _parseProbability(finalProb?['away']);

  final pickRaw = _readString(recommendation, const ['pick', 'direction']);

  final threeMethods = [
    _parseMethodBreakdown(method1, 'P/A비교'),
    _parseMethodBreakdown(method2, 'MIN-MAX 비교'),
    _parseMethodBreakdown(method3, '선제골'),
  ];
  debugPrint(
    '[SOCCER] 3-Method parsed: ${threeMethods.map((m) => 'win=${m.win} draw=${m.draw} lose=${m.lose}').toList()}',
  );

  return SoccerStandardAnalysisParsed(
    leagueId: headerFallback?.resolvedLeagueIconId ??
        (leagueMap == null
            ? 'league_0'
            : leagueIdForCard(
                LeagueInfo.fromJson(leagueMap),
              )),
    matchDateDisplay: headerFallback?.displayDate ?? _formatMatchDateDisplay(match),
    homeTeam: homeName.isEmpty ? '홈' : homeName,
    awayTeam: awayName.isEmpty ? '원정' : awayName,
    homeLogoUrl: headerFallback?.homeTeamLogo ??
        _readString(homeTeamMap, const ['logo', 'logoUrl', 'logo_url']),
    awayLogoUrl: headerFallback?.awayTeamLogo ??
        _readString(awayTeamMap, const ['logo', 'logoUrl', 'logo_url']),
    matchTimestampUtc: matchTimestamp?.toUtc(),
    prediction: _formatPickDisplayKorean(pickRaw),
    winProbability: _formatPickWinProbability(
      pickRaw,
      homeProbValue,
      drawProbValue,
      awayProbValue,
    ),
    powerDiff: _formatAbsPowerDiff(homePower, awayPower),
    gradeBadge: _normalizeGrade(recommendation?['grade']),
    analysisMatchCount: _formatPatternTotalMatches(patternStats),
    patternMatchCount: _formatPatternDisplay(
      predictionRoot: predictionRoot,
      patternStats: patternStats,
    ),
    reasoningItems: _parseReasoningFromRecommendation(recommendation?['reasons']),
    homeOdds: _formatOdds(
      headerFallback?.homeOdds ??
          odds?['home'] ??
          odds?['homeOdds'] ??
          odds?['home_odds'],
    ),
    drawOdds: _formatOdds(
      headerFallback?.drawOdds ??
          odds?['draw'] ??
          odds?['drawOdds'] ??
          odds?['draw_odds'],
    ),
    awayOdds: _formatOdds(
      headerFallback?.awayOdds ??
          odds?['away'] ??
          odds?['awayOdds'] ??
          odds?['away_odds'],
    ),
    homePowerDisplay: _formatPowerValue(homePower),
    awayPowerDisplay: _formatPowerValue(awayPower),
    homePowerRatio: homePowerRatioFromApi ?? 0.5,
    homeProb: homeProbValue,
    drawProb: drawProbValue,
    awayProb: awayProbValue,
    teamStats: _parseTeamStatsFromDebug(
      debug: debug,
      homePA: homePA,
      awayPA: awayPA,
    ),
    threeMethods: threeMethods,
  );
}

void _logPredictV2Structure(Map<String, dynamic> pred) {
  debugPrint('[SOCCER] parse predict-v2 root keys: ${pred.keys.toList()}');
  debugPrint('[SOCCER] prediction.pattern: ${pred['pattern']}');
  debugPrint('[SOCCER] homePA: ${pred['homePA']}');
  debugPrint('[SOCCER] awayPA: ${pred['awayPA']}');
  final homePA = pred['homePA'];
  if (homePA is Map) {
    debugPrint('[SOCCER] homePA.all: ${homePA['all']}');
    debugPrint('[SOCCER] homePA.five: ${homePA['five']}');
    debugPrint('[SOCCER] homePA.firstGoal: ${homePA['firstGoal']}');
  }
  final debug = pred['debug'];
  if (debug is Map) {
    debugPrint('[SOCCER] debug.homeStats: ${debug['homeStats']}');
    debugPrint('[SOCCER] debug.awayStats: ${debug['awayStats']}');
  }
  final patternStats = pred['patternStats'];
  if (patternStats is Map) {
    debugPrint('[SOCCER] patternStats keys: ${patternStats.keys.toList()}');
  }
}

String _formatPickDirection(String? pick) {
  if (pick == null || pick.trim().isEmpty) return '';
  final normalized = pick.trim().toUpperCase();
  if (normalized.contains('HOME') || normalized == 'H' || normalized == '1') {
    return 'HOME';
  }
  if (normalized.contains('DRAW') ||
      normalized.contains('TIE') ||
      normalized == 'X' ||
      normalized == 'D') {
    return 'DRAW';
  }
  if (normalized.contains('AWAY') || normalized == 'A' || normalized == '2') {
    return 'AWAY';
  }
  return normalized;
}

String _formatPickDisplayKorean(String? pick) {
  return switch (_formatPickDirection(pick)) {
    'HOME' => '홈 승',
    'DRAW' => '무승부',
    'AWAY' => '원정 승',
    _ => '-',
  };
}

String _formatPickWinProbability(
  String? pick,
  double homeProb,
  double drawProb,
  double awayProb,
) {
  final direction = _formatPickDirection(pick);
  final prob = switch (direction) {
    'HOME' => homeProb,
    'DRAW' => drawProb,
    'AWAY' => awayProb,
    _ => 0.0,
  };
  if (prob <= 0) return '-';
  return _formatPercent(prob <= 1 ? prob * 100 : prob);
}

String _formatAbsPowerDiff(double? homePower, double? awayPower) {
  if (homePower == null || awayPower == null) return '-';
  return (homePower - awayPower).abs().round().toString();
}

String _formatPowerValue(double? value) {
  if (value == null) return '-';
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}

List<ReasoningDisplayItem> _parseReasoningFromRecommendation(Object? reasonsRaw) {
  if (reasonsRaw is! List || reasonsRaw.isEmpty) {
    return const [];
  }

  final items = <ReasoningDisplayItem>[];
  for (final reason in reasonsRaw) {
    if (items.length >= 5) break;
    if (reason is! String) continue;

    final trimmed = reason.trim();
    if (trimmed.isEmpty) continue;
    if (_shouldSkipReason(trimmed)) continue;

    items.add(_parseReasonString(trimmed));
  }

  return items;
}

bool _shouldSkipReason(String reason) {
  final lower = reason.toLowerCase();
  return lower.startsWith('data:');
}

ReasoningDisplayItem _parseReasonString(String reason) {
  final lower = reason.toLowerCase();

  if (lower.startsWith('power diff') || lower.contains('power diff:')) {
    final raw = reason.contains(':') ? reason.split(':').last.trim() : reason;
    final value = raw
        .replaceAll(RegExp(r'pts', caseSensitive: false), '')
        .trim();
    return ReasoningDisplayItem(
      label: '파워 차이',
      value: value.isEmpty ? '-' : '$value점',
    );
  }

  if (lower.contains('prob edge')) {
    final value = reason.contains(':') ? reason.split(':').last.trim() : reason;
    return ReasoningDisplayItem(
      label: '확률 우위',
      value: value.isEmpty ? '-' : value,
    );
  }

  if (lower.startsWith('pattern:') || lower.contains('pattern:')) {
    final segment = reason.contains(':') ? reason.split(':').last.trim() : reason;
    final match = RegExp(r'(\d+)').firstMatch(segment);
    if (match != null) {
      final count = int.tryParse(match.group(1)!);
      if (count != null) {
        return ReasoningDisplayItem(
          label: '패턴',
          value: '${_formatCountWithComma(count)} 경기 기반',
        );
      }
    }
    return ReasoningDisplayItem(
      label: '패턴',
      value: segment.isEmpty ? '-' : segment,
    );
  }

  if (lower.contains('1st goal') ||
      lower.contains('first goal') ||
      lower.contains('선득점')) {
    final value = reason.contains(':') ? reason.split(':').last.trim() : reason;
    final label = lower.contains('away') ? '원정 선득점 승률' : '홈 선득점 승률';
    return ReasoningDisplayItem(
      label: label,
      value: value.isEmpty ? '-' : value,
    );
  }

  return ReasoningDisplayItem(label: reason, value: '');
}

String _formatPatternDisplay({
  required Map<String, dynamic> predictionRoot,
  Map<String, dynamic>? patternStats,
}) {
  final pattern = predictionRoot['pattern'];
  if (pattern is String && pattern.trim().isNotEmpty) {
    return pattern.trim();
  }

  final home = _parseDouble(patternStats?['homeWinRate'] ?? patternStats?['home_win_rate']);
  final draw = _parseDouble(patternStats?['drawRate'] ?? patternStats?['draw_rate']);
  final away = _parseDouble(patternStats?['awayWinRate'] ?? patternStats?['away_win_rate']);
  if (home == null && draw == null && away == null) return '-';

  final homePart = ((home ?? 0) * 10).round();
  final drawPart = ((draw ?? 0) * 10).round();
  final awayPart = ((away ?? 0) * 10).round();
  return '$homePart-$drawPart-$awayPart';
}

ThreeMethodData _parseMethodBreakdown(
  Map<String, dynamic>? method,
  String label,
) {
  return ThreeMethodData(
    label: label,
    win: _parseMethodProbability(method?['win']),
    draw: _parseMethodProbability(method?['draw']),
    lose: _parseMethodProbability(method?['lose'] ?? method?['loss']),
  );
}

String _formatPatternTotalMatches(Map<String, dynamic>? patternStats) {
  final total = _parseDouble(
    patternStats?['totalMatches'] ?? patternStats?['total_matches'],
  );
  if (total == null) return '-';
  return _formatCountWithComma(total.round());
}

String _formatCountWithComma(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}

double? _parseMethodProbability(Object? value) {
  final parsed = _parseDouble(value);
  if (parsed == null) return null;
  return parsed <= 1 ? parsed : parsed / 100;
}

enum _StatFormat { integerPercent, form }

List<TeamStatItem> _parseTeamStatsFromDebug({
  required Map<String, dynamic>? debug,
  required Map<String, dynamic>? homePA,
  required Map<String, dynamic>? awayPA,
}) {
  final homeStats = _readMap(debug, const ['homeStats', 'home_stats']);
  final awayStats = _readMap(debug, const ['awayStats', 'away_stats']);

  return [
    _buildCompareStatItem(
      label: '선제골 승률',
      homeValue: _parseDouble(homeStats?['homeFirstGoalWinRate']),
      awayValue: _parseDouble(awayStats?['awayFirstGoalWinRate']),
      format: _StatFormat.integerPercent,
    ),
    _buildCompareStatItem(
      label: '역전률',
      homeValue: _parseDouble(homeStats?['homeComebackRate']),
      awayValue: _parseDouble(awayStats?['awayComebackRate']),
      format: _StatFormat.integerPercent,
    ),
    _buildCompareStatItem(
      label: '최근 폼',
      homeValue: _parseDouble(homeStats?['form']),
      awayValue: _parseDouble(awayStats?['form']),
      format: _StatFormat.form,
    ),
    _buildGoalRatioStatItem(
      homeRatio: _parsePaAllValue(homePA),
      awayRatio: _parsePaAllValue(awayPA),
    ),
  ];
}

double? _parsePaAllValue(Map<String, dynamic>? paMap) {
  if (paMap == null) return null;
  final all = paMap['all'];
  if (all is num) return all.toDouble();
  return _parseDouble(all);
}

TeamStatItem _buildGoalRatioStatItem({
  required double? homeRatio,
  required double? awayRatio,
}) {
  final homeDisplay = _formatGoalRatioValue(homeRatio);
  final awayDisplay = _formatGoalRatioValue(awayRatio);

  var homeHighlighted = false;
  var awayHighlighted = false;
  if (homeRatio != null && awayRatio != null) {
    if (homeRatio > awayRatio) {
      homeHighlighted = true;
    } else if (awayRatio > homeRatio) {
      awayHighlighted = true;
    }
  }

  return TeamStatItem(
    label: '득실비',
    homeValue: homeRatio ?? 0,
    awayValue: awayRatio ?? 0,
    homeDisplay: homeDisplay,
    awayDisplay: awayDisplay,
    homeHighlighted: homeHighlighted,
    awayHighlighted: awayHighlighted,
  );
}

String _formatGoalRatioValue(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(2);
}

TeamStatItem _buildCompareStatItem({
  required String label,
  required double? homeValue,
  required double? awayValue,
  required _StatFormat format,
}) {
  final homeDisplay = switch (format) {
    _StatFormat.integerPercent => _formatIntegerPercent(homeValue),
    _StatFormat.form => _formatFormValue(homeValue),
  };
  final awayDisplay = switch (format) {
    _StatFormat.integerPercent => _formatIntegerPercent(awayValue),
    _StatFormat.form => _formatFormValue(awayValue),
  };

  var homeHighlighted = false;
  var awayHighlighted = false;
  if (homeValue != null &&
      awayValue != null &&
      homeDisplay != '-' &&
      awayDisplay != '-') {
    if (homeValue > awayValue) {
      homeHighlighted = true;
    } else if (awayValue > homeValue) {
      awayHighlighted = true;
    }
  }

  return TeamStatItem(
    label: label,
    homeValue: _parseDoubleForBar(homeDisplay),
    awayValue: _parseDoubleForBar(awayDisplay),
    homeDisplay: homeDisplay,
    awayDisplay: awayDisplay,
    homeHighlighted: homeHighlighted,
    awayHighlighted: awayHighlighted,
  );
}

String _formatIntegerPercent(double? value) {
  if (value == null) return '-';
  final percent = value < 1.0 ? value * 100 : value;
  return '${percent.round()}%';
}

String _formatFormValue(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(1);
}

double _parseDoubleForBar(String display) {
  if (display == '-') return 0;
  final cleaned = display.replaceAll('%', '').trim();
  final parsed = double.tryParse(cleaned);
  return parsed ?? 0;
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

String _formatOdds(Object? value) {
  final d = _parseDouble(value);
  if (d == null) return '-';
  return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
}

String _formatPercent(Object? value, {int decimals = 0}) {
  final d = _parseDouble(value);
  if (d == null) return '-';
  if (decimals > 0) {
    return '${d.toStringAsFixed(decimals)}%';
  }
  return '${d.round()}%';
}

String _normalizeGrade(Object? value) {
  if (value == null) return 'pass';
  final raw = value.toString().toLowerCase();
  if (raw.contains('pick') || raw == 'a') return 'pick';
  if (raw.contains('good') || raw == 'b') return 'good';
  return 'pass';
}

double _parseProbability(Object? value) {
  final d = _parseDouble(value);
  if (d == null) return 0;
  return d > 1 ? d / 100 : d;
}

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll('%', '').trim());
  return null;
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
    powerDiff: dummy.powerDiff.replaceAll(' pts', '').replaceAll('pts', '').trim(),
    gradeBadge: dummy.gradeBadge,
    analysisMatchCount: dummy.analyzedMatches,
    patternMatchCount: dummy.patternStats,
    reasoningItems: dummy.reasoningItems
        .map((item) => ReasoningDisplayItem(label: '근거', value: item))
        .toList(),
    homeOdds: dummy.homeOdds,
    drawOdds: dummy.drawOdds,
    awayOdds: dummy.awayOdds,
    homePowerDisplay: '-',
    awayPowerDisplay: '-',
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
    threeMethods: [
      ThreeMethodData(
        label: 'P/A비교',
        win: dummy.paHomeRatio,
        draw: null,
        lose: dummy.paAwayRatio,
      ),
      ThreeMethodData(
        label: 'MIN-MAX 비교',
        win: dummy.minMaxHomeRatio,
        draw: null,
        lose: dummy.minMaxAwayRatio,
      ),
      ThreeMethodData(
        label: '선제골',
        win: dummy.firstGoalHomeRatio,
        draw: null,
        lose: dummy.firstGoalAwayRatio,
      ),
    ],
  );
}
