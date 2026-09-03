// Pure-data parse of baseball starting-pitcher stats for report block 03.
// Normalises MLB, KBO, and NPB pitcher-stats payloads into one shape.
// No BuildContext, localization, or gauge fractions.

class BaseballPitcherSideParsed {
  const BaseballPitcherSideParsed({
    this.name,
    this.nameKo,
    this.isNameTbd = false,
    this.throwingHand,
    this.photoUrl,
    this.pitcherId,
    this.era,
    this.whip,
    this.strikeoutsPer9,
    this.strikeouts,
    this.wins,
    this.losses,
    this.inningsPitched,
    this.strengths = const [],
    this.weaknesses = const [],
    this.summary,
    this.seasonYear,
    this.prevSeasonYear,
    this.prevEra,
    this.prevWhip,
    this.prevStrikeouts,
  });

  final String? name;
  final String? nameKo;
  final bool isNameTbd;
  final String? throwingHand;
  final String? photoUrl;
  final int? pitcherId;

  final double? era;
  final double? whip;
  final double? strikeoutsPer9;
  final int? strikeouts;
  final int? wins;
  final int? losses;
  final String? inningsPitched;

  final List<String> strengths;
  final List<String> weaknesses;
  final String? summary;

  final int? seasonYear;
  final int? prevSeasonYear;
  final double? prevEra;
  final double? prevWhip;
  final int? prevStrikeouts;
}

class BaseballStartingPitchersParsed {
  const BaseballStartingPitchersParsed({
    required this.home,
    required this.away,
    this.seasonYear,
  });

  final BaseballPitcherSideParsed home;
  final BaseballPitcherSideParsed away;
  final int? seasonYear;
}

/// Parses league pitcher-stats payloads into a unified starting-pitchers model.
///
/// [statsResponse] is the current-season response from
/// `mlbPitcherStatsProvider` (MLB) or `baseballPitcherStatsProvider` (KBO/NPB).
/// For KBO/NPB, previous-season maps live in the same payload as
/// `homePitcherPrev` / `awayPitcherPrev`.
///
/// [prevStatsResponse] is the previous-season response from
/// `mlbPitcherStatsPrevProvider` (MLB only).
BaseballStartingPitchersParsed parseBaseballStartingPitchers({
  required String leagueCode,
  required Map<String, dynamic> statsResponse,
  Map<String, dynamic>? prevStatsResponse,
}) {
  final league = _normalizeLeagueCode(leagueCode);
  final rootSeason = _parseSeasonYear(statsResponse['season']);

  final homeCurrent = _readMap(statsResponse, const ['homePitcher']);
  final awayCurrent = _readMap(statsResponse, const ['awayPitcher']);

  Map<String, dynamic>? homePrev;
  Map<String, dynamic>? awayPrev;
  int? rootPrevSeason;

  if (league == 'MLB') {
    final prev = prevStatsResponse ?? const <String, dynamic>{};
    homePrev = _readMap(prev, const ['homePitcher']);
    awayPrev = _readMap(prev, const ['awayPitcher']);
    rootPrevSeason = _parseSeasonYear(prev['season']);
  } else {
    homePrev = _readMap(statsResponse, const ['homePitcherPrev']);
    awayPrev = _readMap(statsResponse, const ['awayPitcherPrev']);
  }

  return BaseballStartingPitchersParsed(
    seasonYear: rootSeason,
    home: _parsePitcherSide(
      league: league,
      current: homeCurrent,
      previous: homePrev,
      rootSeasonYear: rootSeason,
      rootPrevSeasonYear: rootPrevSeason,
    ),
    away: _parsePitcherSide(
      league: league,
      current: awayCurrent,
      previous: awayPrev,
      rootSeasonYear: rootSeason,
      rootPrevSeasonYear: rootPrevSeason,
    ),
  );
}

BaseballPitcherSideParsed _parsePitcherSide({
  required String league,
  required Map<String, dynamic>? current,
  required Map<String, dynamic>? previous,
  required int? rootSeasonYear,
  required int? rootPrevSeasonYear,
}) {
  final normalized = _normalizePitcherStatsMap(current);
  final name = _readString(normalized, const [
    'fullName',
    'full_name',
    'name',
    'pitcherName',
    'pitcher_name',
  ]);
  final nameKo = _readString(normalized, const ['nameKo', 'name_ko']);
  final throwingHand = _readString(normalized, const [
    'throwingHand',
    'throwing_hand',
    'hand',
    'pitcherType',
    'pitcher_type',
  ]);
  final pitcherId = _parseInt(
    normalized['playerId'] ?? normalized['player_id'] ?? normalized['id'],
  );
  final photoUrl = _resolvePhotoUrl(
    league: league,
    photo: _readString(normalized, const [
      'photo',
      'photoUrl',
      'photo_url',
      'image',
    ]),
    pitcherId: pitcherId,
  );

  final era = _parseDouble(_readPitcherStatValue(normalized, 'era'));
  final whip = _parseDouble(_readPitcherStatValue(normalized, 'whip'));
  final strikeoutsPer9 = _parseDouble(
    _readPitcherStatValue(normalized, 'strikeoutsPer9Inn'),
  );
  final strikeouts = _parseInt(
    _readPitcherStatValue(normalized, 'strikeouts'),
  );
  final wins = _parseInt(_readPitcherStatValue(normalized, 'wins'));
  final losses = _parseInt(_readPitcherStatValue(normalized, 'losses'));
  final inningsPitched = _readRawString(
    _readPitcherStatValue(normalized, 'inningsPitched'),
  );

  final strengths = _readStringList(
    normalized['strengths'] ?? normalized['strength'],
  );
  final weaknesses = _readStringList(
    normalized['weaknesses'] ?? normalized['weakness'],
  );
  final summary = _readString(normalized, const ['summary']);

  final sideSeason = _parseSeasonYear(normalized['season']) ?? rootSeasonYear;
  final prevNormalized = _normalizePitcherStatsMap(previous);
  final prevSeasonYear = _parseSeasonYear(prevNormalized['season']) ??
      rootPrevSeasonYear;

  return BaseballPitcherSideParsed(
    name: name,
    nameKo: nameKo,
    isNameTbd: _isPitcherTbd(name, nameKo),
    throwingHand: throwingHand,
    photoUrl: photoUrl,
    pitcherId: pitcherId,
    era: era,
    whip: whip,
    strikeoutsPer9: strikeoutsPer9,
    strikeouts: strikeouts,
    wins: wins,
    losses: losses,
    inningsPitched: inningsPitched,
    strengths: strengths,
    weaknesses: weaknesses,
    summary: summary,
    seasonYear: sideSeason,
    prevSeasonYear: prevSeasonYear,
    prevEra: _parseDouble(_readPitcherStatValue(prevNormalized, 'era')),
    prevWhip: _parseDouble(_readPitcherStatValue(prevNormalized, 'whip')),
    prevStrikeouts: _parseInt(
      _readPitcherStatValue(prevNormalized, 'strikeouts'),
    ),
  );
}

String _normalizeLeagueCode(String league) {
  final upper = league.trim().toUpperCase();
  if (upper.contains('MLB') || upper.contains('MAJOR')) return 'MLB';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('KBO') || upper.contains('KOREA')) return 'KBO';
  return upper;
}

bool _isPitcherNameTbd(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty || trimmed == '-') return true;
  final upper = trimmed.toUpperCase();
  return upper == 'TBD' || trimmed == '미정';
}

bool _isPitcherTbd(String? name, String? nameKo) =>
    _isPitcherNameTbd(name) && _isPitcherNameTbd(nameKo);

String? _resolvePhotoUrl({
  required String league,
  required String? photo,
  required int? pitcherId,
}) {
  final trimmedPhoto = photo?.trim();
  if (trimmedPhoto != null && trimmedPhoto.isNotEmpty) {
    if (league == 'MLB') {
      return trimmedPhoto.replaceFirst('w_213', 'w_120');
    }
    return trimmedPhoto;
  }

  if (league == 'MLB' && pitcherId != null) {
    return 'https://img.mlbstatic.com/mlb-photos/image/upload/'
        'd_people:generic:headshot:67:current.png/w_120,q_auto:best/'
        'v1/people/$pitcherId/headshot/67/current';
  }

  return null;
}

Map<String, dynamic> _normalizePitcherStatsMap(Map<String, dynamic>? stats) {
  if (stats == null || stats.isEmpty) return const {};

  var merged = Map<String, dynamic>.from(stats);
  for (final key in const ['data', 'current', 'seasonStats', 'stats']) {
    final nested = stats[key];
    if (nested is Map) {
      merged = {
        ...Map<String, dynamic>.from(nested),
        ...merged,
      };
    }
  }
  return merged;
}

Object? _readPitcherStatValue(Map<String, dynamic> stats, String key) {
  final variants = switch (key) {
    'era' => const ['era', 'ERA'],
    'whip' => const ['whip', 'WHIP'],
    'wins' => const ['wins', 'W'],
    'losses' => const ['losses', 'L'],
    'strikeouts' => const ['strikeouts', 'strikeOuts', 'k', 'K'],
    'strikeoutsPer9Inn' => const [
        'strikeoutsPer9Inn',
        'k9',
        'K9',
        'strikeouts_per_9_inn',
      ],
    'inningsPitched' => const [
        'inningsPitched',
        'ip',
        'IP',
        'innings_pitched',
      ],
    _ => <String>[key],
  };
  for (final variant in variants) {
    if (stats.containsKey(variant)) return stats[variant];
  }
  return null;
}

List<String> _readStringList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .map((item) => item?.toString().trim())
      .whereType<String>()
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int? _parseSeasonYear(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }
  return null;
}

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
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
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }
  return null;
}

String? _readRawString(Object? value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num) return value.toString();
  return null;
}
