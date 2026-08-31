import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/utils/match_date_formatter.dart';

class MatchHeaderData {
  const MatchHeaderData({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamKo,
    this.awayTeamKo,
    this.homeTeamLogo,
    this.awayTeamLogo,
    this.homeTeamId,
    this.awayTeamId,
    this.leagueName,
    this.leagueNameEn,
    this.leagueLogo,
    this.leagueCode,
    this.leagueIconId,
    this.matchDate = '',
    this.matchTime = '',
    this.matchTimestamp,
    this.homeOdds,
    this.drawOdds,
    this.awayOdds,
    this.commenceTime,
    this.matchStatus,
    this.rawStatus,
    this.homeScore,
    this.awayScore,
  });

  final int matchId;
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamKo;
  final String? awayTeamKo;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final int? homeTeamId;
  final int? awayTeamId;
  final String? leagueName;
  final String? leagueNameEn;
  final String? leagueLogo;
  final String? leagueCode;
  final String? leagueIconId;
  final String matchDate;
  final String matchTime;
  final DateTime? matchTimestamp;
  final double? homeOdds;
  final double? drawOdds;
  final double? awayOdds;
  final String? commenceTime;

  /// Normalized status from fixture/detail: scheduled, live, finished, etc.
  final String? matchStatus;

  /// Original API status code (e.g. IN5, FT, NS).
  final String? rawStatus;
  final int? homeScore;
  final int? awayScore;

  factory MatchHeaderData.fromSoccerCard(SoccerAnalysisCard card) {
    final match = card.match;
    final odds = card.odds;
    return MatchHeaderData(
      matchId: match.matchId,
      homeTeam: match.homeTeam.name,
      awayTeam: match.awayTeam.name,
      homeTeamKo: match.homeTeam.nameKo,
      awayTeamKo: match.awayTeam.nameKo,
      homeTeamLogo: match.homeTeam.logo,
      awayTeamLogo: match.awayTeam.logo,
      homeTeamId: match.homeTeam.id,
      awayTeamId: match.awayTeam.id,
      leagueName: match.league.name,
      leagueNameEn: match.league.nameEn,
      leagueLogo: match.league.icon,
      leagueCode: match.league.code,
      leagueIconId: leagueIdForCard(match.league),
      matchDate: match.matchDate,
      matchTime: match.matchTime,
      matchTimestamp: match.matchTimestamp,
      homeOdds: odds?.home,
      drawOdds: odds?.draw,
      awayOdds: odds?.away,
      commenceTime: match.matchTimestamp?.toUtc().toIso8601String(),
    );
  }

  factory MatchHeaderData.fromFixtureMatch(FixtureMatch match) {
    final routeMatchId = match.sport == 'baseball'
        ? (match.apiMatchId ?? match.matchId)
        : match.matchId;
    final leagueIconId = match.sport == 'baseball'
        ? baseballLeagueIconId(match.leagueCode)
        : (TsAssets.leagueIconIdFromApiCode(match.leagueCode) ??
            match.leagueCode.toLowerCase());

    return MatchHeaderData(
      matchId: routeMatchId,
      homeTeam: match.homeTeam,
      awayTeam: match.awayTeam,
      homeTeamKo: match.homeTeamKo,
      awayTeamKo: match.awayTeamKo,
      homeTeamLogo: match.homeTeamLogo,
      awayTeamLogo: match.awayTeamLogo,
      homeTeamId: match.homeTeamId,
      awayTeamId: match.awayTeamId,
      homeOdds: match.homeOdds,
      drawOdds: match.drawOdds,
      awayOdds: match.awayOdds,
      leagueName: match.leagueName,
      leagueNameEn: match.leagueNameEn,
      leagueLogo: match.leagueLogo,
      leagueCode: match.leagueCode,
      leagueIconId: leagueIconId,
      matchDate: match.matchDate,
      matchTime: match.matchTime,
      matchTimestamp: match.matchTimestamp,
      commenceTime: match.matchTimestamp.toUtc().toIso8601String(),
      matchStatus: match.status,
      rawStatus: match.rawStatus,
      homeScore: match.homeScore,
      awayScore: match.awayScore,
    );
  }

  factory MatchHeaderData.fromBaseballMatchDetail(
    Map<String, dynamic> detail, {
    required int matchId,
  }) {
    final match = _unwrapBaseballMatchMap(detail);
    final homeSide = match['home'] is Map
        ? Map<String, dynamic>.from(match['home'] as Map)
        : <String, dynamic>{};
    final awaySide = match['away'] is Map
        ? Map<String, dynamic>.from(match['away'] as Map)
        : <String, dynamic>{};

    final homeTeam = _baseballTeamEnglish(match, homeSide, isHome: true);
    final awayTeam = _baseballTeamEnglish(match, awaySide, isHome: false);
    final homeTeamKo = _baseballTeamKorean(match, homeSide, isHome: true);
    final awayTeamKo = _baseballTeamKorean(match, awaySide, isHome: false);
    final league = _readString(match, const [
          'league',
          'leagueName',
          'league_name',
        ]) ??
        '';
    final leagueCode = league.trim().toUpperCase();
    final timestamp = _parseDateTime(
      match['timestamp'] ??
          match['matchTimestamp'] ??
          match['match_timestamp'],
    );
    final statusStr = _readString(match, const [
      'matchStatus',
      'match_status',
      'status',
      'state',
    ]);
    final rawStatus = (statusStr ?? 'NS').trim().toUpperCase();

    return MatchHeaderData(
      matchId: (match['id'] as num?)?.toInt() ?? matchId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamKo: homeTeamKo.isEmpty ? null : homeTeamKo,
      awayTeamKo: awayTeamKo.isEmpty ? null : awayTeamKo,
      homeTeamLogo: _nonEmpty(
        match['homeLogo'] ??
            match['home_logo'] ??
            homeSide['logo'],
      ),
      awayTeamLogo: _nonEmpty(
        match['awayLogo'] ??
            match['away_logo'] ??
            awaySide['logo'],
      ),
      leagueName: league.isEmpty ? null : league,
      leagueCode: leagueCode.isEmpty ? null : leagueCode,
      leagueIconId: baseballLeagueIconId(league),
      matchDate: _readString(match, const ['date', 'matchDate', 'match_date']) ??
          (timestamp != null ? _formatYmd(timestamp.toLocal()) : ''),
      matchTime: _readString(match, const ['time', 'matchTime', 'match_time']) ??
          (timestamp != null ? _formatHm(timestamp.toLocal()) : ''),
      matchTimestamp: timestamp,
      commenceTime: timestamp?.toUtc().toIso8601String(),
      matchStatus: normalizeMatchStatus(rawStatus),
      rawStatus: rawStatus,
      homeScore: _parseInt(
        match['finalScoreHome'] ??
            match['final_score_home'] ??
            match['homeScore'] ??
            match['home_score'],
      ),
      awayScore: _parseInt(
        match['finalScoreAway'] ??
            match['final_score_away'] ??
            match['awayScore'] ??
            match['away_score'],
      ),
    );
  }

  factory MatchHeaderData.fromBaseballCard(BaseballAnalysisCard card) {
    return MatchHeaderData(
      matchId: card.detailMatchId,
      homeTeam: card.homeTeam,
      awayTeam: card.awayTeam,
      homeTeamKo: card.homeTeamKo,
      awayTeamKo: card.awayTeamKo,
      homeTeamLogo: card.homeTeamLogo,
      awayTeamLogo: card.awayTeamLogo,
      leagueName: card.league,
      leagueCode: card.league,
      leagueIconId: baseballLeagueIconId(card.league),
      matchDate: card.matchDate,
      matchTime: card.matchTime,
      matchTimestamp: card.matchTimestamp,
    );
  }

  factory MatchHeaderData.placeholder({required int matchId}) {
    return MatchHeaderData(
      matchId: matchId,
      homeTeam: '-',
      awayTeam: '-',
      leagueIconId: 'unknown',
      matchDate: '-',
    );
  }

  String get displayDate => displayDateFor('ko');

  String displayDateFor(String locale) {
    if (matchTimestamp != null) {
      return formatMatchDateWithWeekdayAndTime(
        locale,
        matchTimestamp!.toLocal(),
      );
    }
    if (matchDate.contains('월') && matchDate.contains('요일')) {
      if (isKoreanLocaleCode(locale)) return matchDate;
    }
    if (matchDate.isNotEmpty && matchTime.isNotEmpty) {
      final parsed = DateTime.tryParse('$matchDate $matchTime');
      if (parsed != null) {
        return formatMatchDateWithWeekdayAndTime(locale, parsed.toLocal());
      }
      return '$matchDate $matchTime';
    }
    return matchDate.isNotEmpty ? matchDate : '-';
  }

  String get resolvedLeagueIconId =>
      leagueIconId ??
      (leagueCode != null && leagueCode!.isNotEmpty
          ? leagueCode!.toLowerCase()
          : 'unknown');

  String get apiLeagueName {
    final english = leagueNameEn?.trim();
    if (english != null && english.isNotEmpty) return english;
    final fallback = leagueName?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return '';
  }

  String get apiDate {
    if (matchTimestamp != null) {
      final local = matchTimestamp!.toLocal();
      final month = local.month.toString().padLeft(2, '0');
      final day = local.day.toString().padLeft(2, '0');
      return '${local.year}-$month-$day';
    }
    final trimmed = matchDate.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(trimmed)) {
      return trimmed.substring(0, 10);
    }
    return trimmed;
  }

  String get apiTime {
    final trimmed = matchTime.trim();
    if (trimmed.isNotEmpty) {
      return trimmed.length >= 5 ? trimmed.substring(0, 5) : trimmed;
    }
    if (matchTimestamp != null) {
      final local = matchTimestamp!.toLocal();
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '00:00';
  }

  bool get hasAnalysisMetadata {
    final home = homeTeam.trim();
    final away = awayTeam.trim();
    if (home.isEmpty || away.isEmpty || home == '-' || away == '-') {
      return false;
    }
    final code = leagueCode?.trim();
    if (code == null || code.isEmpty) return false;
    if (homeTeamId == null || awayTeamId == null) return false;
    if (homeOdds == null || drawOdds == null || awayOdds == null) {
      return false;
    }
    return true;
  }

  MatchHeaderData mergeWith(MatchHeaderData? other) {
    if (other == null) return this;
    return MatchHeaderData(
      matchId: matchId,
      homeTeam: _preferText(other.homeTeam, homeTeam),
      awayTeam: _preferText(other.awayTeam, awayTeam),
      homeTeamLogo: other.homeTeamLogo ?? homeTeamLogo,
      awayTeamLogo: other.awayTeamLogo ?? awayTeamLogo,
      homeTeamId: other.homeTeamId ?? homeTeamId,
      awayTeamId: other.awayTeamId ?? awayTeamId,
      leagueName: other.leagueName ?? leagueName,
      leagueNameEn: other.leagueNameEn ?? leagueNameEn,
      leagueLogo: other.leagueLogo ?? leagueLogo,
      leagueCode: other.leagueCode ?? leagueCode,
      leagueIconId: other.leagueIconId ?? leagueIconId,
      matchDate: _preferText(other.matchDate, matchDate),
      matchTime: other.matchTime.isNotEmpty ? other.matchTime : matchTime,
      matchTimestamp: other.matchTimestamp ?? matchTimestamp,
      homeOdds: other.homeOdds ?? homeOdds,
      drawOdds: other.drawOdds ?? drawOdds,
      awayOdds: other.awayOdds ?? awayOdds,
      commenceTime: other.commenceTime ?? commenceTime,
      homeTeamKo: other.homeTeamKo ?? homeTeamKo,
      awayTeamKo: other.awayTeamKo ?? awayTeamKo,
      matchStatus: other.matchStatus ?? matchStatus,
      rawStatus: other.rawStatus ?? rawStatus,
      homeScore: other.homeScore ?? homeScore,
      awayScore: other.awayScore ?? awayScore,
    );
  }

  static MatchHeaderData? fromRouteExtra(Object? extra) {
    if (extra is MatchHeaderData) return extra;
    return null;
  }

  static DateTime? timestampFromRouteExtra(Object? extra) {
    if (extra is MatchHeaderData) return extra.matchTimestamp;
    if (extra is DateTime) return extra;
    if (extra is String) return DateTime.tryParse(extra);
    return null;
  }

  static String _preferText(String primary, String fallback) {
    final trimmed = primary.trim();
    if (trimmed.isEmpty || trimmed == '-' || trimmed == '홈' || trimmed == '원정') {
      return fallback;
    }
    return trimmed;
  }

  static Map<String, dynamic> _unwrapBaseballMatchMap(Map<String, dynamic> detail) {
    final match = detail['match'];
    if (match is Map<String, dynamic>) return match;
    if (match is Map) return Map<String, dynamic>.from(match);

    final matches = detail['matches'];
    if (matches is List && matches.isNotEmpty) {
      final first = matches.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }

    return detail;
  }

  static String _baseballTeamEnglish(
    Map<String, dynamic> match,
    Map<String, dynamic> side, {
    required bool isHome,
  }) {
    final fromSide = _readString(side, const ['team', 'teamKo']) ?? '';
    if (fromSide.isNotEmpty) return fromSide;
    final flatKey = isHome ? 'homeTeam' : 'awayTeam';
    return match[flatKey]?.toString() ?? '';
  }

  static String _baseballTeamKorean(
    Map<String, dynamic> match,
    Map<String, dynamic> side, {
    required bool isHome,
  }) {
    final fromSide = _readString(side, const ['teamKo', 'team']) ?? '';
    if (fromSide.isNotEmpty) return fromSide;
    final flatKoKey = isHome ? 'homeTeamKo' : 'awayTeamKo';
    final flatKey = isHome ? 'homeTeam' : 'awayTeam';
    return _readString(match, [flatKoKey, flatKey]) ?? '';
  }

  static String? _readString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _nonEmpty(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is int) {
      final millis = value < 10000000000 ? value * 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String _formatYmd(DateTime local) {
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static String _formatHm(DateTime local) {
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
