class SoccerMatchReportData {
  const SoccerMatchReportData({
    required this.matchId,
    required this.leagueId,
    required this.matchDate,
    required this.homeTeam,
    required this.awayTeam,
    this.homeLogoUrl,
    this.awayLogoUrl,
    required this.prediction,
    required this.winProbability,
    required this.powerDiff,
    required this.analyzedMatches,
    required this.patternStats,
    required this.gradeBadge,
    required this.reasoningItems,
    required this.homeOdds,
    required this.drawOdds,
    required this.awayOdds,
    required this.homePowerRatio,
    required this.homeProb,
    required this.drawProb,
    required this.awayProb,
    required this.teamStats,
    required this.paResult,
    required this.minMaxResult,
    required this.firstGoalResult,
    required this.h2hHomeWins,
    required this.h2hDraws,
    required this.h2hAwayWins,
    required this.h2hMatches,
    required this.homeAnalysis,
    required this.awayAnalysis,
  });

  final String matchId;
  final String leagueId;
  final String matchDate;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;

  final String prediction;
  final String winProbability;
  final String powerDiff;
  final String analyzedMatches;
  final String patternStats;
  final String gradeBadge;

  final List<String> reasoningItems;

  final String homeOdds;
  final String drawOdds;
  final String awayOdds;

  final double homePowerRatio;

  final double homeProb;
  final double drawProb;
  final double awayProb;

  final List<TeamStatItemData> teamStats;

  final String paResult;
  final String minMaxResult;
  final String firstGoalResult;

  final int h2hHomeWins;
  final int h2hDraws;
  final int h2hAwayWins;
  final List<H2HMatchItemData> h2hMatches;

  final TeamAnalysisData homeAnalysis;
  final TeamAnalysisData awayAnalysis;
}

class TeamStatItemData {
  const TeamStatItemData({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    required this.homeDisplay,
    required this.awayDisplay,
  });

  final String label;
  final double homeValue;
  final double awayValue;
  final String homeDisplay;
  final String awayDisplay;
}

class H2HMatchItemData {
  const H2HMatchItemData({
    required this.result,
    required this.score,
  });

  final String result;
  final String score;
}

class TeamAnalysisData {
  const TeamAnalysisData({
    required this.teamName,
    required this.overallForm,
    required this.homeAwayForm,
    required this.goalStats,
    required this.recentResults,
    required this.strengthText,
    required this.weaknessText,
  });

  final String teamName;
  final String overallForm;
  final String homeAwayForm;
  final String goalStats;
  final String recentResults;
  final String strengthText;
  final String weaknessText;
}

/// Sample report — shown for every [matchId] until API integration.
final SoccerMatchReportData soccerMatchReportDummy = SoccerMatchReportData(
  matchId: 'sa3',
  leagueId: 'champions_league',
  matchDate: 'Mon, May 12 21:00',
  homeTeam: 'Barcelona',
  awayTeam: 'Bayern Munich',
  homeLogoUrl: null,
  awayLogoUrl: null,
  prediction: '홈 승',
  winProbability: '68%',
  powerDiff: '44 pts',
  analyzedMatches: '3,839',
  patternStats: '1-3-2',
  gradeBadge: 'pick',
  reasoningItems: [
    '홈팀의 최근 10경기 승률이 80%로 원정팀 대비 우위',
    '선제골 확률이 홈팀 65%로 높은 선제공격 기대',
    '상대전적 5경기 중 3승으로 심리적 우위 보유',
  ],
  homeOdds: '1.85',
  drawOdds: '3.40',
  awayOdds: '4.20',
  homePowerRatio: 0.62,
  homeProb: 0.45,
  drawProb: 0.25,
  awayProb: 0.30,
  teamStats: [
    TeamStatItemData(label: '승리', homeValue: 8, awayValue: 5, homeDisplay: '8', awayDisplay: '5'),
    TeamStatItemData(label: '무승부', homeValue: 3, awayValue: 3, homeDisplay: '3', awayDisplay: '3'),
    TeamStatItemData(label: '패배', homeValue: 2, awayValue: 5, homeDisplay: '2', awayDisplay: '5'),
    TeamStatItemData(label: '득점', homeValue: 24, awayValue: 18, homeDisplay: '24', awayDisplay: '18'),
  ],
  paResult: '홈 승',
  minMaxResult: '홈 승',
  firstGoalResult: '홈',
  h2hHomeWins: 3,
  h2hDraws: 1,
  h2hAwayWins: 1,
  h2hMatches: [
    H2HMatchItemData(result: 'win', score: '3-1'),
    H2HMatchItemData(result: 'lose', score: '0-2'),
    H2HMatchItemData(result: 'win', score: '2-1'),
    H2HMatchItemData(result: 'draw', score: '1-1'),
    H2HMatchItemData(result: 'win', score: '1-0'),
  ],
  homeAnalysis: TeamAnalysisData(
    teamName: 'Barcelona 분석',
    overallForm: 'W W D L W — 최근 5경기 3승 1무 1패',
    homeAwayForm: '홈 4승 1무 — 홈 경기 강세',
    goalStats: '평균 2.4골 득점 / 0.8골 실점',
    recentResults: 'UCL 조별 4승 2무, La Liga 10연승',
    strengthText: '안정적인 볼 점유율과 빠른 역습 전환. 중앙 미드필드 장악력이 뛰어나며 세트피스 득점력 우수.',
    weaknessText: '후반 체력 저하 시 수비 라인 간격 벌어지는 경향. 원정 경기 대비 홈에서 더 안정적.',
  ),
  awayAnalysis: TeamAnalysisData(
    teamName: 'Bayern Munich 분석',
    overallForm: 'L W W D L — 최근 5경기 2승 1무 2패',
    homeAwayForm: '원정 2승 2패 1무 — 원정 불안정',
    goalStats: '평균 1.8골 득점 / 1.2골 실점',
    recentResults: 'UCL 조별 3승 1무 2패, Bundesliga 최근 3경기 1승 2패',
    strengthText: '높은 프레싱과 측면 공격 위력. 개인 돌파력이 뛰어난 공격진 보유.',
    weaknessText: '수비 전환 속도 느리고 세트피스 실점 빈도 높음. 최근 원정 경기 부진.',
  ),
);
