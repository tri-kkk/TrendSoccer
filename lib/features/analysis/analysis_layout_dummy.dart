/// Layout-only dummy soccer matches for Analysis tab UI testing.
/// Set [enabled] to false before release.
abstract final class AnalysisLayoutDummy {
  static const bool enabled = false;

  static List<Map<String, dynamic>> getSoccerMatches(String date) {
    if (!enabled) return [];

    const leagues = [
      'Premier League',
      'La Liga',
      'Bundesliga',
      'Serie A',
      'Champions League',
    ];
    const leagueIcons = [
      'premier_league',
      'la_liga',
      'bundesliga',
      'serie_a',
      'champions_league',
    ];
    const leaguesKo = [
      '프리미어리그',
      '라리가',
      '분데스리가',
      '세리에A',
      '챔피언스리그',
    ];

    return List.generate(5, (i) {
      return {
        'id': '${date}_$i',
        'homeTeam': 'Home Team ${i + 1}',
        'awayTeam': 'Away Team ${i + 1}',
        'homeTeamKo': '홈팀 ${i + 1}',
        'awayTeamKo': '원정팀 ${i + 1}',
        'leagueName': leagues[i],
        'leagueNameKo': leaguesKo[i],
        'leagueCode': leagueIcons[i],
        'matchDate': date,
        'matchTime': '${(18 + i).toString().padLeft(2, '0')}:30',
        'status': 'scheduled',
      };
    });
  }
}
