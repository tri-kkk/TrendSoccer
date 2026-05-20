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

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

Map<String, dynamic>? _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
}

class TeamInfo {
  const TeamInfo({
    required this.name,
    this.logo,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      name: _readString(json, const ['name', 'teamName', 'team_name']) ?? '',
      logo: _readString(json, const ['logo', 'logoUrl', 'logo_url', 'image']),
    );
  }

  final String name;
  final String? logo;
}

class LeagueInfo {
  const LeagueInfo({
    required this.id,
    required this.name,
    this.code,
    this.icon,
    this.country,
  });

  factory LeagueInfo.fromJson(Map<String, dynamic> json) {
    return LeagueInfo(
      id: _parseInt(json['id'] ?? json['leagueId'] ?? json['league_id']) ?? 0,
      name: _readString(json, const ['name', 'leagueName', 'league_name']) ??
          '',
      code: _readString(json, const ['code', 'leagueCode', 'league_code']),
      icon: _readString(json, const ['icon', 'iconUrl', 'icon_url']),
      country:
          _readString(json, const ['country', 'countryName', 'country_name']),
    );
  }

  final int id;
  final String name;
  final String? code;
  final String? icon;
  final String? country;
}

class ScoreInfo {
  const ScoreInfo({
    this.home,
    this.away,
  });

  factory ScoreInfo.fromJson(Map<String, dynamic> json) {
    final homeScore = json['home'] ?? json['homeScore'] ?? json['home_score'];
    final awayScore = json['away'] ?? json['awayScore'] ?? json['away_score'];

    return ScoreInfo(
      home: _parseInt(homeScore),
      away: _parseInt(awayScore),
    );
  }

  final int? home;
  final int? away;
}

class SoccerOdds {
  const SoccerOdds({
    this.home,
    this.draw,
    this.away,
  });

  factory SoccerOdds.fromJson(Map<String, dynamic> json) {
    return SoccerOdds(
      home: _parseDouble(json['home'] ?? json['homeOdds'] ?? json['home_odds']),
      draw: _parseDouble(json['draw'] ?? json['drawOdds'] ?? json['draw_odds']),
      away: _parseDouble(json['away'] ?? json['awayOdds'] ?? json['away_odds']),
    );
  }

  final double? home;
  final double? draw;
  final double? away;
}

class RecommendationInfo {
  const RecommendationInfo({
    this.grade,
    this.pick,
    this.reasoning,
  });

  factory RecommendationInfo.fromJson(Map<String, dynamic> json) {
    return RecommendationInfo(
      grade: _readString(json, const ['grade']),
      pick: _readString(json, const ['pick', 'selection']),
      reasoning: _readString(
        json,
        const ['reasoning', 'reason', 'summary'],
      ),
    );
  }

  final String? grade;
  final String? pick;
  final String? reasoning;
}

class SoccerPrediction {
  const SoccerPrediction({
    this.direction,
    this.confidence,
    this.recommendation,
  });

  factory SoccerPrediction.fromJson(Map<String, dynamic> json) {
    final recommendationJson = _readMap(
      json,
      const ['recommendation', 'recommendationInfo', 'recommendation_info'],
    );

    return SoccerPrediction(
      direction: _readString(
        json,
        const ['direction', 'prediction', 'pickDirection', 'pick_direction'],
      ),
      confidence: _parseDouble(
        json['confidence'] ?? json['confidenceScore'] ?? json['confidence_score'],
      ),
      recommendation: recommendationJson == null
          ? null
          : RecommendationInfo.fromJson(recommendationJson),
    );
  }

  final String? direction;
  final double? confidence;
  final RecommendationInfo? recommendation;
}

class SoccerMatch {
  const SoccerMatch({
    required this.matchId,
    required this.apiMatchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.matchDate,
    required this.matchTime,
    this.matchTimestamp,
    required this.status,
    this.score,
  });

  factory SoccerMatch.fromJson(Map<String, dynamic> json) {
    final homeJson = _readMap(
      json,
      const ['homeTeam', 'home_team', 'home'],
    );
    final awayJson = _readMap(
      json,
      const ['awayTeam', 'away_team', 'away'],
    );
    final leagueJson = _readMap(
      json,
      const ['league', 'leagueInfo', 'league_info'],
    );
    final scoreJson = _readMap(json, const ['score', 'scores', 'result']);

    final matchId = _parseInt(
          json['matchId'] ?? json['match_id'] ?? json['id'],
        ) ??
        0;
    final apiMatchId = _parseInt(
          json['apiMatchId'] ??
              json['api_match_id'] ??
              json['fixtureId'] ??
              json['fixture_id'],
        ) ??
        matchId;

    final matchDate = _readString(
          json,
          const ['matchDate', 'match_date', 'date'],
        ) ??
        '';
    final matchTime = _readString(
          json,
          const ['matchTime', 'match_time', 'time', 'kickoffTime', 'kickoff_time'],
        ) ??
        '';

    return SoccerMatch(
      matchId: matchId,
      apiMatchId: apiMatchId,
      homeTeam: homeJson == null
          ? const TeamInfo(name: '')
          : TeamInfo.fromJson(homeJson),
      awayTeam: awayJson == null
          ? const TeamInfo(name: '')
          : TeamInfo.fromJson(awayJson),
      league: leagueJson == null
          ? const LeagueInfo(id: 0, name: '')
          : LeagueInfo.fromJson(leagueJson),
      matchDate: matchDate,
      matchTime: matchTime,
      matchTimestamp: _parseDateTime(
        json['matchTimestamp'] ??
            json['match_timestamp'] ??
            json['timestamp'] ??
            json['kickoff'],
      ),
      status: _normalizeStatus(
        _readString(json, const ['status', 'matchStatus', 'match_status']),
      ),
      score: scoreJson == null ? null : ScoreInfo.fromJson(scoreJson),
    );
  }

  static String _normalizeStatus(String? raw) {
    if (raw == null || raw.isEmpty) return 'scheduled';
    final value = raw.toLowerCase();
    if (value.contains('live') || value == 'in_play' || value == 'inplay') {
      return 'live';
    }
    if (value.contains('finish') ||
        value == 'ft' ||
        value == 'completed' ||
        value == 'ended') {
      return 'finished';
    }
    if (value.contains('postpon') || value.contains('cancel')) {
      return 'postponed';
    }
    return 'scheduled';
  }

  final int matchId;
  final int apiMatchId;
  final TeamInfo homeTeam;
  final TeamInfo awayTeam;
  final LeagueInfo league;
  final String matchDate;
  final String matchTime;
  final DateTime? matchTimestamp;
  final String status;
  final ScoreInfo? score;
}

class SoccerAnalysisCard {
  const SoccerAnalysisCard({
    required this.match,
    this.odds,
    this.grade,
    this.prediction,
  });

  factory SoccerAnalysisCard.fromJson(Map<String, dynamic> json) {
    final matchJson = _readMap(json, const ['match', 'fixture', 'game']) ?? json;
    final oddsJson = _readMap(json, const ['odds', 'matchOdds', 'match_odds']);
    final predictionJson = _readMap(
      json,
      const ['prediction', 'analysis', 'pick'],
    );

    return SoccerAnalysisCard(
      match: SoccerMatch.fromJson(matchJson),
      odds: oddsJson == null ? null : SoccerOdds.fromJson(oddsJson),
      grade: _readString(json, const ['grade', 'pickGrade', 'pick_grade']),
      prediction: predictionJson == null
          ? null
          : SoccerPrediction.fromJson(predictionJson),
    );
  }

  SoccerAnalysisCard copyWith({
    SoccerMatch? match,
    SoccerOdds? odds,
    String? grade,
    SoccerPrediction? prediction,
  }) {
    return SoccerAnalysisCard(
      match: match ?? this.match,
      odds: odds ?? this.odds,
      grade: grade ?? this.grade,
      prediction: prediction ?? this.prediction,
    );
  }

  final SoccerMatch match;
  final SoccerOdds? odds;
  final String? grade;
  final SoccerPrediction? prediction;
}
