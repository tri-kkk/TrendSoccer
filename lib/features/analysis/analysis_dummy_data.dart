import 'package:trendsoccer/features/trend/trend_dummy_data.dart';

final List<AnalysisCardData> soccerAnalysisFullDummy = [
  AnalysisCardData(matchId: 'sa1', leagueId: 'epl', leagueName: 'EPL', date: '05.11', homeTeam: 'Arsenal', awayTeam: 'Chelsea', matchTime: '18:30', sport: 'soccer'),
  AnalysisCardData(matchId: 'sa2', leagueId: 'epl', leagueName: 'EPL', date: '05.11', homeTeam: 'Liverpool', awayTeam: 'Man City', matchTime: '21:00', sport: 'soccer'),
  AnalysisCardData(matchId: 'sa3', leagueId: 'ucl', leagueName: 'UCL', date: '05.11', homeTeam: 'Barcelona', awayTeam: 'Bayern', matchTime: '21:00', isPremiumPick: true, pickDirection: 'home', winRate: '72%', sport: 'soccer'),
  AnalysisCardData(matchId: 'sa4', leagueId: 'laliga', leagueName: 'La Liga', date: '05.11', homeTeam: 'Real Madrid', awayTeam: 'Atletico', matchTime: '22:00', sport: 'soccer'),
  AnalysisCardData(matchId: 'sa5', leagueId: 'bundesliga', leagueName: 'Bundesliga', date: '05.11', homeTeam: 'Bayern', awayTeam: 'Dortmund', matchTime: '20:30', sport: 'soccer'),
  AnalysisCardData(matchId: 'sa6', leagueId: 'seriea', leagueName: 'Serie A', date: '05.11', homeTeam: 'Juventus', awayTeam: 'AC Milan', matchTime: '19:00', isPremiumPick: true, pickDirection: 'away', winRate: '65%', sport: 'soccer'),
  AnalysisCardData(matchId: 'sa7', leagueId: 'ligue1', leagueName: 'Ligue 1', date: '05.11', homeTeam: 'PSG', awayTeam: 'Marseille', matchTime: '21:00', sport: 'soccer'),
  AnalysisCardData(matchId: 'sa8', leagueId: 'epl', leagueName: 'EPL', date: '05.11', homeTeam: 'Tottenham', awayTeam: 'Newcastle', matchTime: '16:00', sport: 'soccer'),
  AnalysisCardData(matchId: 'sa9', leagueId: 'ucl', leagueName: 'UCL', date: '05.11', homeTeam: 'Inter', awayTeam: 'PSG', matchTime: '21:00', sport: 'soccer'),
  AnalysisCardData(matchId: 'sa10', leagueId: 'laliga', leagueName: 'La Liga', date: '05.11', homeTeam: 'Sevilla', awayTeam: 'Valencia', matchTime: '20:00', sport: 'soccer'),
];

final List<AnalysisCardData> baseballAnalysisFullDummy = [
  AnalysisCardData(matchId: 'ba1', leagueId: 'kbo', leagueName: 'KBO', date: '05.11', homeTeam: 'LG Twins', awayTeam: 'KT Wiz', matchTime: '18:30', sport: 'baseball'),
  AnalysisCardData(matchId: 'ba2', leagueId: 'kbo', leagueName: 'KBO', date: '05.11', homeTeam: 'Samsung', awayTeam: 'Doosan', matchTime: '18:30', sport: 'baseball'),
  AnalysisCardData(matchId: 'ba3', leagueId: 'kbo', leagueName: 'KBO', date: '05.11', homeTeam: 'Kiwoom', awayTeam: 'Lotte', matchTime: '18:30', sport: 'baseball'),
  AnalysisCardData(matchId: 'ba4', leagueId: 'mlb', leagueName: 'MLB', date: '05.11', homeTeam: 'Yankees', awayTeam: 'Red Sox', matchTime: '08:00', sport: 'baseball'),
  AnalysisCardData(matchId: 'ba5', leagueId: 'mlb', leagueName: 'MLB', date: '05.11', homeTeam: 'Dodgers', awayTeam: 'Giants', matchTime: '10:00', sport: 'baseball'),
  AnalysisCardData(matchId: 'ba6', leagueId: 'npb', leagueName: 'NPB', date: '05.11', homeTeam: 'Giants', awayTeam: 'Tigers', matchTime: '14:00', sport: 'baseball'),
  AnalysisCardData(matchId: 'ba7', leagueId: 'npb', leagueName: 'NPB', date: '05.11', homeTeam: 'Dragons', awayTeam: 'Swallows', matchTime: '14:00', sport: 'baseball'),
  AnalysisCardData(matchId: 'ba8', leagueId: 'cpbl', leagueName: 'CPBL', date: '05.11', homeTeam: 'Brothers', awayTeam: 'Lions', matchTime: '12:00', sport: 'baseball'),
];

final List<Map<String, String>> soccerLeagueFilters = [
  {'id': 'all', 'name': '전체'},
  {'id': 'epl', 'name': 'EPL'},
  {'id': 'ucl', 'name': 'UCL'},
  {'id': 'laliga', 'name': 'La Liga'},
  {'id': 'bundesliga', 'name': 'Bundesliga'},
  {'id': 'seriea', 'name': 'Serie A'},
  {'id': 'ligue1', 'name': 'Ligue 1'},
];

final List<Map<String, String>> baseballLeagueFilters = [
  {'id': 'all', 'name': '전체'},
  {'id': 'kbo', 'name': 'KBO'},
  {'id': 'mlb', 'name': 'MLB'},
  {'id': 'npb', 'name': 'NPB'},
  {'id': 'cpbl', 'name': 'CPBL'},
];
