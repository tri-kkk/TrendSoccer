import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/features/analysis/models/baseball_standard_parser.dart';

MatchHeaderData matchHeaderFromBaseballStandard(
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
