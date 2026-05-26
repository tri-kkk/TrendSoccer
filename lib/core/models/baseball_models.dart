class BaseballAnalysisCard {
  const BaseballAnalysisCard({
    required this.matchId,
    this.dbId,
    required this.league,
    required this.homeTeam,
    this.homeTeamKo,
    this.homeTeamLogo,
    required this.awayTeam,
    this.awayTeamKo,
    this.awayTeamLogo,
    required this.matchDate,
    required this.matchTime,
    required this.matchTimestamp,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.homePitcher,
    this.homePitcherKo,
    this.awayPitcher,
    this.awayPitcherKo,
    this.hasPitcherData = false,
    this.aiPick,
    this.aiPickConfidence,
    this.odds,
  });

  final int matchId; // api_match_id from list/detail API (primary ID for all API calls)
  final int? dbId; // legacy internal DB id — kept for backward compatibility only
  final String league;
  final String homeTeam;
  final String? homeTeamKo;
  final String? homeTeamLogo;
  final String awayTeam;
  final String? awayTeamKo;
  final String? awayTeamLogo;
  final String matchDate;
  final String matchTime;
  final DateTime matchTimestamp;
  final String status;
  final int? homeScore;
  final int? awayScore;
  final String? homePitcher;
  final String? homePitcherKo;
  final String? awayPitcher;
  final String? awayPitcherKo;
  final bool hasPitcherData;
  final String? aiPick;
  final String? aiPickConfidence;
  final BaseballOdds? odds;

  String get homeDisplayTeam =>
      homeTeamKo?.trim().isNotEmpty == true ? homeTeamKo!.trim() : homeTeam;

  String get awayDisplayTeam =>
      awayTeamKo?.trim().isNotEmpty == true ? awayTeamKo!.trim() : awayTeam;

  String get homeDisplayPitcher {
    final ko = homePitcherKo?.trim();
    if (ko != null && ko.isNotEmpty) return ko;
    return homePitcher?.trim() ?? '';
  }

  String get awayDisplayPitcher {
    final ko = awayPitcherKo?.trim();
    if (ko != null && ko.isNotEmpty) return ko;
    return awayPitcher?.trim() ?? '';
  }

  /// Primary match id for detail / analysis API routes — same as [matchId] (api_match_id).
  int get detailMatchId => matchId;

  factory BaseballAnalysisCard.fromJson(Map<String, dynamic> json) {
    final timestamp = _parseTimestamp(json) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final dateRaw = _readString(json, const ['date', 'matchDate', 'match_date']);
    final timeRaw = _readString(json, const ['time', 'matchTime', 'match_time']);
    final matchDate = dateRaw ?? _dateFromTimestamp(timestamp);
    final matchTime = timeRaw ?? _timeFromTimestamp(timestamp);

    return BaseballAnalysisCard(
      matchId: _parseInt(json['id'] ?? json['matchId'] ?? json['match_id']) ?? 0,
      dbId: (json['dbId'] as num?)?.toInt() ?? _parseInt(json['db_id']),
      league: _readString(json, const ['league', 'leagueCode', 'league_code']) ??
          '',
      homeTeam:
          _readString(json, const ['homeTeam', 'home_team', 'home']) ?? '',
      homeTeamKo: _readString(json, const ['homeTeamKo', 'home_team_ko']),
      homeTeamLogo: _nonEmptyOrNull(
        json['homeLogo'] ??
            json['home_logo'] ??
            json['homeTeamLogo'] ??
            json['home_team_logo'],
      ),
      awayTeam:
          _readString(json, const ['awayTeam', 'away_team', 'away']) ?? '',
      awayTeamKo: _readString(json, const ['awayTeamKo', 'away_team_ko']),
      awayTeamLogo: _nonEmptyOrNull(
        json['awayLogo'] ??
            json['away_logo'] ??
            json['awayTeamLogo'] ??
            json['away_team_logo'],
      ),
      matchDate: matchDate,
      matchTime: matchTime,
      matchTimestamp: timestamp,
      status: _readString(json, const ['status', 'matchStatus', 'match_status']) ??
          'scheduled',
      homeScore: _parseInt(
        json['homeScore'] ?? json['home_score'] ?? json['finalScoreHome'],
      ),
      awayScore: _parseInt(
        json['awayScore'] ?? json['away_score'] ?? json['finalScoreAway'],
      ),
      homePitcher:
          _readString(json, const ['homePitcher', 'home_pitcher']),
      homePitcherKo:
          _readString(json, const ['homePitcherKo', 'home_pitcher_ko']),
      awayPitcher:
          _readString(json, const ['awayPitcher', 'away_pitcher']),
      awayPitcherKo:
          _readString(json, const ['awayPitcherKo', 'away_pitcher_ko']),
      hasPitcherData: json['hasPitcherData'] == true ||
          json['has_pitcher_data'] == true,
      aiPick: _readString(json, const ['aiPick', 'ai_pick']),
      aiPickConfidence: _readString(json, const [
        'aiPickConfidence',
        'ai_pick_confidence',
      ]),
      odds: BaseballOdds.fromJson(
        json['odds'] is Map
            ? Map<String, dynamic>.from(json['odds'] as Map)
            : null,
      ),
    );
  }
}

class BaseballOdds {
  const BaseballOdds({
    this.homeWinProb,
    this.awayWinProb,
    this.homeWinOdds,
    this.awayWinOdds,
    this.overUnderLine,
    this.overOdds,
    this.underOdds,
    this.ouLines,
  });

  final double? homeWinProb;
  final double? awayWinProb;
  final double? homeWinOdds;
  final double? awayWinOdds;
  final double? overUnderLine;
  final double? overOdds;
  final double? underOdds;
  final List<OULine>? ouLines;

  factory BaseballOdds.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BaseballOdds();

    List<OULine>? ouLines;
    final rawLines = json['ouLines'] ?? json['ou_lines'];
    if (rawLines is List) {
      ouLines = rawLines
          .whereType<Map>()
          .map((item) => OULine.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return BaseballOdds(
      homeWinProb: _parseDouble(
        json['homeWinProb'] ?? json['home_win_prob'],
      ),
      awayWinProb: _parseDouble(
        json['awayWinProb'] ?? json['away_win_prob'],
      ),
      homeWinOdds: _parseDouble(
        json['homeWinOdds'] ?? json['home_win_odds'],
      ),
      awayWinOdds: _parseDouble(
        json['awayWinOdds'] ?? json['away_win_odds'],
      ),
      overUnderLine: _parseDouble(
        json['overUnderLine'] ?? json['over_under_line'] ?? json['ouLine'],
      ),
      overOdds: _parseDouble(json['overOdds'] ?? json['over_odds']),
      underOdds: _parseDouble(json['underOdds'] ?? json['under_odds']),
      ouLines: ouLines?.isEmpty == true ? null : ouLines,
    );
  }
}

class OULine {
  const OULine({
    required this.line,
    required this.over,
    required this.under,
  });

  final double line;
  final double over;
  final double under;

  factory OULine.fromJson(Map<String, dynamic> json) {
    return OULine(
      line: _parseDouble(json['line']) ?? 0,
      over: _parseDouble(json['over']) ?? 0,
      under: _parseDouble(json['under']) ?? 0,
    );
  }
}

DateTime? _parseTimestamp(Map<String, dynamic> json) {
  final raw = json['timestamp'] ??
      json['matchTimestamp'] ??
      json['match_timestamp'] ??
      json['commence_time'];
  if (raw == null) return null;

  if (raw is DateTime) {
    return raw.isUtc ? raw : raw.toUtc();
  }

  final parsed = DateTime.tryParse(raw.toString());
  if (parsed == null) return null;
  return parsed.isUtc ? parsed : parsed.toUtc();
}

String _dateFromTimestamp(DateTime timestamp) {
  final local = timestamp.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String _timeFromTimestamp(DateTime timestamp) {
  final local = timestamp.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
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
    if (value is num) return value.toString();
  }
  return null;
}

String? _nonEmptyOrNull(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  return str.isEmpty ? null : str;
}
