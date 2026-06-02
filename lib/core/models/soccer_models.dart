import 'package:flutter/foundation.dart';

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

double? _flatPredictionConfidence(Map<String, dynamic> json) {
  final home = _parseDouble(json['home_probability']);
  final draw = _parseDouble(json['draw_probability']);
  final away = _parseDouble(json['away_probability']);
  final winner = json['predicted_winner']?.toString().toLowerCase();
  if (winner == 'home') return home;
  if (winner == 'draw') return draw;
  if (winner == 'away') return away;

  final probabilities = [home, draw, away].whereType<double>().toList();
  if (probabilities.isEmpty) return null;
  return probabilities.reduce((a, b) => a > b ? a : b);
}

(String, String) _dateTimePartsFromTimestamp(DateTime? timestamp) {
  if (timestamp == null) return ('', '');
  final local = timestamp.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return ('${local.year}-$month-$day', '$hour:$minute');
}

class TeamInfo {
  const TeamInfo({
    required this.name,
    this.logo,
    this.id,
  });

  factory TeamInfo.fromJson(dynamic json) {
    if (json is String) {
      return TeamInfo(name: json, logo: null);
    }
    if (json is Map) {
      final map =
          json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json);
      return TeamInfo(
        name: _readString(map, const ['name', 'teamName', 'team_name']) ?? '',
        logo: _readString(map, const ['logo', 'logoUrl', 'logo_url', 'image']),
        id: _parseInt(
          map['id'] ?? map['teamId'] ?? map['team_id'],
        ),
      );
    }
    return const TeamInfo(name: '');
  }

  final String name;
  final String? logo;
  final int? id;
}

class LeagueInfo {
  const LeagueInfo({
    required this.id,
    required this.name,
    this.nameEn,
    this.code,
    this.icon,
    this.country,
  });

  factory LeagueInfo.fromJson(Map<String, dynamic> json) {
    return LeagueInfo(
      id: _parseInt(
            json['id'] ??
                json['leagueId'] ??
                json['league_id'] ??
                json['leaguePriority'],
          ) ??
          0,
      name: _readString(
            json,
            const ['name', 'leagueName', 'league_name'],
          ) ??
          '',
      nameEn: _readString(
        json,
        const ['leagueNameEn', 'league_name_en', 'nameEn'],
      ),
      code: _readString(json, const ['code', 'leagueCode', 'league_code']),
      icon: _readString(json, const ['icon', 'iconUrl', 'icon_url', 'leagueLogo']),
      country:
          _readString(json, const ['country', 'countryName', 'country_name']),
    );
  }

  final int id;
  final String name;
  final String? nameEn;
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
      home: _parseDouble(
        json['home_odds'] ?? json['home'] ?? json['homeOdds'],
      ),
      draw: _parseDouble(
        json['draw_odds'] ?? json['draw'] ?? json['drawOdds'],
      ),
      away: _parseDouble(
        json['away_odds'] ?? json['away'] ?? json['awayOdds'],
      ),
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
    final flatDirection = json['predicted_winner']?.toString();
    final flatConfidence = _flatPredictionConfidence(json);

    return SoccerPrediction(
      direction: _readString(
            json,
            const [
              'direction',
              'prediction',
              'pickDirection',
              'pick_direction',
              'predicted_winner',
            ],
          ) ??
          flatDirection,
      confidence: _parseDouble(
            json['confidence'] ??
                json['confidenceScore'] ??
                json['confidence_score'],
          ) ??
          flatConfidence,
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
    debugPrint('[SOCCER] SoccerMatch.fromJson keys: ${json.keys.toList()}');
    final homeValue = json['homeTeam'] ?? json['home_team'] ?? json['home'];
    final awayValue = json['awayTeam'] ?? json['away_team'] ?? json['away'];
    final isFlat = homeValue is String || awayValue is String;

    if (isFlat) {
      debugPrint(
        '[SOCCER] Field mapping: flat format — home_team/away_team strings, leagueName, commence_time',
      );
      final matchId =
          _parseInt(json['match_id'] ?? json['matchId'] ?? json['id']) ?? 0;
      final matchTimestamp = _parseDateTime(json['commence_time']) ??
          _parseDateTime(
            json['matchTimestamp'] ??
                json['match_timestamp'] ??
                json['timestamp'] ??
                json['kickoff'],
          );
      final (derivedDate, derivedTime) =
          _dateTimePartsFromTimestamp(matchTimestamp);
      final homeScore = _parseInt(json['finalScoreHome']);
      final awayScore = _parseInt(json['finalScoreAway']);

      return SoccerMatch(
        matchId: matchId,
        apiMatchId: matchId,
        homeTeam: TeamInfo(
          name: homeValue is String ? homeValue : '',
          logo: _readString(
            json,
            const ['home_team_logo', 'homeTeamLogo', 'homeLogo'],
          ),
          id: _parseInt(json['home_team_id'] ?? json['homeTeamId']),
        ),
        awayTeam: TeamInfo(
          name: awayValue is String ? awayValue : '',
          logo: _readString(
            json,
            const ['away_team_logo', 'awayTeamLogo', 'awayLogo'],
          ),
          id: _parseInt(json['away_team_id'] ?? json['awayTeamId']),
        ),
        league: LeagueInfo(
          id: _parseInt(json['leaguePriority'] ?? json['league_id']) ?? 0,
          name: _readString(
                json,
                const ['leagueName', 'league_name', 'name'],
              ) ??
              '',
          nameEn: _readString(
            json,
            const ['leagueNameEn', 'league_name_en'],
          ),
          code: _readString(json, const ['league_code', 'leagueCode', 'code']),
          icon: _readString(json, const ['leagueLogo', 'league_logo', 'icon']),
        ),
        matchDate: _readString(
              json,
              const ['matchDate', 'match_date', 'date'],
            ) ??
            derivedDate,
        matchTime: _readString(
              json,
              const [
                'matchTime',
                'match_time',
                'time',
                'kickoffTime',
                'kickoff_time',
              ],
            ) ??
            derivedTime,
        matchTimestamp: matchTimestamp,
        status: _normalizeStatus(
          _readString(json, const ['matchStatus', 'match_status', 'status']),
        ),
        score: homeScore != null || awayScore != null
            ? ScoreInfo(home: homeScore, away: awayScore)
            : null,
      );
    }

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
    debugPrint(
      '[SOCCER] Field mapping: homeTeam<=homeTeam|home_team|home (found: ${homeJson != null}), awayTeam<=awayTeam|away_team|away (found: ${awayJson != null}), league<=league|leagueInfo|league_info (found: ${leagueJson != null})',
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
          ? (homeValue != null
              ? TeamInfo.fromJson(homeValue)
              : const TeamInfo(name: ''))
          : TeamInfo.fromJson(homeJson),
      awayTeam: awayJson == null
          ? (awayValue != null
              ? TeamInfo.fromJson(awayValue)
              : const TeamInfo(name: ''))
          : TeamInfo.fromJson(awayJson),
      league: leagueJson == null
          ? const LeagueInfo(id: 0, name: '')
          : LeagueInfo.fromJson(leagueJson),
      matchDate: matchDate,
      matchTime: matchTime,
      matchTimestamp: _parseDateTime(
        json['commence_time'] ??
            json['matchTimestamp'] ??
            json['match_timestamp'] ??
            json['timestamp'] ??
            json['kickoff'],
      ),
      status: _normalizeStatus(
        _readString(json, const ['matchStatus', 'match_status', 'status']),
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
    debugPrint('[SOCCER] fromJson keys: ${json.keys.toList()}');
    debugPrint(
      '[SOCCER] Field mapping: match<=match|fixture|game|root; odds<=odds|matchOdds|match_odds|flat home_odds; grade<=grade|pickGrade|pick_grade; prediction<=prediction|analysis|pick|flat predicted_winner',
    );

    final nestedMatchJson = _readMap(json, const ['match', 'fixture', 'game']);
    final matchJson = nestedMatchJson ?? json;

    final oddsJson = _readMap(json, const ['odds', 'matchOdds', 'match_odds']);
    final hasFlatOdds = json.containsKey('home_odds') ||
        json.containsKey('draw_odds') ||
        json.containsKey('away_odds');

    final predictionJson = _readMap(
      json,
      const ['prediction', 'analysis', 'pick'],
    );
    final hasFlatPrediction = json.containsKey('predicted_winner') ||
        json.containsKey('home_probability') ||
        json.containsKey('draw_probability') ||
        json.containsKey('away_probability');

    return SoccerAnalysisCard(
      match: SoccerMatch.fromJson(matchJson),
      odds: oddsJson != null
          ? SoccerOdds.fromJson(oddsJson)
          : hasFlatOdds
              ? SoccerOdds.fromJson(json)
              : null,
      grade: _readString(json, const ['grade', 'pickGrade', 'pick_grade']),
      prediction: predictionJson != null
          ? SoccerPrediction.fromJson(predictionJson)
          : hasFlatPrediction
              ? SoccerPrediction.fromJson(json)
              : null,
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
