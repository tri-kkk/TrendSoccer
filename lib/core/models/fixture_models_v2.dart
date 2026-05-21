// Fixture schedule models for soccer and baseball match lists.

class FixtureMatch {
  const FixtureMatch({
    required this.matchId,
    this.apiMatchId,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamLogo,
    this.awayTeamLogo,
    required this.leagueCode,
    required this.leagueName,
    this.leagueLogo,
    required this.matchDate,
    required this.matchTime,
    required this.matchTimestamp,
    required this.status,
    this.homeScore,
    this.awayScore,
    required this.sport,
  });

  final int matchId;
  final int? apiMatchId;
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final String leagueCode;
  final String leagueName;
  final String? leagueLogo;
  final String matchDate;
  final String matchTime;
  final DateTime matchTimestamp;

  /// Normalized status: scheduled, live, finished, postponed, cancelled.
  final String status;
  final int? homeScore;
  final int? awayScore;
  final String sport;

  /// Key used for league grouping and chip filtering.
  String get leagueKey =>
      leagueCode.isNotEmpty
          ? leagueCode
          : (leagueName.isNotEmpty ? leagueName : 'unknown');

  factory FixtureMatch.fromJson(
    Map<String, dynamic> json, {
    required String sport,
  }) {
    final resolvedTimestamp =
        _parseFixtureDateTime(json) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final displayParts = _displayDateTimeParts(resolvedTimestamp);
    final league = _readLeagueFields(json);

    final rawStatus = _readString(json, const [
          'matchStatus',
          'match_status',
          'status',
          'state',
        ]) ??
        'NS';

    return FixtureMatch(
      matchId: _parseInt(
            json['match_id'] ?? json['matchId'] ?? json['id'] ?? json['fixtureId'],
          ) ??
          0,
      apiMatchId: _parseInt(
        json['apiMatchId'] ??
            json['api_match_id'] ??
            json['externalId'] ??
            json['external_id'],
      ),
      homeTeam:
          _readString(json, const ['home_team', 'homeTeam']) ??
              _readTeamName(json, isHome: true),
      awayTeam:
          _readString(json, const ['away_team', 'awayTeam']) ??
              _readTeamName(json, isHome: false),
      homeTeamLogo: _readString(json, const [
        'home_team_logo',
        'homeTeamLogo',
        'homeCrest',
        'homeTeamLogoUrl',
        'home_logo',
        'homeLogo',
      ]),
      awayTeamLogo: _readString(json, const [
        'away_team_logo',
        'awayTeamLogo',
        'awayCrest',
        'awayTeamLogoUrl',
        'away_logo',
        'awayLogo',
      ]),
      leagueCode: league.code,
      leagueName: league.name,
      leagueLogo: league.logo,
      matchDate: displayParts.$1,
      matchTime: displayParts.$2,
      matchTimestamp: resolvedTimestamp,
      status: normalizeMatchStatus(rawStatus),
      homeScore: _parseInt(
        json['finalScoreHome'] ??
            json['homeScore'] ??
            json['home_score'] ??
            json['homeGoals'],
      ),
      awayScore: _parseInt(
        json['finalScoreAway'] ??
            json['awayScore'] ??
            json['away_score'] ??
            json['awayGoals'],
      ),
      sport: _readString(json, const ['sport']) ?? sport,
    );
  }
}

class FixtureLeagueGroup {
  const FixtureLeagueGroup({
    required this.leagueCode,
    required this.leagueName,
    this.leagueLogo,
    required this.matches,
  });

  final String leagueCode;
  final String leagueName;
  final String? leagueLogo;
  final List<FixtureMatch> matches;
}

/// Groups matches by [FixtureMatch.leagueCode] and sorts leagues by name.
List<FixtureLeagueGroup> groupMatchesByLeague(List<FixtureMatch> matches) {
  final grouped = <String, List<FixtureMatch>>{};
  final leagueNames = <String, String>{};
  final leagueLogos = <String, String?>{};

  for (final match in matches) {
    final code = match.leagueKey;
    grouped.putIfAbsent(code, () => []).add(match);
    leagueNames[code] = match.leagueName.isNotEmpty
        ? match.leagueName
        : leagueNames[code] ?? code;
    leagueLogos[code] ??= match.leagueLogo;
  }

  final groups = grouped.entries
      .map(
        (entry) => FixtureLeagueGroup(
          leagueCode: entry.key,
          leagueName: leagueNames[entry.key] ?? entry.key,
          leagueLogo: leagueLogos[entry.key],
          matches: List<FixtureMatch>.from(entry.value),
        ),
      )
      .toList();

  groups.sort(
    (a, b) => a.leagueName.toLowerCase().compareTo(b.leagueName.toLowerCase()),
  );
  return groups;
}

/// Maps API status codes to a normalized status string.
String normalizeMatchStatus(String raw) {
  final value = raw.trim().toUpperCase();
  switch (value) {
    case 'NS':
    case 'NOT_STARTED':
    case 'SCHEDULED':
    case 'TBD':
    case 'TIMED':
      return 'scheduled';
    case '1H':
    case '2H':
    case 'HT':
    case 'ET':
    case 'BT':
    case 'P':
    case 'LIVE':
    case 'IN_PLAY':
      return 'live';
    case 'FT':
    case 'AET':
    case 'PEN':
    case 'FINISHED':
    case 'FIN':
      return 'finished';
    case 'PST':
    case 'POSTPONED':
      return 'postponed';
    case 'CANC':
    case 'ABD':
    case 'CANCELLED':
    case 'CANCELED':
      return 'cancelled';
    default:
      if (value.contains('LIVE') || value.contains('IN_PLAY')) {
        return 'live';
      }
      if (value.contains('FIN')) return 'finished';
      if (value.contains('POST')) return 'postponed';
      if (value.contains('CANC')) return 'cancelled';
      return value.isEmpty ? 'scheduled' : value.toLowerCase();
  }
}

DateTime? _parseFixtureDateTime(Map<String, dynamic> json) {
  final commence = json['commence_time'] ?? json['commenceTime'];
  if (commence != null) {
    final parsed = DateTime.tryParse(commence.toString());
    if (parsed != null) {
      return parsed.isUtc ? parsed : parsed.toUtc();
    }
  }

  final dateRaw = json['date'] ?? json['matchDate'] ?? json['match_date'];
  final timeRaw = json['time'] ?? json['matchTime'] ?? json['match_time'];
  final dateStr = dateRaw?.toString();
  final timeStr = timeRaw?.toString() ?? '00:00';
  if (dateStr == null || dateStr.isEmpty) return null;

  final cleaned = dateStr.replaceAll(RegExp(r'[.\s]+'), ' ').trim();
  final parts = cleaned.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.length >= 3) {
    final year = parts[0];
    final month = parts[1].padLeft(2, '0');
    final day = parts[2].padLeft(2, '0');
    final normalizedTime = _normalizeTimeString(timeStr);
    final iso = '$year-$month-${day}T$normalizedTime:00+09:00';
    final parsed = DateTime.tryParse(iso);
    if (parsed != null) {
      return parsed.toUtc();
    }
  }

  return _parseDateTimeFromParts(dateStr, timeStr);
}

String _normalizeTimeString(String time) {
  final trimmed = time.trim();
  if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(trimmed)) {
    final segments = trimmed.split(':');
    return '${segments[0].padLeft(2, '0')}:${segments[1].padLeft(2, '0')}';
  }
  return '00:00';
}

(String, String) _displayDateTimeParts(DateTime timestamp) {
  final local = timestamp.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return ('$month.$day', '$hour:$minute');
}

String _readTeamName(Map<String, dynamic> json, {required bool isHome}) {
  if (isHome) {
    final nested = _readMap(json, const ['home']);
    final nestedName = nested == null
        ? null
        : _readString(nested, const ['name', 'teamName', 'team_name']);
    return nestedName ??
        _readString(json, const [
          'homeTeamName',
          'home_team_name',
          'home',
        ]) ??
        '';
  }

  final nested = _readMap(json, const ['away']);
  final nestedName = nested == null
      ? null
      : _readString(nested, const ['name', 'teamName', 'team_name']);
  return nestedName ??
      _readString(json, const [
        'awayTeamName',
        'away_team_name',
        'away',
      ]) ??
      '';
}

DateTime? _parseDateTimeFromParts(String? date, String? time) {
  if (date == null || date.isEmpty) return null;
  final combined = (time == null || time.isEmpty) ? date : '$date $time';
  final parsed = DateTime.tryParse(combined);
  if (parsed == null) return null;
  return parsed.isUtc ? parsed : parsed.toUtc();
}

({String code, String name, String? logo}) _readLeagueFields(
  Map<String, dynamic> json,
) {
  final leagueValue = json['league'];
  if (leagueValue is String && leagueValue.isNotEmpty) {
    return (
      code: _readString(json, const ['leagueCode', 'league_code', 'code']) ?? '',
      name: leagueValue,
      logo: _readString(json, const ['leagueLogo', 'league_logo']),
    );
  }

  final leagueMap = _readMap(json, const [
    'league',
    'leagueInfo',
    'league_info',
    'competition',
  ]);

  if (leagueMap != null) {
    return (
      code: _readString(leagueMap, const [
            'code',
            'leagueCode',
            'league_code',
            'id',
            'leagueId',
            'league_id',
          ]) ??
          '',
      name: _readString(leagueMap, const [
            'name',
            'leagueName',
            'league_name',
          ]) ??
          '',
      logo: _readString(leagueMap, const [
        'logo',
        'leagueLogo',
        'league_logo',
        'icon',
        'image',
      ]),
    );
  }

  return (
    code: _readString(json, const [
          'league_code',
          'leagueCode',
          'code',
          'leagueId',
          'league_id',
        ]) ??
        '',
    name: _readString(json, const [
          'leagueName',
          'leagueNameEn',
          'league_name',
          'competition',
        ]) ??
        '',
    logo: _readString(json, const [
      'leagueLogo',
      'league_logo',
      'leagueIcon',
      'league_icon',
      'icon',
    ]),
  );
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
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

Map<String, dynamic>? _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
}
