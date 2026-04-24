import '../../core/models/fixture_models.dart';

/// Placeholder league/team images (replace when API is wired).
const String kFixturePlaceholderLogo =
    'https://placehold.co/32x32/212726/AACBC4/png';

DateTime _anchorDay() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _onDay(DateTime day, int hour, int minute) =>
    DateTime(day.year, day.month, day.day, hour, minute);

FixtureMatch _match({
  required String matchId,
  required String leagueId,
  required String leagueName,
  required String home,
  required String away,
  required String status,
  required DateTime matchDateTime,
  int? homeScore,
  int? awayScore,
}) {
  return FixtureMatch(
    matchId: matchId,
    leagueId: leagueId,
    leagueName: leagueName,
    leagueLogoUrl: kFixturePlaceholderLogo,
    homeTeam: FixtureTeam(name: home, logoUrl: kFixturePlaceholderLogo),
    awayTeam: FixtureTeam(name: away, logoUrl: kFixturePlaceholderLogo),
    matchDateTime: matchDateTime,
    status: status,
    homeScore: homeScore,
    awayScore: awayScore,
  );
}

/// Five leagues, 15 matches — spread across [yesterday, today, tomorrow], varied times, includes live.
List<FixtureLeague> dummySoccerFixtureLeagues() {
  final today = _anchorDay();
  final y = today.subtract(const Duration(days: 1));
  final tm = today.add(const Duration(days: 1));

  return [
    FixtureLeague(
      leagueId: 'ucl',
      leagueName: 'Champions League',
      logoUrl: kFixturePlaceholderLogo,
      matches: [
        _match(
          matchId: 'soc-ucl-1',
          leagueId: 'ucl',
          leagueName: 'Champions League',
          home: 'Arsenal',
          away: 'Bayern',
          status: 'scheduled',
          matchDateTime: _onDay(y, 12, 30),
        ),
        _match(
          matchId: 'soc-ucl-2',
          leagueId: 'ucl',
          leagueName: 'Champions League',
          home: 'Real Madrid',
          away: 'Man City',
          status: 'live',
          matchDateTime: _onDay(today, 21, 0),
          homeScore: 1,
          awayScore: 1,
        ),
        _match(
          matchId: 'soc-ucl-3',
          leagueId: 'ucl',
          leagueName: 'Champions League',
          home: 'Inter',
          away: 'Atletico',
          status: 'finished',
          matchDateTime: _onDay(tm, 16, 45),
          homeScore: 2,
          awayScore: 0,
        ),
      ],
    ),
    FixtureLeague(
      leagueId: 'uel',
      leagueName: 'Europa League',
      logoUrl: kFixturePlaceholderLogo,
      matches: [
        _match(
          matchId: 'soc-uel-1',
          leagueId: 'uel',
          leagueName: 'Europa League',
          home: 'Liverpool',
          away: 'Lyon',
          status: 'finished',
          matchDateTime: _onDay(y, 20, 0),
          homeScore: 3,
          awayScore: 1,
        ),
        _match(
          matchId: 'soc-uel-2',
          leagueId: 'uel',
          leagueName: 'Europa League',
          home: 'Roma',
          away: 'Ajax',
          status: 'scheduled',
          matchDateTime: _onDay(today, 14, 15),
        ),
        _match(
          matchId: 'soc-uel-3',
          leagueId: 'uel',
          leagueName: 'Europa League',
          home: 'Villarreal',
          away: 'PAOK',
          status: 'live',
          matchDateTime: _onDay(tm, 19, 30),
          homeScore: 0,
          awayScore: 0,
        ),
      ],
    ),
    FixtureLeague(
      leagueId: 'epl',
      leagueName: 'Premier League',
      logoUrl: kFixturePlaceholderLogo,
      matches: [
        _match(
          matchId: 'soc-epl-1',
          leagueId: 'epl',
          leagueName: 'Premier League',
          home: 'Chelsea',
          away: 'Liverpool',
          status: 'scheduled',
          matchDateTime: _onDay(y, 8, 45),
        ),
        _match(
          matchId: 'soc-epl-2',
          leagueId: 'epl',
          leagueName: 'Premier League',
          home: 'Tottenham',
          away: 'Newcastle',
          status: 'live',
          matchDateTime: _onDay(today, 16, 0),
          homeScore: 0,
          awayScore: 2,
        ),
        _match(
          matchId: 'soc-epl-3',
          leagueId: 'epl',
          leagueName: 'Premier League',
          home: 'Man United',
          away: 'Brighton',
          status: 'finished',
          matchDateTime: _onDay(tm, 12, 0),
          homeScore: 3,
          awayScore: 1,
        ),
      ],
    ),
    FixtureLeague(
      leagueId: 'laliga',
      leagueName: 'La Liga',
      logoUrl: kFixturePlaceholderLogo,
      matches: [
        _match(
          matchId: 'soc-ll-1',
          leagueId: 'laliga',
          leagueName: 'La Liga',
          home: 'Barcelona',
          away: 'Getafe',
          status: 'finished',
          matchDateTime: _onDay(y, 16, 15),
          homeScore: 2,
          awayScore: 1,
        ),
        _match(
          matchId: 'soc-ll-2',
          leagueId: 'laliga',
          leagueName: 'La Liga',
          home: 'Atletico',
          away: 'Sevilla',
          status: 'scheduled',
          matchDateTime: _onDay(today, 10, 0),
        ),
        _match(
          matchId: 'soc-ll-3',
          leagueId: 'laliga',
          leagueName: 'La Liga',
          home: 'Real Madrid',
          away: 'Valencia',
          status: 'finished',
          matchDateTime: _onDay(tm, 22, 0),
          homeScore: 4,
          awayScore: 2,
        ),
      ],
    ),
    FixtureLeague(
      leagueId: 'bundesliga',
      leagueName: 'Bundesliga',
      logoUrl: kFixturePlaceholderLogo,
      matches: [
        _match(
          matchId: 'soc-bl-1',
          leagueId: 'bundesliga',
          leagueName: 'Bundesliga',
          home: 'Bayern',
          away: 'Wolfsburg',
          status: 'live',
          matchDateTime: _onDay(y, 19, 30),
          homeScore: 1,
          awayScore: 0,
        ),
        _match(
          matchId: 'soc-bl-2',
          leagueId: 'bundesliga',
          leagueName: 'Bundesliga',
          home: 'Dortmund',
          away: 'Leipzig',
          status: 'scheduled',
          matchDateTime: _onDay(today, 18, 30),
        ),
        _match(
          matchId: 'soc-bl-3',
          leagueId: 'bundesliga',
          leagueName: 'Bundesliga',
          home: 'Leverkusen',
          away: 'Frankfurt',
          status: 'finished',
          matchDateTime: _onDay(today, 11, 30),
          homeScore: 1,
          awayScore: 1,
        ),
      ],
    ),
  ];
}

/// Four leagues, 12 matches.
List<FixtureLeague> dummyBaseballFixtureLeagues() {
  final today = _anchorDay();
  final y = today.subtract(const Duration(days: 1));
  final tm = today.add(const Duration(days: 1));

  return [
    FixtureLeague(
      leagueId: 'kbo',
      leagueName: 'KBO',
      logoUrl: kFixturePlaceholderLogo,
      matches: [
        _match(
          matchId: 'bb-kbo-1',
          leagueId: 'kbo',
          leagueName: 'KBO',
          home: 'Doosan Bears',
          away: 'Samsung Lions',
          status: 'scheduled',
          matchDateTime: _onDay(today, 18, 30),
        ),
        _match(
          matchId: 'bb-kbo-2',
          leagueId: 'kbo',
          leagueName: 'KBO',
          home: 'LG Twins',
          away: 'SSG Landers',
          status: 'live',
          matchDateTime: _onDay(y, 19, 0),
          homeScore: 3,
          awayScore: 3,
        ),
        _match(
          matchId: 'bb-kbo-3',
          leagueId: 'kbo',
          leagueName: 'KBO',
          home: 'Kiwoom Heroes',
          away: 'NC Dinos',
          status: 'finished',
          matchDateTime: _onDay(tm, 14, 0),
          homeScore: 5,
          awayScore: 2,
        ),
      ],
    ),
    FixtureLeague(
      leagueId: 'mlb',
      leagueName: 'MLB',
      logoUrl: kFixturePlaceholderLogo,
      matches: [
        _match(
          matchId: 'bb-mlb-1',
          leagueId: 'mlb',
          leagueName: 'MLB',
          home: 'Yankees',
          away: 'Red Sox',
          status: 'finished',
          matchDateTime: _onDay(y, 1, 5),
          homeScore: 4,
          awayScore: 2,
        ),
        _match(
          matchId: 'bb-mlb-2',
          leagueId: 'mlb',
          leagueName: 'MLB',
          home: 'Dodgers',
          away: 'Padres',
          status: 'live',
          matchDateTime: _onDay(today, 22, 10),
          homeScore: 2,
          awayScore: 4,
        ),
        _match(
          matchId: 'bb-mlb-3',
          leagueId: 'mlb',
          leagueName: 'MLB',
          home: 'Cubs',
          away: 'Cardinals',
          status: 'scheduled',
          matchDateTime: _onDay(tm, 20, 5),
        ),
      ],
    ),
    FixtureLeague(
      leagueId: 'npb',
      leagueName: 'NPB',
      logoUrl: kFixturePlaceholderLogo,
      matches: [
        _match(
          matchId: 'bb-npb-1',
          leagueId: 'npb',
          leagueName: 'NPB',
          home: 'Giants',
          away: 'Swallows',
          status: 'scheduled',
          matchDateTime: _onDay(today, 18, 0),
        ),
        _match(
          matchId: 'bb-npb-2',
          leagueId: 'npb',
          leagueName: 'NPB',
          home: 'Dragons',
          away: 'Tigers',
          status: 'finished',
          matchDateTime: _onDay(y, 15, 0),
          homeScore: 0,
          awayScore: 1,
        ),
        _match(
          matchId: 'bb-npb-3',
          leagueId: 'npb',
          leagueName: 'NPB',
          home: 'Hawks',
          away: 'Buffaloes',
          status: 'live',
          matchDateTime: _onDay(tm, 14, 0),
          homeScore: 1,
          awayScore: 0,
        ),
      ],
    ),
    FixtureLeague(
      leagueId: 'cpbl',
      leagueName: 'CPBL',
      logoUrl: kFixturePlaceholderLogo,
      matches: [
        _match(
          matchId: 'bb-cpbl-1',
          leagueId: 'cpbl',
          leagueName: 'CPBL',
          home: 'Monkeys',
          away: 'Brothers',
          status: 'finished',
          matchDateTime: _onDay(today, 17, 0),
          homeScore: 3,
          awayScore: 2,
        ),
        _match(
          matchId: 'bb-cpbl-2',
          leagueId: 'cpbl',
          leagueName: 'CPBL',
          home: 'Guardians',
          away: 'Lions',
          status: 'scheduled',
          matchDateTime: _onDay(y, 16, 35),
        ),
        _match(
          matchId: 'bb-cpbl-3',
          leagueId: 'cpbl',
          leagueName: 'CPBL',
          home: 'Dragons',
          away: 'Uni-Lions',
          status: 'finished',
          matchDateTime: _onDay(tm, 16, 5),
          homeScore: 6,
          awayScore: 1,
        ),
      ],
    ),
  ];
}
