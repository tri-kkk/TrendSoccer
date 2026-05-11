class FixtureMatchData {
  const FixtureMatchData({
    required this.matchId,
    required this.leagueId,
    required this.leagueName,
    this.leagueLogoUrl,
    required this.homeTeam,
    required this.awayTeam,
    this.homeLogoUrl,
    this.awayLogoUrl,
    required this.status,
    required this.matchTime,
    this.homeScore,
    this.awayScore,
    required this.matchDate,
    required this.sport,
  });

  final String matchId;
  final String leagueId;
  final String leagueName;
  final String? leagueLogoUrl;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final String status;
  final String matchTime;
  final String? homeScore;
  final String? awayScore;
  final DateTime matchDate;
  final String sport;
}

class FixtureLeagueGroup {
  const FixtureLeagueGroup({
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogoUrl,
    required this.matches,
  });

  final String leagueId;
  final String leagueName;
  final String? leagueLogoUrl;
  final List<FixtureMatchData> matches;
}

final List<FixtureMatchData> soccerFixtureDummy = [
  FixtureMatchData(
    matchId: 'sf1',
    leagueId: 'premier_league',
    leagueName: 'EPL',
    homeTeam: 'Arsenal',
    awayTeam: 'Chelsea',
    status: 'scheduled',
    matchTime: '18:30',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf2',
    leagueId: 'premier_league',
    leagueName: 'EPL',
    homeTeam: 'Liverpool',
    awayTeam: 'Man City',
    status: 'live',
    matchTime: '',
    homeScore: '2',
    awayScore: '1',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf3',
    leagueId: 'premier_league',
    leagueName: 'EPL',
    homeTeam: 'Tottenham',
    awayTeam: 'Newcastle',
    status: 'finished',
    matchTime: 'FT',
    homeScore: '3',
    awayScore: '0',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf4',
    leagueId: 'champions_league',
    leagueName: 'UCL',
    homeTeam: 'Barcelona',
    awayTeam: 'Bayern',
    status: 'scheduled',
    matchTime: '21:00',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf5',
    leagueId: 'champions_league',
    leagueName: 'UCL',
    homeTeam: 'Inter',
    awayTeam: 'PSG',
    status: 'scheduled',
    matchTime: '21:00',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf6',
    leagueId: 'laliga',
    leagueName: 'La Liga',
    homeTeam: 'Real Madrid',
    awayTeam: 'Atletico',
    status: 'scheduled',
    matchTime: '22:00',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf7',
    leagueId: 'premier_league',
    leagueName: 'EPL',
    homeTeam: 'Man United',
    awayTeam: 'Everton',
    status: 'finished',
    matchTime: 'FT',
    homeScore: '2',
    awayScore: '2',
    matchDate: DateTime(2026, 5, 10),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf8',
    leagueId: 'bundesliga',
    leagueName: 'Bundesliga',
    homeTeam: 'Bayern',
    awayTeam: 'Dortmund',
    status: 'scheduled',
    matchTime: '20:30',
    matchDate: DateTime(2026, 5, 12),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf9',
    leagueId: 'bundesliga',
    leagueName: 'Bundesliga',
    homeTeam: 'Leipzig',
    awayTeam: 'Leverkusen',
    status: 'scheduled',
    matchTime: '18:00',
    matchDate: DateTime(2026, 5, 12),
    sport: 'soccer',
  ),
];

final List<FixtureMatchData> baseballFixtureDummy = [
  FixtureMatchData(
    matchId: 'bf1',
    leagueId: 'kbo',
    leagueName: 'KBO',
    homeTeam: 'LG Twins',
    awayTeam: 'KT Wiz',
    status: 'live',
    matchTime: '',
    homeScore: '5',
    awayScore: '3',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf2',
    leagueId: 'kbo',
    leagueName: 'KBO',
    homeTeam: 'Samsung',
    awayTeam: 'Doosan',
    status: 'scheduled',
    matchTime: '18:30',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf3',
    leagueId: 'kbo',
    leagueName: 'KBO',
    homeTeam: 'Kiwoom',
    awayTeam: 'Lotte',
    status: 'scheduled',
    matchTime: '18:30',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf4',
    leagueId: 'mlb',
    leagueName: 'MLB',
    homeTeam: 'Yankees',
    awayTeam: 'Red Sox',
    status: 'scheduled',
    matchTime: '08:00',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf5',
    leagueId: 'mlb',
    leagueName: 'MLB',
    homeTeam: 'Dodgers',
    awayTeam: 'Giants',
    status: 'finished',
    matchTime: 'Final',
    homeScore: '7',
    awayScore: '4',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf6',
    leagueId: 'kbo',
    leagueName: 'KBO',
    homeTeam: 'NC',
    awayTeam: 'SSG',
    status: 'finished',
    matchTime: 'Final',
    homeScore: '3',
    awayScore: '6',
    matchDate: DateTime(2026, 5, 10),
    sport: 'baseball',
  ),
];

List<FixtureLeagueGroup> groupByLeague(List<FixtureMatchData> matches) {
  final order = <String>[];
  final byId = <String, List<FixtureMatchData>>{};
  for (final m in matches) {
    if (!byId.containsKey(m.leagueId)) {
      order.add(m.leagueId);
      byId[m.leagueId] = [];
    }
    byId[m.leagueId]!.add(m);
  }
  return [
    for (final id in order)
      FixtureLeagueGroup(
        leagueId: id,
        leagueName: byId[id]!.first.leagueName,
        leagueLogoUrl: byId[id]!.first.leagueLogoUrl,
        matches: byId[id]!,
      ),
  ];
}
