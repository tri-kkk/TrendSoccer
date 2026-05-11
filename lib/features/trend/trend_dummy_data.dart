class AnalysisCardData {
  const AnalysisCardData({
    required this.matchId,
    required this.leagueId,
    required this.leagueName,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchTime,
    this.homeLogoUrl,
    this.awayLogoUrl,
    this.isPremiumPick = false,
    this.pickDirection,
    this.winRate,
    required this.sport,
  });

  final String matchId;
  final String leagueId;
  final String leagueName;
  final String date;
  final String homeTeam;
  final String awayTeam;
  final String matchTime;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final bool isPremiumPick;
  /// 'home', 'draw', 'away'
  final String? pickDirection;
  final String? winRate;
  /// 'soccer' or 'baseball'
  final String sport;
}

const List<AnalysisCardData> soccerAnalysisDummy = [
  AnalysisCardData(
    matchId: 's1',
    leagueId: 'epl',
    leagueName: 'EPL',
    date: '05.11',
    homeTeam: 'Arsenal',
    awayTeam: 'Chelsea',
    matchTime: '18:30',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's2',
    leagueId: 'ucl',
    leagueName: 'UCL',
    date: '05.11',
    homeTeam: 'Barcelona',
    awayTeam: 'Bayern',
    matchTime: '21:00',
    isPremiumPick: true,
    pickDirection: 'home',
    winRate: '72%',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's3',
    leagueId: 'laliga',
    leagueName: 'La Liga',
    date: '05.11',
    homeTeam: 'Real Madrid',
    awayTeam: 'Atletico',
    matchTime: '22:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's4',
    leagueId: 'bundesliga',
    leagueName: 'Bundesliga',
    date: '05.11',
    homeTeam: 'Bayern',
    awayTeam: 'Dortmund',
    matchTime: '20:30',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's5',
    leagueId: 'seriea',
    leagueName: 'Serie A',
    date: '05.11',
    homeTeam: 'Juventus',
    awayTeam: 'AC Milan',
    matchTime: '19:00',
    isPremiumPick: true,
    pickDirection: 'away',
    winRate: '65%',
    sport: 'soccer',
  ),
];

const List<AnalysisCardData> baseballAnalysisDummy = [
  AnalysisCardData(
    matchId: 'b1',
    leagueId: 'kbo',
    leagueName: 'KBO',
    date: '05.11',
    homeTeam: 'LG Twins',
    awayTeam: 'KT Wiz',
    matchTime: '18:30',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'b2',
    leagueId: 'mlb',
    leagueName: 'MLB',
    date: '05.11',
    homeTeam: 'Yankees',
    awayTeam: 'Red Sox',
    matchTime: '08:00',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'b3',
    leagueId: 'kbo',
    leagueName: 'KBO',
    date: '05.11',
    homeTeam: 'Samsung',
    awayTeam: 'Doosan',
    matchTime: '18:30',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'b4',
    leagueId: 'npb',
    leagueName: 'NPB',
    date: '05.11',
    homeTeam: 'Giants',
    awayTeam: 'Tigers',
    matchTime: '14:00',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'b5',
    leagueId: 'mlb',
    leagueName: 'MLB',
    date: '05.11',
    homeTeam: 'Dodgers',
    awayTeam: 'Giants',
    matchTime: '10:00',
    sport: 'baseball',
  ),
];
