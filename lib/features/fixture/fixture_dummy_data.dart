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
    leagueName: '프리미어리그',
    homeTeam: '아스날',
    awayTeam: '첼시',
    status: 'scheduled',
    matchTime: '20:30',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf2',
    leagueId: 'premier_league',
    leagueName: '프리미어리그',
    homeTeam: '리버풀',
    awayTeam: '맨시티',
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
    leagueName: '프리미어리그',
    homeTeam: '토트넘',
    awayTeam: '뉴캐슬',
    status: 'finished',
    matchTime: 'FT',
    homeScore: '3',
    awayScore: '0',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf4',
    leagueId: 'laliga',
    leagueName: '라리가',
    homeTeam: '레알 마드리드',
    awayTeam: '아틀레티코',
    status: 'scheduled',
    matchTime: '22:00',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf5',
    leagueId: 'laliga',
    leagueName: '라리가',
    homeTeam: '바르셀로나',
    awayTeam: '세비야',
    status: 'live',
    matchTime: '',
    homeScore: '1',
    awayScore: '0',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf6',
    leagueId: 'laliga',
    leagueName: '라리가',
    homeTeam: '소시에다드',
    awayTeam: '비야레알',
    status: 'finished',
    matchTime: 'FT',
    homeScore: '2',
    awayScore: '2',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf7',
    leagueId: 'europa_league',
    leagueName: '유로파리그',
    homeTeam: '레버쿠젠',
    awayTeam: 'PSG',
    status: 'scheduled',
    matchTime: '21:00',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf8',
    leagueId: 'europa_league',
    leagueName: '유로파리그',
    homeTeam: '아약스',
    awayTeam: '라치오',
    status: 'live',
    matchTime: '',
    homeScore: '0',
    awayScore: '1',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf9',
    leagueId: 'europa_league',
    leagueName: '유로파리그',
    homeTeam: '로마',
    awayTeam: '맨유',
    status: 'finished',
    matchTime: 'FT',
    homeScore: '1',
    awayScore: '3',
    matchDate: DateTime(2026, 5, 11),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf10',
    leagueId: 'bundesliga',
    leagueName: '분데스리가',
    homeTeam: '바이에른',
    awayTeam: '도르트문트',
    status: 'finished',
    matchTime: 'FT',
    homeScore: '2',
    awayScore: '1',
    matchDate: DateTime(2026, 5, 10),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf11',
    leagueId: 'champions_league',
    leagueName: '챔피언스리그',
    homeTeam: '바르셀로나',
    awayTeam: '바이에른',
    status: 'scheduled',
    matchTime: '21:00',
    matchDate: DateTime(2026, 5, 12),
    sport: 'soccer',
  ),
  FixtureMatchData(
    matchId: 'sf12',
    leagueId: 'champions_league',
    leagueName: '챔피언스리그',
    homeTeam: '인테르',
    awayTeam: 'PSG',
    status: 'scheduled',
    matchTime: '21:00',
    matchDate: DateTime(2026, 5, 12),
    sport: 'soccer',
  ),
];

final List<FixtureMatchData> baseballFixtureDummy = [
  FixtureMatchData(
    matchId: 'bf1',
    leagueId: 'kbo',
    leagueName: 'KBO',
    homeTeam: 'LG 트윈스',
    awayTeam: 'KT 위즈',
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
    homeTeam: '삼성',
    awayTeam: '두산',
    status: 'scheduled',
    matchTime: '18:30',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf3',
    leagueId: 'kbo',
    leagueName: 'KBO',
    homeTeam: '키움',
    awayTeam: '롯데',
    status: 'scheduled',
    matchTime: '18:30',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf4',
    leagueId: 'mlb',
    leagueName: 'MLB',
    homeTeam: '양키스',
    awayTeam: '레드삭스',
    status: 'scheduled',
    matchTime: '08:00',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf5',
    leagueId: 'mlb',
    leagueName: 'MLB',
    homeTeam: '다저스',
    awayTeam: '자이언츠',
    status: 'finished',
    matchTime: 'Final',
    homeScore: '7',
    awayScore: '4',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf6',
    leagueId: 'npb',
    leagueName: 'NPB',
    homeTeam: '요미우리',
    awayTeam: '한신',
    status: 'scheduled',
    matchTime: '18:00',
    matchDate: DateTime(2026, 5, 11),
    sport: 'baseball',
  ),
  FixtureMatchData(
    matchId: 'bf7',
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
