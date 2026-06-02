import 'package:flutter/foundation.dart';

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
    required this.rawStatus,
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

  /// Normalized status: scheduled, live, finished, postponed, cancelled, interrupted.
  final String status;

  /// Original API status code (e.g. IN5, FT, NS).
  final String rawStatus;
  final int? homeScore;
  final int? awayScore;
  final String sport;

  /// Key used for league grouping and chip filtering.
  String get leagueKey =>
      leagueCode.isNotEmpty
          ? leagueCode
          : (leagueName.isNotEmpty ? leagueName : 'unknown');

  FixtureMatch copyWithLive(LiveMatchData live) {
    final raw = live.status.trim().toUpperCase();
    return FixtureMatch(
      matchId: matchId,
      apiMatchId: apiMatchId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamLogo: homeTeamLogo,
      awayTeamLogo: awayTeamLogo,
      leagueCode: live.leagueCode?.isNotEmpty == true ? live.leagueCode! : leagueCode,
      leagueName: leagueName,
      leagueLogo: leagueLogo,
      matchDate: matchDate,
      matchTime: matchTime,
      matchTimestamp: matchTimestamp,
      status: normalizeMatchStatus(raw),
      rawStatus: raw,
      homeScore: live.homeScore,
      awayScore: live.awayScore,
      sport: sport,
    );
  }

  factory FixtureMatch.fromJson(
    Map<String, dynamic> json, {
    required String sport,
    int? statusDebugIndex,
  }) {
    final resolvedTimestamp =
        _parseFixtureDateTime(json) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final displayParts = _displayDateTimeParts(resolvedTimestamp);
    final league = _readLeagueFields(json);

    final statusStr = _readString(json, const [
      'matchStatus',
      'match_status',
      'status',
      'state',
    ]);
    final rawStatus = (statusStr ?? 'NS').trim().toUpperCase();
    final normalizedStatus = normalizeMatchStatus(rawStatus);

    if (statusDebugIndex != null && statusDebugIndex < 5) {
      debugPrint(
        '[FIXTURE] status fields: status=${json['status']}, matchStatus=${json['matchStatus']}',
      );
      debugPrint(
        '[FIXTURE] Match status raw: "${statusStr ?? ''}" → normalized: "$normalizedStatus"',
      );
    }

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
      homeTeamLogo: _nonEmptyOrNull(
        json['home_team_logo'] ??
            json['home_crest'] ??
            json['homeCrest'] ??
            json['homeTeamLogo'] ??
            json['homeTeamLogoUrl'] ??
            json['home_logo'] ??
            json['homeLogo'],
      ),
      awayTeamLogo: _nonEmptyOrNull(
        json['away_team_logo'] ??
            json['away_crest'] ??
            json['awayCrest'] ??
            json['awayTeamLogo'] ??
            json['awayTeamLogoUrl'] ??
            json['away_logo'] ??
            json['awayLogo'],
      ),
      leagueCode: league.code,
      leagueName: league.name,
      leagueLogo: _nonEmptyOrNull(
        json['leagueLogo'] ?? json['league_logo'] ?? league.logo,
      ),
      matchDate: displayParts.$1,
      matchTime: displayParts.$2,
      matchTimestamp: resolvedTimestamp,
      status: normalizedStatus,
      rawStatus: rawStatus,
      homeScore: _parseInt(
        json['finalScoreHome'] ??
            json['final_score_home'] ??
            json['homeScore'] ??
            json['home_score'] ??
            json['homeGoals'],
      ),
      awayScore: _parseInt(
        json['finalScoreAway'] ??
            json['final_score_away'] ??
            json['awayScore'] ??
            json['away_score'] ??
            json['awayGoals'],
      ),
      sport: _readString(json, const ['sport']) ?? sport,
    );
  }
}

class LiveMatchData {
  const LiveMatchData({
    required this.matchId,
    required this.status,
    required this.statusLong,
    required this.elapsed,
    required this.homeScore,
    required this.awayScore,
    this.halftimeHomeScore,
    this.halftimeAwayScore,
    this.leagueCode,
  });

  final String matchId;
  final String status;
  final String statusLong;
  final int elapsed;
  final int homeScore;
  final int awayScore;
  final int? halftimeHomeScore;
  final int? halftimeAwayScore;
  final String? leagueCode;

  factory LiveMatchData.fromJson(Map<String, dynamic> json) {
    return LiveMatchData(
      matchId: (json['id'] ?? json['fixtureId']).toString(),
      status: json['status']?.toString() ?? '',
      statusLong: json['statusLong']?.toString() ?? '',
      elapsed: (json['elapsed'] as num?)?.toInt() ?? 0,
      homeScore: (json['homeScore'] as num?)?.toInt() ?? 0,
      awayScore: (json['awayScore'] as num?)?.toInt() ?? 0,
      halftimeHomeScore: (json['halftimeHomeScore'] as num?)?.toInt(),
      halftimeAwayScore: (json['halftimeAwayScore'] as num?)?.toInt(),
      leagueCode: json['leagueCode']?.toString(),
    );
  }

  bool get isLive => normalizeMatchStatus(status) == 'live';

  bool get isFinished => normalizeMatchStatus(status) == 'finished';
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
    case '3H':
    case '4H':
    case '5H':
    case '6H':
    case '7H':
    case '8H':
    case '9H':
    case '10H':
    case '11H':
    case '12H':
    case '13H':
    case '14H':
    case '15H':
    case 'HT':
    case 'ET':
    case 'BT':
    case 'P':
    case 'LIVE':
    case 'IN_PLAY':
    case 'IN1':
    case 'IN2':
    case 'IN3':
    case 'IN4':
    case 'IN5':
    case 'IN6':
    case 'IN7':
    case 'IN8':
    case 'IN9':
    case 'IN10':
    case 'IN11':
    case 'IN12':
    case 'IN13':
    case 'IN14':
    case 'IN15':
      return 'live';
    case 'FT':
    case 'AET':
    case 'PEN':
    case 'FINISHED':
    case 'FIN':
    case 'ABD':
    case 'AWD':
    case 'WO':
      return 'finished';
    case 'PST':
    case 'POSTPONED':
    case 'POST':
      return 'postponed';
    case 'CANC':
    case 'CANCELLED':
    case 'CANCELED':
      return 'cancelled';
    case 'INTR':
      return 'interrupted';
    default:
      if (_isBaseballInningCode(value)) return 'live';
      if (value.contains('LIVE') || value.contains('IN_PLAY')) {
        return 'live';
      }
      if (value.contains('FIN')) return 'finished';
      if (value.contains('POST')) return 'postponed';
      if (value.contains('CANC')) return 'cancelled';
      return value.isEmpty ? 'scheduled' : value.toLowerCase();
  }
}

bool _isBaseballInningCode(String value) {
  if (value.startsWith('IN') && value.length > 2) {
    final inning = int.tryParse(value.substring(2));
    return inning != null && inning >= 1 && inning <= 15;
  }
  if (value.endsWith('H') && value.length >= 2) {
    final inning = int.tryParse(value.substring(0, value.length - 1));
    return inning != null && inning >= 1 && inning <= 15;
  }
  return false;
}

DateTime? _parseFixtureDateTime(Map<String, dynamic> json) {
  final isoRaw =
      json['commence_time'] ?? json['commenceTime'] ?? json['match_date'];
  if (isoRaw != null) {
    final parsed = DateTime.tryParse(isoRaw.toString());
    if (parsed != null) {
      return parsed.isUtc ? parsed : parsed.toUtc();
    }
  }

  final dateRaw = json['date'] ?? json['matchDate'];
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

/// Reverse map for finished-match responses where [league] is a full name string.
const _leagueNameToCode = <String, String>{
  'Premier League': 'PL',
  'La Liga': 'PD',
  'Bundesliga': 'BL1',
  'Serie A': 'SA',
  'Ligue 1': 'FL1',
  'Eredivisie': 'DED',
  'Major League Soccer': 'MLS',
  'MLS': 'MLS',
  'K League 1': 'KL',
  'K League 2': 'KL2',
  'J1 League': 'J1',
  'J League': 'J1',
  'UEFA Champions League': 'UCL',
  'Champions League': 'UCL',
  'UEFA Europa League': 'UEL',
  'Europa League': 'UEL',
  'UEFA Europa Conference League': 'ECL',
  'Conference League': 'ECL',
  'Scottish Premiership': 'SPL',
  'Scottish Premier League': 'SPL',
  'Saudi Pro League': 'SAL',
  'Egyptian Premier League': 'EGY',
  'Super League Greece': 'GSL',
  'Greek Super League': 'GSL',
  'Swiss Super League': 'SSL',
  'Jupiler Pro League': 'JPL',
  'Belgian Pro League': 'JPL',
  'Campeonato Brasileiro Série A': 'BSA',
  'Brasileirão': 'BSA',
  'Brasileirao': 'BSA',
  'Primeira Liga': 'PPL',
  'Serie B': 'SB',
  '2. Bundesliga': 'BL2',
  'Bundesliga 2': 'BL2',
  'Championship': 'CHP',
  'EFL Championship': 'CHP',
  'League Two': 'L2',
  'Ligue 2': 'L2',
  'Liga MX': 'MX',
  'Chinese Super League': 'CSL',
  'Super Lig': 'DSL',
  'Süper Lig': 'DSL',
  'A-League': 'AUS',
  'A League': 'AUS',
  'Copa Libertadores': 'COPA',
  'Copa Sudamericana': 'COSU',
};

String? _lookupLeagueCodeFromName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final direct = _leagueNameToCode[trimmed];
  if (direct != null) return direct;

  final lower = trimmed.toLowerCase();
  for (final entry in _leagueNameToCode.entries) {
    if (entry.key.toLowerCase() == lower) return entry.value;
  }
  return null;
}

String _resolveLeagueCode({required String code, required String name}) {
  final trimmedCode = code.trim();
  final trimmedName = name.trim();

  final fromName = _lookupLeagueCodeFromName(trimmedName);
  if (fromName != null) return fromName;

  final fromCodeAsName = _lookupLeagueCodeFromName(trimmedCode);
  if (fromCodeAsName != null) return fromCodeAsName;

  if (trimmedCode.isNotEmpty &&
      trimmedCode.length <= 6 &&
      RegExp(r'^[A-Za-z0-9]+$').hasMatch(trimmedCode)) {
    return trimmedCode.toUpperCase();
  }

  return trimmedCode;
}

({String code, String name, String? logo}) _readLeagueFields(
  Map<String, dynamic> json,
) {
  final leagueValue = json['league'];
  if (leagueValue is String && leagueValue.isNotEmpty) {
    final code =
        _readString(json, const ['leagueCode', 'league_code', 'code']) ?? '';
    final name = _readString(json, const [
          'leagueName',
          'leagueNameEn',
          'league_name',
        ]) ??
        leagueValue;
    return (
      code: _resolveLeagueCode(code: code, name: name),
      name: name,
      logo: _nonEmptyOrNull(json['leagueLogo'] ?? json['league_logo']),
    );
  }

  final leagueMap = _readMap(json, const [
    'league',
    'leagueInfo',
    'league_info',
    'competition',
  ]);

  if (leagueMap != null) {
    final code = _readString(leagueMap, const [
          'code',
          'leagueCode',
          'league_code',
          'id',
          'leagueId',
          'league_id',
        ]) ??
        '';
    final name = _readString(leagueMap, const [
          'name',
          'leagueName',
          'league_name',
        ]) ??
        '';
    return (
      code: _resolveLeagueCode(code: code, name: name),
      name: name,
      logo: _nonEmptyOrNull(
        leagueMap['logo'] ??
            leagueMap['leagueLogo'] ??
            leagueMap['league_logo'] ??
            leagueMap['icon'] ??
            leagueMap['image'],
      ),
    );
  }

  final code = _readString(json, const [
        'league_code',
        'leagueCode',
        'code',
        'leagueId',
        'league_id',
      ]) ??
      '';
  final name = _readString(json, const [
        'leagueName',
        'leagueNameEn',
        'league_name',
        'competition',
      ]) ??
      code;

  return (
    code: _resolveLeagueCode(code: code, name: name),
    name: name,
    logo: _nonEmptyOrNull(
      json['leagueLogo'] ??
          json['league_logo'] ??
          json['leagueIcon'] ??
          json['league_icon'] ??
          json['icon'],
    ),
  );
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _nonEmptyOrNull(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  return str.isEmpty ? null : str;
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
