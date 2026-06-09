import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/features/analysis/models/baseball_standard_parser.dart';
import 'package:trendsoccer/features/analysis/models/soccer_analysis_parser.dart';

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

  factory MatchHeaderData.fromSoccerStandardParsed(
    SoccerStandardAnalysisParsed parsed, {
    required int matchId,
  }) {
    return MatchHeaderData(
      matchId: matchId,
      homeTeam: parsed.homeTeam,
      awayTeam: parsed.awayTeam,
      homeTeamLogo: parsed.homeLogoUrl,
      awayTeamLogo: parsed.awayLogoUrl,
      leagueIconId: parsed.leagueId,
      matchDate: parsed.matchDateDisplay,
      matchTimestamp: parsed.matchTimestampUtc,
    );
  }

  factory MatchHeaderData.fromBaseballStandardParsed(
    BaseballStandardParsed parsed, {
    required int matchId,
  }) {
    return MatchHeaderData(
      matchId: matchId,
      homeTeam: parsed.homeTeam,
      awayTeam: parsed.awayTeam,
      homeTeamKo: parsed.homeTeamKo,
      awayTeamKo: parsed.awayTeamKo,
      homeTeamLogo: parsed.homeLogoUrl,
      awayTeamLogo: parsed.awayLogoUrl,
      leagueName: parsed.league,
      leagueIconId: parsed.leagueId,
      matchDate: parsed.matchDateDisplay,
      matchTime: parsed.matchTimeDisplay,
      matchTimestamp: null,
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

  String get displayDate {
    if (matchDate.contains('월') && matchDate.contains('요일')) {
      return matchDate;
    }
    if (matchTimestamp != null) {
      return _formatKstDateTime(matchTimestamp!.toLocal());
    }
    if (matchDate.isNotEmpty && matchTime.isNotEmpty) {
      final parsed = DateTime.tryParse('$matchDate $matchTime');
      if (parsed != null) {
        return _formatKstDateTime(parsed.toLocal());
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

  static String _formatKstDateTime(DateTime local) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[local.weekday - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.month}월 ${local.day}일 $weekday요일 $hour:$minute';
  }
}
