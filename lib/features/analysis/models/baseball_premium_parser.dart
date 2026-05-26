import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/confidence_chip.dart';

void logBaseballPremiumPredict(Map<String, dynamic> predictData) {
  print('[BASEBALL] Premium predict keys: ${predictData.keys}');

  final prediction = predictData['prediction'] as Map?;
  final insights = predictData['insights'] as Map?;
  final dataQuality = predictData['dataQuality'] as Map?;

  print(
    '[BASEBALL] Premium WIN PROB: home=${prediction?['homeWinProb']}, away=${prediction?['awayWinProb']}',
  );
  print(
    '[BASEBALL] Premium O/U PROB: over=${prediction?['overProb']}, under=${prediction?['underProb']}',
  );
  print('[BASEBALL] Premium CONFIDENCE: ${prediction?['confidence']}');
  print('[BASEBALL] Premium RECENT FORM: ${insights?['recentForm']}');
  print('[BASEBALL] Premium HOME ADVANTAGE: ${insights?['homeAdvantage']}');
  print('[BASEBALL] Premium TEAM FORM: ${insights?['teamForm']}');
  print('[BASEBALL] Premium TEAM SEASON: ${insights?['teamSeason']}');
  print('[BASEBALL] Premium DATA QUALITY: $dataQuality');
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
    required this.awayWinProb,
    required this.homeWinProb,
    required this.summary,
    required this.overUnderLine,
    required this.overOdds,
    required this.underOdds,
    required this.highlightUnder,
    required this.awayRecentForm,
    required this.homeRecentForm,
    required this.confidence,
    required this.teamProduction,
    required this.teamProductionDescription,
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
  final String summary;
  final String overUnderLine;
  final String overOdds;
  final String underOdds;
  final bool highlightUnder;
  final String awayRecentForm;
  final String homeRecentForm;
  final ConfidenceLevel confidence;
  final List<PremiumGaugeItem> teamProduction;
  final String teamProductionDescription;
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
}

BaseballPremiumParsed parseBaseballPremium({
  required Map<String, dynamic> detail,
  required Map<String, dynamic> predict,
}) {
  final match = _unwrapMatch(detail);
  final homeSide = _readMap(match, const ['home']) ?? {};
  final awaySide = _readMap(match, const ['away']) ?? {};
  final homeTeam = _preferKo(
    _readString(homeSide, const ['teamKo', 'team_ko']),
    _readString(homeSide, const ['team', 'name']) ?? '홈',
  );
  final awayTeam = _preferKo(
    _readString(awaySide, const ['teamKo', 'team_ko']),
    _readString(awaySide, const ['team', 'name']) ?? '원정',
  );

  final oddsMap = _mergeOddsMap(match);
  final odds = BaseballOdds.fromJson(oddsMap);
  final prediction = _readMap(predict, const ['prediction']) ?? {};
  final insights = _readMap(predict, const ['insights']) ?? {};

  final homeWinProb = _formatWinProb(prediction['homeWinProb']);
  final awayWinProb = _formatWinProb(prediction['awayWinProb']);

  final summary = _readString(insights, const ['summary']) ?? 'AI 분석 데이터';

  final overProb = _parseDouble(prediction['overProb']);
  final underProb = _parseDouble(prediction['underProb']);
  final highlightUnder = (underProb ?? 0) > (overProb ?? 0);

  final recentForm = _readMap(insights, const ['recentForm', 'recent_form']) ?? {};
  final homeAdvantage =
      _readMap(insights, const ['homeAdvantage', 'home_advantage']) ?? {};
  final awayRecentForm = _formatRecentFormWithRecord(
    recentForm['away'],
    homeAdvantage['awayRecord'] ?? homeAdvantage['away_record'],
  );
  final homeRecentForm = _formatRecentFormWithRecord(
    recentForm['home'],
    homeAdvantage['homeRecord'] ?? homeAdvantage['home_record'],
  );

  final confidence = _confidenceFromString(
    _readString(prediction, const ['confidence']),
  );

  final teamForm = _readMap(insights, const ['teamForm', 'team_form']) ?? {};
  final homeForm = _readMap(teamForm, const ['home']) ?? {};
  final awayForm = _readMap(teamForm, const ['away']) ?? {};

  final homeScored = _parseDouble(homeForm['scored']) ?? 0;
  final awayScored = _parseDouble(awayForm['scored']) ?? 0;

  final teamProduction = [
    _gaugeFromTeamForm(
      '득점',
      homeForm,
      awayForm,
      'scored',
      homeFormat: _formatOneDecimal,
    ),
    _gaugeFromTeamForm(
      '실점',
      homeForm,
      awayForm,
      'conceded',
      homeFormat: _formatOneDecimal,
    ),
    _gaugeFromTeamForm(
      '안타',
      homeForm,
      awayForm,
      'hits',
      homeFormat: _formatOneDecimal,
    ),
  ];

  final teamProductionDescription = _buildProductionDescription(
    summary: summary,
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    homeScored: homeScored,
    awayScored: awayScored,
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
    awayWinProb: awayWinProb,
    homeWinProb: homeWinProb,
    summary: summary,
    overUnderLine: _formatLine(odds.overUnderLine),
    overOdds: _formatOdds(odds.overOdds),
    underOdds: _formatOdds(odds.underOdds),
    highlightUnder: highlightUnder,
    awayRecentForm: awayRecentForm,
    homeRecentForm: homeRecentForm,
    confidence: confidence,
    teamProduction: teamProduction,
    teamProductionDescription: teamProductionDescription,
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

String _buildProductionDescription({
  required String summary,
  required String homeTeam,
  required String awayTeam,
  required double homeScored,
  required double awayScored,
  required bool hasTeamFormData,
}) {
  if (hasTeamFormData) {
    if (summary.trim().isNotEmpty && summary != 'AI 분석 데이터') {
      return summary;
    }
    if (homeScored > awayScored) {
      return '$homeTeam 타선 우세 (${homeScored.toStringAsFixed(1)}점/경기)';
    }
    if (awayScored > homeScored) {
      return '$awayTeam 타선 우세 (${awayScored.toStringAsFixed(1)}점/경기)';
    }
  }
  return '최근 10경기 팀 공격 생산성 지표입니다.';
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

String _formatRecentFormWithRecord(Object? percent, Object? record) {
  final pct = _formatRecentForm(percent);
  final recordText = record?.toString().trim();
  if (recordText == null ||
      recordText.isEmpty ||
      recordText.toUpperCase() == 'N/A') {
    return pct;
  }
  return '$pct ($recordText)';
}

String _formatWinProb(Object? value) {
  if (value == null) return '-';
  final parsed = _parseDouble(value);
  if (parsed == null) return '-';
  if (parsed == parsed.roundToDouble()) {
    return '${parsed.round()}%';
  }
  return '${parsed.toStringAsFixed(1)}%';
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
  return detail;
}

Map<String, dynamic> _mergeOddsMap(Map<String, dynamic> match) {
  final odds = match['odds'];
  if (odds is Map<String, dynamic>) return odds;
  if (odds is Map) return Map<String, dynamic>.from(odds);
  return match;
}

String _formatOdds(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(2);
}

String _formatLine(double? value) {
  if (value == null) return '-';
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

String _preferKo(String? ko, String fallback) {
  final trimmedKo = ko?.trim();
  if (trimmedKo != null && trimmedKo.isNotEmpty) return trimmedKo;
  return fallback.trim().isEmpty ? '-' : fallback.trim();
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
