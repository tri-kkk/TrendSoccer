import 'package:trendsoccer/features/analysis/widgets/baseball/standard/baseball_h2h_section.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/standard/baseball_odds_section.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/standard/starting_pitchers_section.dart';

class BaseballMatchReportData {
  const BaseballMatchReportData({
    required this.matchId,
    required this.leagueId,
    required this.matchDate,
    required this.awayTeam,
    required this.homeTeam,
    this.awayLogoUrl,
    this.homeLogoUrl,
    required this.awayPitcher,
    required this.homePitcher,
    required this.pitcherAnalysisText,
    required this.h2hMatches,
    required this.awayOdds,
    required this.homeOdds,
    required this.ouLines,
    required this.awayWinProb,
    required this.homeWinProb,
    required this.winProbDescription,
    required this.ouBaseLine,
    required this.ouOverOdds,
    required this.ouUnderOdds,
    required this.isFavoredUnder,
    required this.awayRecord,
    required this.homeRecord,
    required this.awayWinRate,
    required this.homeWinRate,
    required this.confidenceLevel,
    required this.runsRatio,
    required this.runsAllowedRatio,
    required this.hitsRatio,
    required this.avgRatio,
    required this.opsRatio,
    required this.eraRatio,
    required this.whipRatio,
  });

  final String matchId;
  final String leagueId;
  final String matchDate;
  final String awayTeam;
  final String homeTeam;
  final String? awayLogoUrl;
  final String? homeLogoUrl;

  final PitcherData awayPitcher;
  final PitcherData homePitcher;

  final String pitcherAnalysisText;

  final List<BaseballH2HMatch> h2hMatches;

  final String awayOdds;
  final String homeOdds;
  final List<BaseballOULine> ouLines;

  final String awayWinProb;
  final String homeWinProb;
  final String winProbDescription;

  final String ouBaseLine;
  final String ouOverOdds;
  final String ouUnderOdds;
  final bool isFavoredUnder;

  final String awayRecord;
  final String homeRecord;

  final String awayWinRate;
  final String homeWinRate;
  final String confidenceLevel;

  final double runsRatio;
  final double runsAllowedRatio;
  final double hitsRatio;

  final double avgRatio;
  final double opsRatio;
  final double eraRatio;
  final double whipRatio;
}

/// Sample report — same content for every [matchId] until API integration.
final BaseballMatchReportData baseballMatchReportDummy = BaseballMatchReportData(
  matchId: 'ba1',
  leagueId: 'kbo',
  matchDate: 'Mon, May 12 18:30',
  awayTeam: 'KT Wiz',
  homeTeam: 'LG Twins',
  awayLogoUrl: null,
  homeLogoUrl: null,
  awayPitcher: PitcherData(
    name: '김선수',
    pitcherType: '우완 투수',
    photoUrl: null,
    era: '3.45',
    whip: '1.12',
    k9: '8.5',
    wl: '5-3',
    ip: '92.1',
    k: '87',
    prevWl: '12-8',
    prevIp: '178.2',
    prevK: '156',
    strengths: ['제구력이 뛰어남', '변화구 다양', '초구 스트라이크 비율 높음'],
    weaknesses: ['좌타자 상대 피안타율 높음', '이닝 후반 구속 저하', '주자 있을 때 피안타율 상승'],
  ),
  homePitcher: PitcherData(
    name: '이선수',
    pitcherType: '좌완 투수',
    photoUrl: null,
    era: '2.89',
    whip: '0.98',
    k9: '9.2',
    wl: '7-2',
    ip: '105.0',
    k: '108',
    prevWl: '10-6',
    prevIp: '165.1',
    prevK: '142',
    strengths: ['패스트볼 구속 우수', '삼진 비율 높음', '홈 경기 ERA 2.1'],
    weaknesses: ['우타자 상대 장타 허용', '볼넷 빈도 증가 추세'],
  ),
  pitcherAnalysisText:
      '홈팀 투수 이선수는 올시즌 ERA 2.89로 리그 상위권 성적을 기록 중입니다. 특히 홈 경기에서 ERA 2.1로 안정적인 모습을 보여주고 있습니다. 반면 원정팀 김선수는 좌타자 상대 피안타율이 높아 LG 좌타 라인업에 취약할 수 있습니다.',
  h2hMatches: [
    BaseballH2HMatch(date: '05.05', homeTeam: 'LG', awayTeam: 'KT', homeScore: 5, awayScore: 3, homeWin: true),
    BaseballH2HMatch(date: '04.28', homeTeam: 'KT', awayTeam: 'LG', homeScore: 2, awayScore: 4, homeWin: false),
    BaseballH2HMatch(date: '04.15', homeTeam: 'LG', awayTeam: 'KT', homeScore: 1, awayScore: 3, homeWin: false),
    BaseballH2HMatch(date: '04.01', homeTeam: 'KT', awayTeam: 'LG', homeScore: 6, awayScore: 7, homeWin: false),
    BaseballH2HMatch(date: '03.25', homeTeam: 'LG', awayTeam: 'KT', homeScore: 8, awayScore: 2, homeWin: true),
  ],
  awayOdds: '2.15',
  homeOdds: '1.75',
  ouLines: [
    BaseballOULine(line: '7.5', over: '1.90', under: '1.90', isBaseLine: false),
    BaseballOULine(line: '8.0', over: '1.85', under: '1.95', isBaseLine: false),
    BaseballOULine(line: '8.5', over: '1.80', under: '2.00', isBaseLine: true),
    BaseballOULine(line: '9.0', over: '1.75', under: '2.05', isBaseLine: false),
    BaseballOULine(line: '9.5', over: '1.70', under: '2.10', isBaseLine: false),
  ],
  awayWinProb: '42%',
  homeWinProb: '58%',
  winProbDescription:
      '홈팀이 투수력과 최근 상대전적에서 우위를 점하고 있어 승리 확률이 높게 산출되었습니다.',
  ouBaseLine: '8.5',
  ouOverOdds: '1.85',
  ouUnderOdds: '1.95',
  isFavoredUnder: true,
  awayRecord: '4승 6패',
  homeRecord: '7승 3패',
  awayWinRate: '40%',
  homeWinRate: '70%',
  confidenceLevel: 'high',
  runsRatio: 0.58,
  runsAllowedRatio: 0.42,
  hitsRatio: 0.55,
  avgRatio: 0.52,
  opsRatio: 0.60,
  eraRatio: 0.62,
  whipRatio: 0.58,
);
