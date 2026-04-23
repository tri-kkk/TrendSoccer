/// Baseball match report payload and nested DTOs with JSON serialization.
class PitcherData {
  const PitcherData({
    required this.name,
    required this.team,
    required this.handedness,
    required this.currentSeason,
    required this.era,
    required this.whip,
    required this.k9,
    required this.wl,
    required this.ip,
    required this.k,
    required this.positiveComments,
    required this.negativeComments,
    this.imageUrl,
    this.previousSeasonEra,
    this.previousSeasonWhip,
    this.previousSeasonK,
  });

  final String name;
  final String team;
  final String handedness;
  final bool currentSeason;

  /// Headshot URL (MLB reports). Non-MLB leagues omit this in the UI.
  final String? imageUrl;
  final double era;
  final double whip;
  final double k9;
  final String wl;
  final double ip;
  final int k;
  final List<String> positiveComments;
  final List<String> negativeComments;
  final double? previousSeasonEra;
  final double? previousSeasonWhip;
  final int? previousSeasonK;

  Map<String, dynamic> toJson() => {
        'name': name,
        'team': team,
        'handedness': handedness,
        'currentSeason': currentSeason,
        'era': era,
        'whip': whip,
        'k9': k9,
        'wl': wl,
        'ip': ip,
        'k': k,
        'positiveComments': positiveComments,
        'negativeComments': negativeComments,
        'imageUrl': imageUrl,
        'previousSeasonEra': previousSeasonEra,
        'previousSeasonWhip': previousSeasonWhip,
        'previousSeasonK': previousSeasonK,
      };

  factory PitcherData.fromJson(Map<String, dynamic> json) {
    return PitcherData(
      name: json['name'] as String,
      team: json['team'] as String,
      handedness: json['handedness'] as String,
      currentSeason: json['currentSeason'] as bool,
      era: (json['era'] as num).toDouble(),
      whip: (json['whip'] as num).toDouble(),
      k9: (json['k9'] as num).toDouble(),
      wl: json['wl'] as String,
      ip: (json['ip'] as num).toDouble(),
      k: (json['k'] as num).toInt(),
      positiveComments: (json['positiveComments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      negativeComments: (json['negativeComments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      previousSeasonEra: json['previousSeasonEra'] != null
          ? (json['previousSeasonEra'] as num).toDouble()
          : null,
      previousSeasonWhip: json['previousSeasonWhip'] != null
          ? (json['previousSeasonWhip'] as num).toDouble()
          : null,
      previousSeasonK: json['previousSeasonK'] != null
          ? (json['previousSeasonK'] as num).toInt()
          : null,
    );
  }
}

class H2HRecord {
  const H2HRecord({
    required this.date,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayScore,
    required this.homeScore,
    this.winner,
  });

  final String date;
  final String awayTeam;
  final String homeTeam;
  final int awayScore;
  final int homeScore;
  final String? winner;

  Map<String, dynamic> toJson() => {
        'date': date,
        'awayTeam': awayTeam,
        'homeTeam': homeTeam,
        'awayScore': awayScore,
        'homeScore': homeScore,
        'winner': winner,
      };

  factory H2HRecord.fromJson(Map<String, dynamic> json) {
    return H2HRecord(
      date: json['date'] as String,
      awayTeam: json['awayTeam'] as String,
      homeTeam: json['homeTeam'] as String,
      awayScore: (json['awayScore'] as num).toInt(),
      homeScore: (json['homeScore'] as num).toInt(),
      winner: json['winner'] as String?,
    );
  }
}

class OddsLineData {
  const OddsLineData({
    required this.line,
    required this.isBaseLine,
    required this.overOdds,
    required this.underOdds,
  });

  final String line;
  final bool isBaseLine;
  final String overOdds;
  final String underOdds;

  Map<String, dynamic> toJson() => {
        'line': line,
        'isBaseLine': isBaseLine,
        'overOdds': overOdds,
        'underOdds': underOdds,
      };

  factory OddsLineData.fromJson(Map<String, dynamic> json) {
    return OddsLineData(
      line: json['line'] as String,
      isBaseLine: json['isBaseLine'] as bool,
      overOdds: json['overOdds'] as String,
      underOdds: json['underOdds'] as String,
    );
  }
}

class BaseballMatchReport {
  const BaseballMatchReport({
    required this.matchId,
    required this.leagueId,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDateTime,
    required this.awayPitcher,
    required this.homePitcher,
    required this.pitcherAnalysis,
    required this.h2hRecords,
    required this.awayWinOdds,
    required this.homeWinOdds,
    required this.oddsLines,
  });

  final String matchId;
  final String leagueId;
  final String homeTeam;
  final String awayTeam;
  final DateTime matchDateTime;
  final PitcherData awayPitcher;
  final PitcherData homePitcher;
  final List<String> pitcherAnalysis;
  final List<H2HRecord> h2hRecords;
  final String awayWinOdds;
  final String homeWinOdds;
  final List<OddsLineData> oddsLines;

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'leagueId': leagueId,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'matchDateTime': matchDateTime.toIso8601String(),
        'awayPitcher': awayPitcher.toJson(),
        'homePitcher': homePitcher.toJson(),
        'pitcherAnalysis': pitcherAnalysis,
        'h2hRecords': h2hRecords.map((e) => e.toJson()).toList(),
        'awayWinOdds': awayWinOdds,
        'homeWinOdds': homeWinOdds,
        'oddsLines': oddsLines.map((e) => e.toJson()).toList(),
      };

  factory BaseballMatchReport.fromJson(Map<String, dynamic> json) {
    return BaseballMatchReport(
      matchId: json['matchId'] as String,
      leagueId: json['leagueId'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      matchDateTime: DateTime.parse(json['matchDateTime'] as String),
      awayPitcher: PitcherData.fromJson(
        Map<String, dynamic>.from(json['awayPitcher'] as Map),
      ),
      homePitcher: PitcherData.fromJson(
        Map<String, dynamic>.from(json['homePitcher'] as Map),
      ),
      pitcherAnalysis: (json['pitcherAnalysis'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      h2hRecords: (json['h2hRecords'] as List<dynamic>)
          .map((e) => H2HRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      awayWinOdds: json['awayWinOdds'] as String,
      homeWinOdds: json['homeWinOdds'] as String,
      oddsLines: (json['oddsLines'] as List<dynamic>)
          .map(
            (e) => OddsLineData.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }
}
