/// Away / home value pair with bar ratio for premium baseball UI.
class GaugeStat {
  const GaugeStat({
    required this.awayValue,
    required this.homeValue,
    required this.awayRatio,
  });

  final String awayValue;
  final String homeValue;
  final double awayRatio;

  Map<String, dynamic> toJson() => {
        'awayValue': awayValue,
        'homeValue': homeValue,
        'awayRatio': awayRatio,
      };

  factory GaugeStat.fromJson(Map<String, dynamic> json) {
    return GaugeStat(
      awayValue: json['awayValue'] as String,
      homeValue: json['homeValue'] as String,
      awayRatio: (json['awayRatio'] as num).toDouble(),
    );
  }
}

class WinProbability {
  const WinProbability({
    required this.awayWinPercent,
    required this.homeWinPercent,
    required this.description,
  });

  final String awayWinPercent;
  final String homeWinPercent;
  final String description;

  Map<String, dynamic> toJson() => {
        'awayWinPercent': awayWinPercent,
        'homeWinPercent': homeWinPercent,
        'description': description,
      };

  factory WinProbability.fromJson(Map<String, dynamic> json) {
    return WinProbability(
      awayWinPercent: json['awayWinPercent'] as String,
      homeWinPercent: json['homeWinPercent'] as String,
      description: json['description'] as String,
    );
  }
}

class OverUnder {
  const OverUnder({
    required this.baseLine,
    required this.overPercent,
    required this.underPercent,
    this.favoredSide,
  });

  final String baseLine;
  final String overPercent;
  final String underPercent;
  final String? favoredSide;

  Map<String, dynamic> toJson() => {
        'baseLine': baseLine,
        'overPercent': overPercent,
        'underPercent': underPercent,
        'favoredSide': favoredSide,
      };

  factory OverUnder.fromJson(Map<String, dynamic> json) {
    return OverUnder(
      baseLine: json['baseLine'] as String,
      overPercent: json['overPercent'] as String,
      underPercent: json['underPercent'] as String,
      favoredSide: json['favoredSide'] as String?,
    );
  }
}

class HomeAwayRecord {
  const HomeAwayRecord({
    required this.awayWinPercent,
    required this.homeWinPercent,
  });

  final String awayWinPercent;
  final String homeWinPercent;

  Map<String, dynamic> toJson() => {
        'awayWinPercent': awayWinPercent,
        'homeWinPercent': homeWinPercent,
      };

  factory HomeAwayRecord.fromJson(Map<String, dynamic> json) {
    return HomeAwayRecord(
      awayWinPercent: json['awayWinPercent'] as String,
      homeWinPercent: json['homeWinPercent'] as String,
    );
  }
}

class WinRateData {
  const WinRateData({
    required this.awayWinPercent,
    required this.homeWinPercent,
    required this.confidence,
  });

  final String awayWinPercent;
  final String homeWinPercent;
  final String confidence;

  Map<String, dynamic> toJson() => {
        'awayWinPercent': awayWinPercent,
        'homeWinPercent': homeWinPercent,
        'confidence': confidence,
      };

  factory WinRateData.fromJson(Map<String, dynamic> json) {
    return WinRateData(
      awayWinPercent: json['awayWinPercent'] as String,
      homeWinPercent: json['homeWinPercent'] as String,
      confidence: json['confidence'] as String,
    );
  }
}

class TeamProductionData {
  const TeamProductionData({
    required this.runs,
    required this.allowed,
    required this.hits,
    required this.summary,
  });

  final GaugeStat runs;
  final GaugeStat allowed;
  final GaugeStat hits;
  final String summary;

  Map<String, dynamic> toJson() => {
        'runs': runs.toJson(),
        'allowed': allowed.toJson(),
        'hits': hits.toJson(),
        'summary': summary,
      };

  factory TeamProductionData.fromJson(Map<String, dynamic> json) {
    return TeamProductionData(
      runs: GaugeStat.fromJson(Map<String, dynamic>.from(json['runs'] as Map)),
      allowed:
          GaugeStat.fromJson(Map<String, dynamic>.from(json['allowed'] as Map)),
      hits: GaugeStat.fromJson(Map<String, dynamic>.from(json['hits'] as Map)),
      summary: json['summary'] as String,
    );
  }
}

class SeasonTeamStatsData {
  const SeasonTeamStatsData({
    required this.avg,
    required this.ops,
    required this.era,
    required this.whip,
  });

  final GaugeStat avg;
  final GaugeStat ops;
  final GaugeStat era;
  final GaugeStat whip;

  Map<String, dynamic> toJson() => {
        'avg': avg.toJson(),
        'ops': ops.toJson(),
        'era': era.toJson(),
        'whip': whip.toJson(),
      };

  factory SeasonTeamStatsData.fromJson(Map<String, dynamic> json) {
    return SeasonTeamStatsData(
      avg: GaugeStat.fromJson(Map<String, dynamic>.from(json['avg'] as Map)),
      ops: GaugeStat.fromJson(Map<String, dynamic>.from(json['ops'] as Map)),
      era: GaugeStat.fromJson(Map<String, dynamic>.from(json['era'] as Map)),
      whip: GaugeStat.fromJson(Map<String, dynamic>.from(json['whip'] as Map)),
    );
  }
}

class BaseballPremiumData {
  const BaseballPremiumData({
    required this.pickGrade,
    required this.winProbability,
    required this.overUnder,
    required this.homeAwayRecord,
    required this.winRate,
    required this.teamProduction,
    required this.seasonStats,
  });

  final String pickGrade;
  final WinProbability winProbability;
  final OverUnder overUnder;
  final HomeAwayRecord homeAwayRecord;
  final WinRateData winRate;
  final TeamProductionData teamProduction;
  final SeasonTeamStatsData seasonStats;

  Map<String, dynamic> toJson() => {
        'pickGrade': pickGrade,
        'winProbability': winProbability.toJson(),
        'overUnder': overUnder.toJson(),
        'homeAwayRecord': homeAwayRecord.toJson(),
        'winRate': winRate.toJson(),
        'teamProduction': teamProduction.toJson(),
        'seasonStats': seasonStats.toJson(),
      };

  factory BaseballPremiumData.fromJson(Map<String, dynamic> json) {
    return BaseballPremiumData(
      pickGrade: json['pickGrade'] as String,
      winProbability: WinProbability.fromJson(
        Map<String, dynamic>.from(json['winProbability'] as Map),
      ),
      overUnder: OverUnder.fromJson(
        Map<String, dynamic>.from(json['overUnder'] as Map),
      ),
      homeAwayRecord: HomeAwayRecord.fromJson(
        Map<String, dynamic>.from(json['homeAwayRecord'] as Map),
      ),
      winRate: WinRateData.fromJson(
        Map<String, dynamic>.from(json['winRate'] as Map),
      ),
      teamProduction: TeamProductionData.fromJson(
        Map<String, dynamic>.from(json['teamProduction'] as Map),
      ),
      seasonStats: SeasonTeamStatsData.fromJson(
        Map<String, dynamic>.from(json['seasonStats'] as Map),
      ),
    );
  }
}
