import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/utils/league_supports_analysis.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';

/// Cap for the home "today's matches" carousel (Figma shows five).
const homeTodayMatchesLimit = 10;

/// Cap for the home analysis carousels (Figma shows seven).
const homeAnalysisMatchesLimit = 7;

/// Normalized upcoming match preview shared across home carousels.
class HomeMatchPreview {
  const HomeMatchPreview({
    required this.leagueCode,
    required this.homeTeamEn,
    this.homeTeamKo,
    required this.awayTeamEn,
    this.awayTeamKo,
    this.homeEmblemUrl,
    this.awayEmblemUrl,
    required this.kickoffUtc,
    required this.hasAnalysis,
  });

  final String leagueCode;
  final String homeTeamEn;
  final String? homeTeamKo;
  final String awayTeamEn;
  final String? awayTeamKo;
  final String? homeEmblemUrl;
  final String? awayEmblemUrl;

  /// Kickoff instant stored in UTC for cross-sport sorting.
  final DateTime kickoffUtc;
  final bool hasAnalysis;
}

/// Today's upcoming scheduled matches across soccer and baseball analysis feeds.
final homeTodayMatchesProvider =
    FutureProvider<List<HomeMatchPreview>>((ref) async {
  final soccer = await ref.watch(analysisSoccerMatchesProvider.future);
  final baseball = await ref.watch(baseballAnalysisMatchesProvider.future);

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  final merged = <HomeMatchPreview>[
    ...soccer
        .map(_homeMatchPreviewFromSoccer)
        .whereType<HomeMatchPreview>()
        .where((match) => _isTodayUpcomingScheduled(match, todayStart, now)),
    ...baseball
        .map(_homeMatchPreviewFromBaseball)
        .where((match) => _isTodayUpcomingScheduled(match, todayStart, now)),
  ];

  return _capSortedByKickoff(merged, homeTodayMatchesLimit);
});

/// Upcoming analysis matches for one sport, sorted by kickoff (no today filter).
final homeAnalysisMatchesProvider =
    FutureProvider.family<List<HomeMatchPreview>, TsSport>((ref, sport) async {
  switch (sport) {
    case TsSport.soccer:
      final soccer = await ref.watch(analysisSoccerMatchesProvider.future);
      final previews = soccer
          .map(_homeMatchPreviewFromSoccer)
          .whereType<HomeMatchPreview>()
          .toList();
      return _capSortedByKickoff(previews, homeAnalysisMatchesLimit);
    case TsSport.baseball:
      final baseball = await ref.watch(baseballAnalysisMatchesProvider.future);
      final previews = baseball.map(_homeMatchPreviewFromBaseball).toList();
      return _capSortedByKickoff(previews, homeAnalysisMatchesLimit);
  }
});

List<HomeMatchPreview> _capSortedByKickoff(
  List<HomeMatchPreview> matches,
  int limit,
) {
  final sorted = [...matches]..sort((a, b) => a.kickoffUtc.compareTo(b.kickoffUtc));
  if (sorted.length > limit) {
    return sorted.sublist(0, limit);
  }
  return sorted;
}

bool _isTodayUpcomingScheduled(
  HomeMatchPreview match,
  DateTime todayStart,
  DateTime now,
) {
  final localKickoff = match.kickoffUtc.toLocal();
  final kickoffDay = DateTime(
    localKickoff.year,
    localKickoff.month,
    localKickoff.day,
  );
  if (kickoffDay != todayStart) return false;
  return localKickoff.isAfter(now);
}

HomeMatchPreview? _homeMatchPreviewFromSoccer(SoccerAnalysisCard card) {
  final match = card.match;
  if (match.status != 'scheduled') return null;

  final timestamp = match.matchTimestamp;
  if (timestamp == null) return null;

  final kickoffUtc = timestamp.isUtc ? timestamp : timestamp.toUtc();
  final leagueCode = match.league.code;
  if (leagueCode == null || leagueCode.isEmpty) return null;

  return HomeMatchPreview(
    leagueCode: leagueCode,
    homeTeamEn: match.homeTeam.name,
    homeTeamKo: match.homeTeam.nameKo,
    awayTeamEn: match.awayTeam.name,
    awayTeamKo: match.awayTeam.nameKo,
    homeEmblemUrl: match.homeTeam.logo,
    awayEmblemUrl: match.awayTeam.logo,
    kickoffUtc: kickoffUtc,
    hasAnalysis: _soccerHasAnalysis(card),
  );
}

HomeMatchPreview _homeMatchPreviewFromBaseball(BaseballAnalysisCard card) {
  final kickoffUtc = card.matchTimestamp.isUtc
      ? card.matchTimestamp
      : card.matchTimestamp.toUtc();

  return HomeMatchPreview(
    leagueCode: card.league,
    homeTeamEn: card.homeTeam,
    homeTeamKo: card.homeTeamKo,
    awayTeamEn: card.awayTeam,
    awayTeamKo: card.awayTeamKo,
    homeEmblemUrl: card.homeTeamLogo,
    awayEmblemUrl: card.awayTeamLogo,
    kickoffUtc: kickoffUtc,
    hasAnalysis: card.aiPick?.trim().isNotEmpty == true &&
        leagueSupportsAnalysis('baseball', card.league),
  );
}

bool _soccerHasAnalysis(SoccerAnalysisCard card) {
  final prediction = card.prediction;
  if (prediction == null) return false;

  final direction = prediction.direction?.trim();
  if (direction != null && direction.isNotEmpty) return true;

  final pick = prediction.recommendation?.pick?.trim();
  return pick != null && pick.isNotEmpty;
}
