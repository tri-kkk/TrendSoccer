import 'package:flutter/foundation.dart';
import 'package:trendsoccer/features/analysis/models/parser_labels.dart';
import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/confidence_chip.dart';

void logBaseballPremiumPredict(Map<String, dynamic> predictData) {
  debugPrint('[BASEBALL] Premium predict keys: ${predictData.keys}');

  final prediction = predictData['prediction'] as Map?;
  final insights = predictData['insights'] as Map?;
  final dataQuality = predictData['dataQuality'] as Map?;

  debugPrint(
    '[BASEBALL] Premium WIN PROB: home=${prediction?['homeWinProb']}, away=${prediction?['awayWinProb']}',
  );
  debugPrint(
    '[BASEBALL] Premium O/U PROB: over=${prediction?['overProb']}, under=${prediction?['underProb']}',
  );
  debugPrint('[BASEBALL] Premium CONFIDENCE: ${prediction?['confidence']}');
  debugPrint('[BASEBALL] Premium RECENT FORM: ${insights?['recentForm']}');
  debugPrint('[BASEBALL] Premium HOME ADVANTAGE: ${insights?['homeAdvantage']}');
  debugPrint('[BASEBALL] Premium TEAM FORM: ${insights?['teamForm']}');
  debugPrint('[BASEBALL] Premium TEAM SEASON: ${insights?['teamSeason']}');
  debugPrint('[BASEBALL] Premium DATA QUALITY: $dataQuality');
  debugPrint('[BASEBALL] Premium using predict for sections 3-7');
}

void logBaseballPremiumDetail(Map<String, dynamic> detail) {
  final match = _unwrapMatch(detail);
  final aiPred = match['aiPrediction'] as Map?;
  debugPrint(
    '[BASEBALL] Premium using aiPrediction: homeWinProb=${aiPred?['homeWinProb']}, grade=${match['aiPick']}',
  );
  final odds = match['odds'] as Map?;
  final (overProb, underProb) = _impliedOverUnderProbs(
    _parseDouble(odds?['overOdds']),
    _parseDouble(odds?['underOdds']),
  );
  debugPrint('[BASEBALL] Premium O/U implied: over=$overProb%, under=$underProb%');
}

class PremiumGaugeItem {
  const PremiumGaugeItem({
    required this.label,
    required this.homeStatLabel,
    required this.awayStatLabel,
    required this.homeRatio,
    this.lowerIsBetter = false,
  });

  final String label;
  final String homeStatLabel;
  final String awayStatLabel;
  final double homeRatio;
  final bool lowerIsBetter;
}

class BaseballPremiumParsed {
  const BaseballPremiumParsed({
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamKo,
    this.awayTeamKo,
    required this.awayWinProb,
    required this.homeWinProb,
    required this.grade,
    required this.summary,
    required this.overUnderLine,
    required this.overProb,
    required this.underProb,
    required this.highlightUnder,
    required this.homeAdvantageRecord,
    required this.awayAdvantageRecord,
    required this.homeRecentWinRate,
    required this.awayRecentWinRate,
    required this.confidence,
    required this.teamProduction,
    required this.teamProductionLine1,
    required this.teamProductionLine2,
    required this.league,
    required this.seasonTeamStats,
    required this.hasTeamSeason,
    this.homeAvg,
    this.awayAvg,
    this.homeOps,
    this.awayOps,
    this.homeEra,
    this.awayEra,
    this.homeWhip,
    this.awayWhip,
  });

  final String homeTeam;
  final String awayTeam;
  final String awayWinProb;
  final String homeWinProb;
  final String grade;
  final String summary;
  final String overUnderLine;
  final int overProb;
  final int underProb;
  final bool highlightUnder;
  final String homeAdvantageRecord;
  final String awayAdvantageRecord;
  final String homeRecentWinRate;
  final String awayRecentWinRate;
  final ConfidenceLevel confidence;
  final List<PremiumGaugeItem> teamProduction;
  final String teamProductionLine1;
  final String teamProductionLine2;
  final String league;
  final List<PremiumGaugeItem> seasonTeamStats;
  final bool hasTeamSeason;
  final double? homeAvg;
  final double? awayAvg;
  final double? homeOps;
  final double? awayOps;
  final double? homeEra;
  final double? awayEra;
  final double? homeWhip;
  final double? awayWhip;

  final String? homeTeamKo;
  final String? awayTeamKo;

  factory BaseballPremiumParsed.fromResponses({
    required Map<String, dynamic> matchData,
    Map<String, dynamic>? predictData,
    required ParserLabels labels,
  }) {
    return parseBaseballPremium(
      detail: matchData,
      predict: predictData,
      labels: labels,
    );
  }
}

BaseballPremiumParsed parseBaseballPremium({
  required Map<String, dynamic> detail,
  Map<String, dynamic>? predict,
  required ParserLabels labels,
}) {
  final match = _unwrapMatch(detail);
  final homeSide = _readMap(match, const ['home']) ?? {};
  final awaySide = _readMap(match, const ['away']) ?? {};
  final homeTeamKoFlat = _readString(match, const ['homeTeamKo', 'home_team_ko']);
  final homeTeamEnFlat = _readString(match, const ['homeTeam', 'home_team']);
  final awayTeamKoFlat = _readString(match, const ['awayTeamKo', 'away_team_ko']);
  final awayTeamEnFlat = _readString(match, const ['awayTeam', 'away_team']);
  final homeTeamEn =
      _readString(homeSide, const ['team', 'name']) ?? homeTeamEnFlat;
  final awayTeamEn =
      _readString(awaySide, const ['team', 'name']) ?? awayTeamEnFlat;
  final homeTeamKo =
      _readString(homeSide, const ['teamKo', 'team_ko']) ?? homeTeamKoFlat;
  final awayTeamKo =
      _readString(awaySide, const ['teamKo', 'team_ko']) ?? awayTeamKoFlat;
  final homeTeam = (homeTeamEn ?? '').isNotEmpty
      ? homeTeamEn!
      : (homeTeamKo ?? labels.labelHome);
  final awayTeam = (awayTeamEn ?? '').isNotEmpty
      ? awayTeamEn!
      : (awayTeamKo ?? labels.labelAway);

  final leagueRaw = _readString(match, const ['league', 'leagueName', 'league_name']) ??
      _readString(detail, const ['league']) ??
      'MLB';
  final league = _normalizePremiumLeagueCode(leagueRaw);

  final oddsMap = _mergeOddsMap(match);
  final odds = BaseballOdds.fromJson(oddsMap);
  final aiPred = _readMap(match, const ['aiPrediction', 'ai_prediction']);
  final prediction = predict != null
      ? (_readMap(predict, const ['prediction']) ?? {})
      : <String, dynamic>{};
  final insights = predict != null
      ? (_readMap(predict, const ['insights']) ?? {})
      : <String, dynamic>{};

  final homeWinProbInt = _resolveWinProbPercent(
    aiPred?['homeWinProb'] ?? oddsMap['homeWinProb'],
  );
  final awayWinProbInt = _resolveWinProbPercent(
    aiPred?['awayWinProb'] ?? oddsMap['awayWinProb'],
  );
  final homeWinProb = '$homeWinProbInt%';
  final awayWinProb = '$awayWinProbInt%';

  final gradeRaw =
      match['aiPick'] ?? aiPred?['grade'] ?? prediction['grade'];
  final gradeText = gradeRaw?.toString().trim();
  final grade = (gradeText != null && gradeText.isNotEmpty)
      ? gradeText.toUpperCase()
      : 'PASS';

  final summaryRaw =
      _readString(insights, const ['summary']) ?? labels.baseballAiSummaryDefault;
  final summary = _localizeTeamNamesInSummary(
    _formatPremiumSummary(summaryRaw),
    homeTeamEn: homeTeamEn,
    awayTeamEn: awayTeamEn,
    homeTeamKo: homeTeam,
    awayTeamKo: awayTeam,
  );

  int overProb;
  int underProb;
  if (predict == null) {
    overProb = -1;
    underProb = -1;
  } else {
    overProb = _parseProbPercentInt(prediction['overProb']);
    underProb = _parseProbPercentInt(prediction['underProb']);
    if (overProb == 0 && underProb == 0) {
      final implied = _impliedOverUnderProbs(odds.overOdds, odds.underOdds);
      overProb = implied.$1;
      underProb = implied.$2;
    }
  }
  final highlightUnder =
      overProb > 0 && underProb > 0 && underProb > overProb;

  final recentForm = _readMap(insights, const ['recentForm', 'recent_form']) ?? {};
  final homeAdvantage =
      _readMap(insights, const ['homeAdvantage', 'home_advantage']) ?? {};
  final homeAdvantageRecord =
      (homeAdvantage['homeRecord'] ?? homeAdvantage['home_record'])
              ?.toString()
              .trim() ??
          'N/A';
  final awayAdvantageRecord =
      (homeAdvantage['awayRecord'] ?? homeAdvantage['away_record'])
              ?.toString()
              .trim() ??
          'N/A';
  final homeRecentWinRate = _formatRecentForm(recentForm['home']);
  final awayRecentWinRate = _formatRecentForm(recentForm['away']);

  final confidence = _confidenceFromString(
    _readString(prediction, const ['confidence']) ??
        _readString(match, const ['aiPickConfidence', 'ai_pick_confidence']),
  );

  final teamForm = _readMap(insights, const ['teamForm', 'team_form']) ?? {};
  final homeForm = _readMap(teamForm, const ['home']) ?? {};
  final awayForm = _readMap(teamForm, const ['away']) ?? {};

  final homeScored = _parseDouble(homeForm['scored']) ?? 0;
  final awayScored = _parseDouble(awayForm['scored']) ?? 0;
  final homeConceded = _parseDouble(homeForm['conceded']) ?? 0;
  final awayConceded = _parseDouble(awayForm['conceded']) ?? 0;

  final teamProduction = [
    _gaugeFromTeamForm(
      labels.baseballStatRunsScored,
      homeForm,
      awayForm,
      'scored',
      homeFormat: _formatOneDecimal,
    ),
    _gaugeFromTeamForm(
      labels.baseballStatRunsAllowed,
      homeForm,
      awayForm,
      'conceded',
      homeFormat: _formatOneDecimal,
    ),
    _gaugeFromTeamForm(
      labels.baseballStatHits,
      homeForm,
      awayForm,
      'hits',
      homeFormat: _formatOneDecimal,
    ),
  ];

  final (teamProductionLine1, teamProductionLine2) = _buildProductionLines(
    labels: labels,
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    homeScored: homeScored,
    awayScored: awayScored,
    homeConceded: homeConceded,
    awayConceded: awayConceded,
    hasTeamFormData: _hasTeamFormData(homeForm, awayForm),
  );

  final teamSeason = _readMap(insights, const ['teamSeason', 'team_season']);
  final homeSeason = teamSeason != null
      ? _readMap(teamSeason, const ['home'])
      : null;
  final awaySeason = teamSeason != null
      ? _readMap(teamSeason, const ['away'])
      : null;

  final homeAvg = _parseDouble(homeSeason?['avg']);
  final awayAvg = _parseDouble(awaySeason?['avg']);
  final homeOps = _parseDouble(homeSeason?['ops']);
  final awayOps = _parseDouble(awaySeason?['ops']);
  final homeEra = _parseDouble(homeSeason?['era']);
  final awayEra = _parseDouble(awaySeason?['era']);
  final homeWhip = _parseDouble(homeSeason?['whip']);
  final awayWhip = _parseDouble(awaySeason?['whip']);

  final hasTeamSeason = homeSeason != null && awaySeason != null;

  final seasonTeamStats = hasTeamSeason
      ? [
          _seasonGauge(
            'AVG',
            homeAvg,
            awayAvg,
            format: _formatThreeDecimal,
          ),
          _seasonGauge(
            'OPS',
            homeOps,
            awayOps,
            format: _formatThreeDecimal,
          ),
          _seasonGauge(
            'ERA',
            homeEra,
            awayEra,
            format: _formatTwoDecimal,
            lowerIsBetter: true,
          ),
          _seasonGauge(
            'WHIP',
            homeWhip,
            awayWhip,
            format: _formatTwoDecimal,
            lowerIsBetter: true,
          ),
        ]
      : const <PremiumGaugeItem>[];

  return BaseballPremiumParsed(
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    homeTeamKo: homeTeamKo,
    awayTeamKo: awayTeamKo,
    awayWinProb: awayWinProb,
    homeWinProb: homeWinProb,
    grade: grade,
    summary: summary,
    overUnderLine: _formatLine(odds.overUnderLine),
    overProb: overProb,
    underProb: underProb,
    highlightUnder: highlightUnder,
    homeAdvantageRecord: homeAdvantageRecord,
    awayAdvantageRecord: awayAdvantageRecord,
    homeRecentWinRate: homeRecentWinRate,
    awayRecentWinRate: awayRecentWinRate,
    confidence: confidence,
    teamProduction: teamProduction,
    teamProductionLine1: teamProductionLine1,
    teamProductionLine2: teamProductionLine2,
    league: league,
    seasonTeamStats: seasonTeamStats,
    hasTeamSeason: hasTeamSeason,
    homeAvg: homeAvg,
    awayAvg: awayAvg,
    homeOps: homeOps,
    awayOps: awayOps,
    homeEra: homeEra,
    awayEra: awayEra,
    homeWhip: homeWhip,
    awayWhip: awayWhip,
  );
}

bool _hasTeamFormData(Map<String, dynamic> homeForm, Map<String, dynamic> awayForm) {
  for (final key in const ['scored', 'conceded', 'hits']) {
    final home = _parseDouble(homeForm[key]);
    final away = _parseDouble(awayForm[key]);
    if ((home ?? 0) > 0 || (away ?? 0) > 0) return true;
  }
  return false;
}

(String, String) _buildProductionLines({
  required ParserLabels labels,
  required String homeTeam,
  required String awayTeam,
  required double homeScored,
  required double awayScored,
  required double homeConceded,
  required double awayConceded,
  required bool hasTeamFormData,
}) {
  if (!hasTeamFormData) {
    return (labels.baseballTeamProductivityComment, '');
  }

  final homeScoredMore = homeScored >= awayScored;
  final batterTeam = homeScoredMore ? homeTeam : awayTeam;
  final batterValue = homeScoredMore ? homeScored : awayScored;
  final line1 = labels.baseballProductionBatterEdge(
    batterTeam,
    batterValue.toStringAsFixed(1),
  );

  final homeBetterDefense = homeConceded <= awayConceded;
  final defenseTeam = homeBetterDefense ? homeTeam : awayTeam;
  final defenseValue = homeBetterDefense ? homeConceded : awayConceded;
  final line2 = labels.baseballProductionDefenseEdge(
    defenseTeam,
    defenseValue.toStringAsFixed(1),
  );

  return (line1, line2);
}

PremiumGaugeItem _gaugeFromTeamForm(
  String label,
  Map<String, dynamic> homeForm,
  Map<String, dynamic> awayForm,
  String key, {
  required String Function(double) homeFormat,
}) {
  final homeValue = _parseDouble(homeForm[key]) ?? 0;
  final awayValue = _parseDouble(awayForm[key]) ?? 0;
  final total = homeValue + awayValue;
  final ratio = total > 0 ? (homeValue / total).clamp(0.0, 1.0) : 0.5;

  return PremiumGaugeItem(
    label: label,
    homeStatLabel: homeFormat(homeValue),
    awayStatLabel: homeFormat(awayValue),
    homeRatio: ratio,
  );
}

PremiumGaugeItem _seasonGauge(
  String label,
  double? homeValue,
  double? awayValue, {
  required String Function(double) format,
  bool lowerIsBetter = false,
}) {
  final homeNum = homeValue ?? 0;
  final awayNum = awayValue ?? 0;
  final ratio = _ratioForValues(
    homeNum,
    awayNum,
    lowerIsBetter: lowerIsBetter,
  );

  return PremiumGaugeItem(
    label: label,
    homeStatLabel: homeValue != null ? format(homeNum) : '-',
    awayStatLabel: awayValue != null ? format(awayNum) : '-',
    homeRatio: ratio,
    lowerIsBetter: lowerIsBetter,
  );
}

double _ratioForValues(
  double homeValue,
  double awayValue, {
  required bool lowerIsBetter,
}) {
  if (lowerIsBetter) {
    if (homeValue <= 0 && awayValue <= 0) return 0.5;
    if (homeValue <= 0) return 0;
    if (awayValue <= 0) return 1;
    final homeScore = 1 / homeValue;
    final awayScore = 1 / awayValue;
    final total = homeScore + awayScore;
    return total > 0 ? (homeScore / total).clamp(0.0, 1.0) : 0.5;
  }

  final total = homeValue + awayValue;
  return total > 0 ? (homeValue / total).clamp(0.0, 1.0) : 0.5;
}

ConfidenceLevel _confidenceFromString(String? value) {
  switch (value?.toUpperCase().trim()) {
    case 'HIGH':
      return ConfidenceLevel.high;
    case 'LOW':
      return ConfidenceLevel.low;
    case 'MEDIUM':
    default:
      return ConfidenceLevel.medium;
  }
}

int _parseProbPercentInt(Object? value) {
  final parsed = _parseDouble(value);
  if (parsed == null) return 0;
  if (parsed > 0 && parsed <= 1) return (parsed * 100).round();
  return parsed.round();
}

int _resolveWinProbPercent(Object? value) {
  final parsed = _parseProbPercentInt(value);
  return parsed > 0 ? parsed : 50;
}

(int, int) _impliedOverUnderProbs(double? overOdds, double? underOdds) {
  final overVal = overOdds ?? 2.0;
  final underVal = underOdds ?? 2.0;
  if (overVal <= 0 || underVal <= 0) return (50, 50);

  var overProb = (100 / overVal).round();
  var underProb = (100 / underVal).round();
  final totalProb = overProb + underProb;
  if (totalProb > 0) {
    overProb = (overProb * 100 / totalProb).round();
    underProb = 100 - overProb;
  }
  return (overProb, underProb);
}

String _formatRecentForm(Object? value) {
  if (value == null) return '-';
  final text = value.toString().trim();
  if (text.isEmpty) return '-';
  if (text.contains('%')) return text;
  final parsed = _parseDouble(value);
  if (parsed == null) return text;
  if (parsed == parsed.roundToDouble()) {
    return '${parsed.round()}%';
  }
  return '${parsed.toStringAsFixed(1)}%';
}

String _formatOneDecimal(double value) => value.toStringAsFixed(1);

String _formatThreeDecimal(double value) => value.toStringAsFixed(3);

String _formatTwoDecimal(double value) => value.toStringAsFixed(2);

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

String _formatLine(double? value) {
  if (value == null) return '-';
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

String _formatPremiumSummary(String text) {
  if (text.isEmpty) return text;

  text = text.replaceAll(r'\n', '\n');

  if (text.contains('\n') &&
      text.split('\n').where((segment) => segment.trim().isNotEmpty).length >
          1) {
    return text.trim();
  }

  return text
      .replaceAllMapped(
        RegExp(r'(\.\s)(?=\S)'),
        (match) => '.\n\n',
      )
      .trim();
}

String _localizeTeamNamesInSummary(
  String summary, {
  String? homeTeamEn,
  String? awayTeamEn,
  required String homeTeamKo,
  required String awayTeamKo,
}) {
  var localized = summary;
  if (homeTeamEn != null && homeTeamEn.isNotEmpty) {
    localized = localized.replaceAll(homeTeamEn, homeTeamKo);
  }
  if (awayTeamEn != null && awayTeamEn.isNotEmpty) {
    localized = localized.replaceAll(awayTeamEn, awayTeamKo);
  }
  return localized;
}

Map<String, dynamic>? _readMap(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) return null;
  for (final key in keys) {
    final value = map[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
}

String? _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
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

String _normalizePremiumLeagueCode(String league) {
  final upper = league.trim().toUpperCase();
  if (upper.contains('MLB') || upper.contains('MAJOR')) return 'MLB';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('KBO') || upper.contains('KOREA')) return 'KBO';
  if (upper.contains('CPBL')) return 'CPBL';
  return upper.isEmpty ? 'MLB' : upper;
}
