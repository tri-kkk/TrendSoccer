import 'package:trendsoccer/features/analysis/widgets/baseball/premium/team_stat_gauge_card.dart';
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
    required this.pitcherAnalysis,
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
    required this.teamProduction,
    required this.teamProductionComment,
    required this.seasonTeamStats,
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

  final List<String> pitcherAnalysis;

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

  final List<GaugeData> teamProduction;
  final String teamProductionComment;
  final List<GaugeData> seasonTeamStats;
}

/// Sample report — same content for every [matchId] until API integration.
final BaseballMatchReportData baseballMatchReportDummy = BaseballMatchReportData(
  matchId: 'ba1',
  leagueId: 'kbo',
  matchDate: '5월 12일 월요일 18:30',
  awayTeam: 'KT 위즈',
  homeTeam: 'LG 트윈스',
  awayLogoUrl: null,
  homeLogoUrl: null,
  awayPitcher: PitcherData(
    name: '김선수',
    pitcherType: '우완 투수',
    era: '3.45',
    whip: '1.12',
    k9: '8.5',
    wl: '5-3',
    ip: '92.1',
    k: '87',
    prevWl: '12-8',
    prevIp: '178.2',
    prevK: '156',
    strengths: ['제구력 우수', '변화구 다양', '좌타자 상대 강함'],
    weaknesses: ['우타자 상대 약함', '이닝 소화력 부족', '초구 스트라이크율 낮음'],
  ),
  homePitcher: PitcherData(
    name: '이선수',
    pitcherType: '좌완 투수',
    era: '2.89',
    whip: '0.98',
    k9: '9.2',
    wl: '7-2',
    ip: '105.0',
    k: '108',
    prevWl: '10-6',
    prevIp: '165.1',
    prevK: '142',
    strengths: ['패스트볼 위력', '삼진 능력 우수', '홈 구장 적응력'],
    weaknesses: ['컨트롤 불안정', '주자 허용 시 실점'],
  ),
  pitcherAnalysis: [
    '김광현(ERA 3.12, WHIP 1.15)은 62.0IP에서 58K를 기록하며 안정적인 투구를 보여주고 있으며, 문동주(ERA 4.28, WHIP 1.42)는 48.0IP에서 41K로 탈삼진 능력은 있으나 제구력이 다소 불안정하다.',
    'LG 트윈스 선발진의 우위가 뚜렷하며, 김광현의 1.15 WHIP은 주자 허용을 효과적으로 제한하는 반면 문동주의 1.42 WHIP은 상대팀에게 더 많은 공략 기회를 제공한다.',
    'KT 위즈 타선이 김광현의 변화구 조합을 어떻게 공략하고, 문동주가 초반 이닝을 안정적으로 소화할 수 있는지가 승부의 관건이 될 것이다.',
  ],
  h2hMatches: [
    BaseballH2HMatch(
      date: '05.05',
      awayTeam: 'KT 위즈',
      homeTeam: 'LG 트윈스',
      score: '5-3',
      winner: BaseballH2HWinner.away,
    ),
    BaseballH2HMatch(
      date: '04.28',
      awayTeam: 'KT 위즈',
      homeTeam: 'LG 트윈스',
      score: '2-4',
      winner: BaseballH2HWinner.home,
    ),
    BaseballH2HMatch(
      date: '04.21',
      awayTeam: 'KT 위즈',
      homeTeam: 'LG 트윈스',
      score: '3-1',
      winner: BaseballH2HWinner.away,
    ),
    BaseballH2HMatch(
      date: '04.14',
      awayTeam: 'KT 위즈',
      homeTeam: 'LG 트윈스',
      score: '6-2',
      winner: BaseballH2HWinner.away,
    ),
    BaseballH2HMatch(
      date: '04.07',
      awayTeam: 'KT 위즈',
      homeTeam: 'LG 트윈스',
      score: '7-3',
      winner: BaseballH2HWinner.away,
    ),
  ],
  awayOdds: '2.15',
  homeOdds: '1.75',
  ouLines: [
    BaseballOULine(line: '7.5', over: '1.81', under: '2.06', isBaseLine: false),
    BaseballOULine(line: '8', over: '1.96', under: '1.91', isBaseLine: true),
    BaseballOULine(line: '8.5', over: '2.12', under: '1.77', isBaseLine: false),
  ],
  awayWinProb: '42%',
  homeWinProb: '58%',
  winProbDescription:
      '홈팀이 투수력과 최근 상대전적에서 우위를 점하고 있어 승리 가능성이 높게 산출되었습니다.',
  ouBaseLine: '8',
  ouOverOdds: '1.96',
  ouUnderOdds: '1.91',
  isFavoredUnder: true,
  awayRecord: '4승 6패',
  homeRecord: '7승 3패',
  awayWinRate: '40%',
  homeWinRate: '70%',
  confidenceLevel: 'high',
  teamProduction: [
    const GaugeData(label: '득점', homeValue: '4.9', awayValue: '4.0', homeRatio: 0.55),
    const GaugeData(
      label: '실점',
      homeValue: '4.2',
      awayValue: '7.2',
      homeRatio: 0.37,
    ),
    const GaugeData(label: '안타', homeValue: '9.2', awayValue: '8.4', homeRatio: 0.52),
  ],
  teamProductionComment: '최근 10경기 팀 공격 생산성 지표입니다.',
  seasonTeamStats: [
    const GaugeData(label: '팀 타율', homeValue: '0.250', awayValue: '0.249', homeRatio: 0.50),
    const GaugeData(label: '팀 OPS', homeValue: '0.719', awayValue: '0.727', homeRatio: 0.50),
    const GaugeData(
      label: '팀 방어율',
      homeValue: '4.84',
      awayValue: '3.73',
      homeRatio: 0.44,
    ),
    const GaugeData(
      label: '팀 WHIP',
      homeValue: '1.42',
      awayValue: '1.23',
      homeRatio: 0.46,
    ),
  ],
);
