import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/features/analysis/models/baseball_match_report_data.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/standard/baseball_h2h_section.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/standard/baseball_odds_section.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/standard/starting_pitchers_section.dart';

class BaseballStandardPitcher {
  const BaseballStandardPitcher({
    required this.name,
    this.nameKo,
    this.photoUrl,
    required this.pitcherType,
    required this.era,
    required this.whip,
    required this.k9,
    required this.wl,
    required this.ip,
    required this.k,
    required this.prevWl,
    required this.prevIp,
    required this.prevK,
    required this.strengths,
    required this.weaknesses,
  });

  final String name;
  final String? nameKo;
  final String? photoUrl;
  final String pitcherType;
  final String era;
  final String whip;
  final String k9;
  final String wl;
  final String ip;
  final String k;
  final String prevWl;
  final String prevIp;
  final String prevK;
  final List<String> strengths;
  final List<String> weaknesses;

  String get displayName {
    final ko = nameKo?.trim();
    if (ko != null && ko.isNotEmpty) return ko;
    return name.trim().isEmpty ? '-' : name.trim();
  }

  PitcherData toPitcherData() {
    return PitcherData(
      name: displayName,
      pitcherType: pitcherType.isEmpty ? '투수' : pitcherType,
      photoUrl: photoUrl,
      era: era,
      whip: whip,
      k9: k9,
      wl: wl,
      ip: ip,
      k: k,
      prevWl: prevWl,
      prevIp: prevIp,
      prevK: prevK,
      strengths: strengths,
      weaknesses: weaknesses,
    );
  }
}

class BaseballStandardParsed {
  const BaseballStandardParsed({
    required this.league,
    required this.leagueId,
    required this.homeTeam,
    required this.awayTeam,
    this.homeLogoUrl,
    this.awayLogoUrl,
    required this.matchDateDisplay,
    required this.matchTimeDisplay,
    required this.status,
    this.homeScore,
    this.awayScore,
    required this.homePitcher,
    required this.awayPitcher,
    required this.pitcherMatchupAnalysis,
    required this.h2hMatches,
    required this.relatedMatches,
    required this.homeWinOdds,
    required this.awayWinOdds,
    this.homeWinProbRatio,
    this.awayWinProbRatio,
    required this.ouLines,
  });

  final String league;
  final String leagueId;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final String matchDateDisplay;
  final String matchTimeDisplay;
  final String status;
  final String? homeScore;
  final String? awayScore;
  final BaseballStandardPitcher homePitcher;
  final BaseballStandardPitcher awayPitcher;
  final List<String> pitcherMatchupAnalysis;
  final List<BaseballH2HMatch> h2hMatches;
  final List<BaseballRelatedMatch> relatedMatches;
  final String homeWinOdds;
  final String awayWinOdds;
  final double? homeWinProbRatio;
  final double? awayWinProbRatio;
  final List<BaseballOULine> ouLines;
}

class BaseballRelatedMatch {
  const BaseballRelatedMatch({
    required this.date,
    required this.time,
    required this.homeTeam,
    required this.awayTeam,
    this.homeLogoUrl,
    this.awayLogoUrl,
    this.homeScore,
    this.awayScore,
    required this.status,
  });

  final String date;
  final String time;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final String? homeScore;
  final String? awayScore;
  final String status;

  String get dateDisplay {
    if (date.isEmpty) return '-';
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(date)) {
      final parts = date.split('-');
      if (parts.length >= 3) return '${parts[1]}.${parts[2]}';
    }
    return date;
  }

  String get scoreDisplay {
    if (homeScore != null &&
        awayScore != null &&
        homeScore!.isNotEmpty &&
        awayScore!.isNotEmpty) {
      return '$awayScore-$homeScore';
    }
    return 'vs';
  }
}

bool _loggedDetailKeys = false;

BaseballStandardParsed parseBaseballStandardDetail(Map<String, dynamic> raw) {
  if (!_loggedDetailKeys) {
    _loggedDetailKeys = true;
    print('[BASEBALL] Match detail keys: ${raw.keys.toList()}');
  }

  final match = _unwrapDetail(raw);
  if (match.isNotEmpty && match != raw) {
    print('[BASEBALL] Match detail data keys: ${match.keys.toList()}');
  }

  final homeSide = _readMap(match, const ['home']) ?? {};
  final awaySide = _readMap(match, const ['away']) ?? {};

  final homeTeamKo = _readString(homeSide, const ['teamKo', 'team_ko']);
  final homeTeamEn = _readString(homeSide, const ['team', 'name']) ?? '';
  final awayTeamKo = _readString(awaySide, const ['teamKo', 'team_ko']);
  final awayTeamEn = _readString(awaySide, const ['team', 'name']) ?? '';

  final homeTeam = _preferKo(homeTeamKo, homeTeamEn);
  final awayTeam = _preferKo(awayTeamKo, awayTeamEn);

  final homeLogoUrl = _nonEmptyOrNull(homeSide['logo']);
  final awayLogoUrl = _nonEmptyOrNull(awaySide['logo']);

  final homeScore = _formatNullableScore(homeSide['score']);
  final awayScore = _formatNullableScore(awaySide['score']);

  final league = _readString(match, const ['league', 'leagueName', 'league_name']) ??
      '';
  final dateStr = _readString(match, const ['date', 'matchDate', 'match_date']) ?? '';
  final timeStr = _readString(match, const ['time', 'matchTime', 'match_time']) ?? '';
  final timestamp = _parseDateTime(
    match['timestamp'] ?? match['matchTimestamp'] ?? match['match_timestamp'],
  );

  final homePitcher = _parsePitcherFromMatchRoot(
    match,
    side: 'home',
    teamLogoUrl: homeLogoUrl,
  );
  final awayPitcher = _parsePitcherFromMatchRoot(
    match,
    side: 'away',
    teamLogoUrl: awayLogoUrl,
  );

  print('[BASEBALL] Standard parse: home=$homeTeam, away=$awayTeam');
  print(
    '[BASEBALL] Standard parse: homePitcher=${homePitcher.displayName}, awayPitcher=${awayPitcher.displayName}',
  );

  final oddsMap = _readMap(match, const ['odds']) ?? {};
  final odds = BaseballOdds.fromJson(oddsMap);
  final homeProbRatio = _normalizeProbRatio(odds.homeWinProb);
  final awayProbRatio = _normalizeProbRatio(odds.awayWinProb);

  print(
    '[BASEBALL] Standard parse: odds homeProb=${odds.homeWinProb}, awayProb=${odds.awayWinProb}',
  );

  final cardFallback = BaseballAnalysisCard.fromJson(match);

  return BaseballStandardParsed(
    league: league.isEmpty ? '야구' : league,
    leagueId: baseballLeagueIconId(league),
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    homeLogoUrl: homeLogoUrl,
    awayLogoUrl: awayLogoUrl,
    matchDateDisplay: _formatMatchDateDisplay(
      timestamp ?? cardFallback.matchTimestamp,
      dateStr,
      timeStr,
    ),
    matchTimeDisplay: _formatMatchTimeDisplay(
      timestamp ?? cardFallback.matchTimestamp,
      timeStr,
    ),
    status: _readString(match, const ['status', 'matchStatus', 'match_status']) ??
        cardFallback.status,
    homeScore: homeScore,
    awayScore: awayScore,
    homePitcher: homePitcher,
    awayPitcher: awayPitcher,
    pitcherMatchupAnalysis: _parsePitcherMatchupAnalysis(match),
    h2hMatches: _parseH2HMatches(match, cardFallback),
    relatedMatches: _parseRelatedMatches(match['relatedMatches']),
    homeWinOdds: _formatOddsValue(odds.homeWinOdds),
    awayWinOdds: _formatOddsValue(odds.awayWinOdds),
    homeWinProbRatio: homeProbRatio,
    awayWinProbRatio: awayProbRatio,
    ouLines: _parseOuLines(odds),
  );
}

BaseballStandardParsed baseballStandardHeaderFallback(
  BaseballMatchReportData dummy,
) {
  return BaseballStandardParsed(
    league: dummy.leagueId.toUpperCase(),
    leagueId: dummy.leagueId,
    homeTeam: dummy.homeTeam,
    awayTeam: dummy.awayTeam,
    homeLogoUrl: dummy.homeLogoUrl,
    awayLogoUrl: dummy.awayLogoUrl,
    matchDateDisplay: dummy.matchDate,
    matchTimeDisplay: '',
    status: 'scheduled',
    homePitcher: _emptyPitcher(),
    awayPitcher: _emptyPitcher(),
    pitcherMatchupAnalysis: const [],
    h2hMatches: const [],
    relatedMatches: const [],
    homeWinOdds: '-',
    awayWinOdds: '-',
    ouLines: const [],
  );
}

Map<String, dynamic> _unwrapDetail(Map<String, dynamic> raw) {
  final match = raw['match'];
  if (match is Map<String, dynamic>) return match;
  if (match is Map) return Map<String, dynamic>.from(match);

  if (raw['success'] == true) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
  }

  final nested = _readMap(raw, const ['data', 'result']);
  return nested ?? raw;
}

String _preferKo(String? ko, String fallback) {
  final trimmedKo = ko?.trim();
  if (trimmedKo != null && trimmedKo.isNotEmpty) return trimmedKo;
  final trimmedFallback = fallback.trim();
  return trimmedFallback.isEmpty ? '-' : trimmedFallback;
}

String? _formatNullableScore(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _parseDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value.isUtc ? value : value.toUtc();
  return DateTime.tryParse(value.toString());
}

BaseballStandardPitcher _parsePitcherFromMatchRoot(
  Map<String, dynamic> match, {
  required String side,
  String? teamLogoUrl,
}) {
  final prefix = side == 'home' ? 'home' : 'away';
  final name = _readString(match, ['${prefix}Pitcher', '${prefix}_pitcher']) ?? '';
  final nameKo = _readString(match, [
    '${prefix}PitcherKo',
    '${prefix}_pitcher_ko',
  ]);

  return BaseballStandardPitcher(
    name: name.isEmpty ? '-' : name,
    nameKo: nameKo,
    photoUrl: teamLogoUrl,
    pitcherType: '투수',
    era: _formatDecimalStat(match['${prefix}PitcherEra']),
    whip: _formatDecimalStat(match['${prefix}PitcherWhip']),
    k9: '-',
    wl: '-',
    ip: '-',
    k: _formatStat(match['${prefix}PitcherK']),
    prevWl: '-',
    prevIp: '-',
    prevK: '-',
    strengths: const [],
    weaknesses: const [],
  );
}

List<BaseballRelatedMatch> _parseRelatedMatches(Object? value) {
  if (value is! List) return const [];

  return value.whereType<Map>().map((item) {
    final map = Map<String, dynamic>.from(item);
    return BaseballRelatedMatch(
      date: _readString(map, const ['date', 'matchDate', 'match_date']) ?? '',
      time: _readString(map, const ['time', 'matchTime', 'match_time']) ?? '',
      homeTeam: _readString(map, const [
            'homeTeamKo',
            'home_team_ko',
            'homeTeam',
            'home_team',
          ]) ??
          '-',
      awayTeam: _readString(map, const [
            'awayTeamKo',
            'away_team_ko',
            'awayTeam',
            'away_team',
          ]) ??
          '-',
      homeLogoUrl: _nonEmptyOrNull(
        map['homeLogo'] ?? map['home_logo'] ?? map['homeTeamLogo'],
      ),
      awayLogoUrl: _nonEmptyOrNull(
        map['awayLogo'] ?? map['away_logo'] ?? map['awayTeamLogo'],
      ),
      homeScore: _formatNullableScore(map['homeScore'] ?? map['home_score']),
      awayScore: _formatNullableScore(map['awayScore'] ?? map['away_score']),
      status: _readString(map, const ['status', 'matchStatus']) ?? '',
    );
  }).toList();
}

String _formatDecimalStat(Object? value) {
  if (value == null) return '-';
  if (value is num) return value.toStringAsFixed(2);
  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

BaseballStandardPitcher _emptyPitcher() {
  return const BaseballStandardPitcher(
    name: '-',
    pitcherType: '투수',
    era: '-',
    whip: '-',
    k9: '-',
    wl: '-',
    ip: '-',
    k: '-',
    prevWl: '-',
    prevIp: '-',
    prevK: '-',
    strengths: [],
    weaknesses: [],
  );
}

List<String> _parsePitcherMatchupAnalysis(Map<String, dynamic> data) {
  final root = _readMap(data, const [
        'pitcherMatchupAnalysis',
        'pitcher_matchup_analysis',
        'pitcherAnalysis',
        'pitcher_analysis',
        'matchupAnalysis',
        'matchup_analysis',
        'pitcherMatchup',
        'pitcher_matchup',
      ]) ??
      data;

  final paragraphs = _parseStringList(
    root['paragraphs'] ??
        root['sections'] ??
        root['analysis'] ??
        root['summary'] ??
        root['text'] ??
        root['content'] ??
        data['pitcherAnalysis'] ??
        data['pitcher_analysis'] ??
        data['matchupAnalysis'] ??
        data['matchup_analysis'],
  );

  if (paragraphs.isNotEmpty) return paragraphs;

  final single = _readString(root, const [
    'summary',
    'text',
    'analysis',
    'content',
    'insight',
    'description',
  ]);
  if (single != null && single.trim().isNotEmpty) {
    return single
        .split(RegExp(r'\n{2,}'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }
  return const [];
}

List<BaseballH2HMatch> _parseH2HMatches(
  Map<String, dynamic> data,
  BaseballAnalysisCard card,
) {
  final h2hRoot = _readMap(data, const [
        'h2h',
        'headToHead',
        'head_to_head',
        'matchupHistory',
        'matchup_history',
      ]) ??
      data;

  final list = _extractList(
    h2hRoot['matches'] ??
        h2hRoot['meetings'] ??
        h2hRoot['records'] ??
        h2hRoot['history'] ??
        h2hRoot['items'] ??
        h2hRoot['games'],
  );

  return list
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        final homeScore = _parseInt(
          map['homeScore'] ??
              map['home_score'] ??
              map['homeGoals'] ??
              map['home_goals'],
        );
        final awayScore = _parseInt(
          map['awayScore'] ??
              map['away_score'] ??
              map['awayGoals'] ??
              map['away_goals'],
        );

        final homeTeam = _readString(map, const [
              'homeTeamKo',
              'home_team_ko',
              'homeTeam',
              'home_team',
              'home',
            ]) ??
            card.homeDisplayTeam;
        final awayTeam = _readString(map, const [
              'awayTeamKo',
              'away_team_ko',
              'awayTeam',
              'away_team',
              'away',
            ]) ??
            card.awayDisplayTeam;

        final score = homeScore != null && awayScore != null
            ? '$awayScore-$homeScore'
            : _readString(map, const ['score', 'result']) ?? '-';

        BaseballH2HWinner winner = BaseballH2HWinner.home;
        if (homeScore != null && awayScore != null) {
          if (awayScore > homeScore) {
            winner = BaseballH2HWinner.away;
          } else if (homeScore > awayScore) {
            winner = BaseballH2HWinner.home;
          } else {
            winner = BaseballH2HWinner.home;
          }
        } else {
          final winnerRaw =
              _readString(map, const ['winner', 'winnerSide', 'winner_side']);
          if (winnerRaw?.toLowerCase().contains('away') == true) {
            winner = BaseballH2HWinner.away;
          }
        }

        return BaseballH2HMatch(
          date: _formatH2HDate(
            _readString(map, const ['date', 'matchDate', 'match_date']),
          ),
          awayTeam: awayTeam,
          homeTeam: homeTeam,
          score: score,
          winner: winner,
        );
      })
      .toList();
}

List<BaseballOULine> _parseOuLines(BaseballOdds odds) {
  final lines = odds.ouLines;
  if (lines != null && lines.isNotEmpty) {
    return lines
        .map(
          (line) => BaseballOULine(
            line: _formatOddsValue(line.line),
            over: _formatOddsValue(line.over),
            under: _formatOddsValue(line.under),
            isBaseLine: odds.overUnderLine == line.line,
          ),
        )
        .toList();
  }

  if (odds.overUnderLine != null) {
    return [
      BaseballOULine(
        line: _formatOddsValue(odds.overUnderLine!),
        over: _formatOddsValue(odds.overOdds ?? 0),
        under: _formatOddsValue(odds.underOdds ?? 0),
        isBaseLine: true,
      ),
    ];
  }

  return const [];
}

String _formatMatchDateDisplay(
  DateTime timestamp,
  String dateStr,
  String timeStr,
) {
  var local = timestamp.toLocal();
  if (local.millisecondsSinceEpoch == 0) {
    final parsed = DateTime.tryParse('$dateStr $timeStr');
    if (parsed != null) local = parsed.toLocal();
  }

  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final weekday = weekdays[local.weekday - 1];
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.month}월 ${local.day}일 $weekday요일 $hour:$minute';
}

String _formatMatchTimeDisplay(DateTime timestamp, String timeStr) {
  if (timestamp.millisecondsSinceEpoch != 0) {
    final local = timestamp.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  if (timeStr.contains(':')) {
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
  }
  return timeStr;
}

String _formatH2HDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final parsed = DateTime.tryParse(raw);
  if (parsed != null) {
    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$month.$day';
  }
  if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(raw)) {
    final parts = raw.split('-');
    if (parts.length >= 3) return '${parts[1]}.${parts[2]}';
  }
  return raw;
}

String _formatStat(Object? value) {
  if (value == null) return '-';
  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

String _formatOddsValue(Object? value) {
  if (value == null) return '-';
  if (value is num) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }
  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

double? _normalizeProbRatio(double? value) {
  if (value == null) return null;
  if (value <= 0) return null;
  if (value <= 1) return value.clamp(0.0, 1.0);
  return (value / 100).clamp(0.0, 1.0);
}

List<String> _parseStringList(Object? value) {
  if (value is List) {
    return value
        .map((item) {
          if (item is String) return item.trim();
          if (item is Map) {
            return _readString(
              Map<String, dynamic>.from(item),
              const ['text', 'label', 'value', 'name', 'content'],
            );
          }
          return item?.toString().trim();
        })
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return [value.trim()];
  }
  return const [];
}

List<dynamic> _extractList(Object? value) {
  if (value is List) return value;
  return const [];
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
    if (value is String && value.isNotEmpty) return value;
    if (value is num) return value.toString();
  }
  return null;
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _nonEmptyOrNull(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
