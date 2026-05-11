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

/// Korean team labels per Trend spec (soccer/baseball mappings).
const List<AnalysisCardData> soccerAnalysisDummy = [
  AnalysisCardData(
    matchId: 's1',
    leagueId: 'epl',
    leagueName: 'EPL',
    date: '05.11',
    homeTeam: '아스날',
    awayTeam: '첼시',
    matchTime: '18:30',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's2',
    leagueId: 'epl',
    leagueName: 'EPL',
    date: '05.11',
    homeTeam: '리버풀',
    awayTeam: '맨시티',
    matchTime: '20:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's3',
    leagueId: 'ucl',
    leagueName: 'UCL',
    date: '05.11',
    homeTeam: '바르셀로나',
    awayTeam: '바이에른',
    matchTime: '21:00',
    isPremiumPick: true,
    pickDirection: 'home',
    winRate: '72%',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's4',
    leagueId: 'laliga',
    leagueName: 'La Liga',
    date: '05.11',
    homeTeam: '레알 마드리드',
    awayTeam: '아틀레티코',
    matchTime: '22:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's5',
    leagueId: 'bundesliga',
    leagueName: 'Bundesliga',
    date: '05.11',
    homeTeam: '도르트문트',
    awayTeam: '레버쿠젠',
    matchTime: '20:30',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's6',
    leagueId: 'seriea',
    leagueName: 'Serie A',
    date: '05.11',
    homeTeam: '유벤투스',
    awayTeam: '인테르',
    matchTime: '19:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's7',
    leagueId: 'seriea',
    leagueName: 'Serie A',
    date: '05.11',
    homeTeam: '인테르',
    awayTeam: 'AC 밀란',
    matchTime: '21:45',
    isPremiumPick: true,
    pickDirection: 'away',
    winRate: '65%',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's8',
    leagueId: 'ucl',
    leagueName: 'UCL',
    date: '05.11',
    homeTeam: 'PSG',
    awayTeam: '도르트문트',
    matchTime: '23:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's9',
    leagueId: 'epl',
    leagueName: 'EPL',
    date: '05.11',
    homeTeam: '토트넘',
    awayTeam: '뉴캐슬',
    matchTime: '17:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's10',
    leagueId: 'epl',
    leagueName: 'EPL',
    date: '05.11',
    homeTeam: '맨유',
    awayTeam: '에버턴',
    matchTime: '15:30',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 's11',
    leagueId: 'bundesliga',
    leagueName: 'Bundesliga',
    date: '05.11',
    homeTeam: '라이프치히',
    awayTeam: '바이에른',
    matchTime: '19:30',
    sport: 'soccer',
  ),
];

const List<AnalysisCardData> baseballAnalysisDummy = [
  AnalysisCardData(
    matchId: 'b1',
    leagueId: 'kbo',
    leagueName: 'KBO',
    date: '05.11',
    homeTeam: 'LG 트윈스',
    awayTeam: 'KT 위즈',
    matchTime: '18:30',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'b2',
    leagueId: 'kbo',
    leagueName: 'KBO',
    date: '05.11',
    homeTeam: '삼성',
    awayTeam: '두산',
    matchTime: '18:30',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'b3',
    leagueId: 'kbo',
    leagueName: 'KBO',
    date: '05.11',
    homeTeam: '키움',
    awayTeam: '롯데',
    matchTime: '17:00',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'b4',
    leagueId: 'kbo',
    leagueName: 'KBO',
    date: '05.11',
    homeTeam: 'NC',
    awayTeam: 'SSG',
    matchTime: '18:00',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'b5',
    leagueId: 'mlb',
    leagueName: 'MLB',
    date: '05.11',
    homeTeam: '양키스',
    awayTeam: '레드삭스',
    matchTime: '08:00',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'b6',
    leagueId: 'mlb',
    leagueName: 'MLB',
    date: '05.11',
    homeTeam: '다저스',
    awayTeam: '자이언츠',
    matchTime: '10:00',
    sport: 'baseball',
  ),
];
