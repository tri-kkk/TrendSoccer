import 'package:trendsoccer/features/trend/trend_dummy_data.dart';

class LeagueFilter {
  final String id;
  final String label;
  final bool hasIcon;

  const LeagueFilter({
    required this.id,
    required this.label,
    this.hasIcon = true,
  });
}

/// Fixed order — do not change.
const soccerLeagueFilters = [
  LeagueFilter(id: 'all', label: '전체', hasIcon: false),
  LeagueFilter(id: 'champions_league', label: '챔피언스리그'),
  LeagueFilter(id: 'europa_league', label: '유로파리그'),
  LeagueFilter(id: 'premier_league', label: '프리미어리그'),
  LeagueFilter(id: 'laliga', label: '라리가'),
  LeagueFilter(id: 'bundesliga', label: '분데스리가'),
  LeagueFilter(id: 'serie_a', label: '세리에A'),
  LeagueFilter(id: 'ligue_1', label: '리그1'),
  LeagueFilter(id: 'eredivisie', label: '에레디비제'),
  LeagueFilter(id: 'k_league', label: 'K리그'),
  LeagueFilter(id: 'j1_league', label: 'J리그'),
  LeagueFilter(id: 'mls', label: 'MLS'),
];

/// Fixed order.
const baseballLeagueFilters = [
  LeagueFilter(id: 'all', label: '전체', hasIcon: false),
  LeagueFilter(id: 'mlb', label: 'MLB'),
  LeagueFilter(id: 'npb', label: 'NPB'),
  LeagueFilter(id: 'kbo', label: 'KBO'),
  LeagueFilter(id: 'cpbl', label: 'CPBL'),
];

/// At least one row per covered league; Korean [leagueName] for card display.
const soccerAnalysisDummy = [
  AnalysisCardData(
    matchId: 'sa1',
    leagueId: 'champions_league',
    leagueName: '챔피언스리그',
    date: '05.11',
    homeTeam: '바르셀로나',
    awayTeam: '바이에른',
    matchTime: '21:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa2',
    leagueId: 'europa_league',
    leagueName: '유로파리그',
    date: '05.11',
    homeTeam: '레버쿠젠',
    awayTeam: 'PSG',
    matchTime: '21:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa3',
    leagueId: 'premier_league',
    leagueName: '프리미어리그',
    date: '05.11',
    homeTeam: '아스날',
    awayTeam: '첼시',
    matchTime: '18:30',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa4',
    leagueId: 'premier_league',
    leagueName: '프리미어리그',
    date: '05.11',
    homeTeam: '리버풀',
    awayTeam: '맨시티',
    matchTime: '21:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa5',
    leagueId: 'laliga',
    leagueName: '라리가',
    date: '05.11',
    homeTeam: '레알 마드리드',
    awayTeam: '아틀레티코',
    matchTime: '22:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa6',
    leagueId: 'bundesliga',
    leagueName: '분데스리가',
    date: '05.12',
    homeTeam: '바이에른',
    awayTeam: '도르트문트',
    matchTime: '20:30',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa7',
    leagueId: 'serie_a',
    leagueName: '세리에A',
    date: '05.11',
    homeTeam: '유벤투스',
    awayTeam: 'AC 밀란',
    matchTime: '19:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa8',
    leagueId: 'ligue_1',
    leagueName: '리그1',
    date: '05.11',
    homeTeam: 'PSG',
    awayTeam: '마르세유',
    matchTime: '21:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa9',
    leagueId: 'eredivisie',
    leagueName: '에레디비제',
    date: '05.11',
    homeTeam: '아약스',
    awayTeam: 'PSV',
    matchTime: '20:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa10',
    leagueId: 'k_league',
    leagueName: 'K리그',
    date: '05.11',
    homeTeam: '울산',
    awayTeam: '전북',
    matchTime: '19:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa11',
    leagueId: 'j1_league',
    leagueName: 'J리그',
    date: '05.11',
    homeTeam: '가와사키',
    awayTeam: '요코하마',
    matchTime: '18:00',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'sa12',
    leagueId: 'mls',
    leagueName: 'MLS',
    date: '05.11',
    homeTeam: 'LA FC',
    awayTeam: 'NY 시티',
    matchTime: '10:00',
    sport: 'soccer',
  ),
];

final baseballAnalysisDummy = [
  // KBO
  AnalysisCardData(
    matchId: 'ba1',
    leagueId: 'kbo',
    leagueName: 'KBO',
    date: '05.11',
    homeTeam: 'LG 트윈스',
    awayTeam: 'KT 위즈',
    matchTime: '18:30',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'ba2',
    leagueId: 'kbo',
    leagueName: 'KBO',
    date: '05.11',
    homeTeam: '삼성',
    awayTeam: '두산',
    matchTime: '18:30',
    sport: 'baseball',
  ),
  // NPB
  AnalysisCardData(
    matchId: 'ba3',
    leagueId: 'npb',
    leagueName: 'NPB',
    date: '05.11',
    homeTeam: '요미우리',
    awayTeam: '한신',
    matchTime: '18:00',
    sport: 'baseball',
  ),
  // MLB
  AnalysisCardData(
    matchId: 'ba4',
    leagueId: 'mlb',
    leagueName: 'MLB',
    date: '05.11',
    homeTeam: '양키스',
    awayTeam: '레드삭스',
    matchTime: '08:00',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'ba5',
    leagueId: 'mlb',
    leagueName: 'MLB',
    date: '05.11',
    homeTeam: '다저스',
    awayTeam: '자이언츠',
    matchTime: '10:00',
    sport: 'baseball',
  ),
  AnalysisCardData(
    matchId: 'ba6',
    leagueId: 'mlb',
    leagueName: 'MLB',
    date: '05.11',
    homeTeam: '메츠',
    awayTeam: '필리스',
    matchTime: '09:00',
    sport: 'baseball',
  ),
  // CPBL
  AnalysisCardData(
    matchId: 'ba7',
    leagueId: 'cpbl',
    leagueName: 'CPBL',
    date: '05.11',
    homeTeam: '라쿠텐',
    awayTeam: '웨이촨',
    matchTime: '18:30',
    sport: 'baseball',
  ),
  // KBO extra
  AnalysisCardData(
    matchId: 'ba8',
    leagueId: 'kbo',
    leagueName: 'KBO',
    date: '05.11',
    homeTeam: '키움',
    awayTeam: '롯데',
    matchTime: '18:30',
    sport: 'baseball',
  ),
];
