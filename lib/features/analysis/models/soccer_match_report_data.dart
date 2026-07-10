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
    required this.paHomeRatio,
    required this.paAwayRatio,
    required this.minMaxHomeRatio,
    required this.minMaxAwayRatio,
    required this.firstGoalHomeRatio,
    required this.firstGoalAwayRatio,
    required this.h2hHomeWins,
    required this.h2hDraws,
    required this.h2hAwayWins,
    required this.h2hTotalMatches,
    required this.h2hMatches,
    required this.h2hAvgGoals,
    required this.h2hOver25,
    required this.h2hOver25Highlight,
    required this.h2hBtts,
    required this.h2hMostCommonScores,
    required this.h2hInsights,
    required this.homeTeamAnalysis,
    required this.awayTeamAnalysis,
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

  /// P/A 분석 — 홈·원정 비중 (합 ≈ 1)
  final double paHomeRatio;
  final double paAwayRatio;

  /// Min-Max — 홈·원정 비중
  final double minMaxHomeRatio;
  final double minMaxAwayRatio;

  /// 선제골 — 홈·원정 비중
  final double firstGoalHomeRatio;
  final double firstGoalAwayRatio;

  final int h2hHomeWins;
  final int h2hDraws;
  final int h2hAwayWins;
  final int h2hTotalMatches;
  final List<H2HMatchItemData> h2hMatches;

  final String h2hAvgGoals;
  final String h2hOver25;
  final bool h2hOver25Highlight;
  final String h2hBtts;
  final List<MostCommonScoreData> h2hMostCommonScores;
  final List<String> h2hInsights;

  final TeamAnalysisPremiumData homeTeamAnalysis;
  final TeamAnalysisPremiumData awayTeamAnalysis;
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

class MostCommonScoreData {
  const MostCommonScoreData({
    required this.count,
    required this.score,
  });

  final int count;
  final String score;
}

class TeamAnalysisPremiumData {
  const TeamAnalysisPremiumData({
    required this.wins10,
    required this.draws10,
    required this.losses10,
    required this.recentForm,
    required this.recordWins,
    required this.recordDraws,
    required this.recordLosses,
    required this.winRate,
    required this.goalLineO15,
    required this.goalLineO15Highlight,
    required this.goalLineO25,
    required this.goalLineO25Highlight,
    required this.goalLineO35,
    this.goalLineO35Highlight = false,
    required this.marketO25,
    required this.marketO25Highlight,
    required this.marketBtts,
    required this.marketBttsHighlight,
    required this.marketCs,
    required this.marketFts,
    required this.insights,
  });

  final int wins10;
  final int draws10;
  final int losses10;
  final List<H2HMatchItemData> recentForm;
  final String recordWins;
  final String recordDraws;
  final String recordLosses;
  final String winRate;
  final String goalLineO15;
  final bool goalLineO15Highlight;
  final String goalLineO25;
  final bool goalLineO25Highlight;
  final String goalLineO35;
  final bool goalLineO35Highlight;
  final String marketO25;
  final bool marketO25Highlight;
  final String marketBtts;
  final bool marketBttsHighlight;
  final String marketCs;
  final String marketFts;
  final List<String> insights;
}

/// 샘플 리포트 — API 연동 전까지 모든 [matchId]에 표시.
final SoccerMatchReportData soccerMatchReportDummy = SoccerMatchReportData(
  matchId: 'sa3',
  leagueId: 'champions_league',
  matchDate: '5월 12일 월요일 21:00',
  homeTeam: '바르셀로나',
  awayTeam: '바이에른',
  homeLogoUrl: null,
  awayLogoUrl: null,
  prediction: '홈 승',
  winProbability: '68%',
  powerDiff: '44 pts',
  analyzedMatches: '3,839',
  patternStats: '1-3-2',
  gradeBadge: 'pick',
  reasoningItems: [
    '홈팀 최근 10경기 전력 분석 80%로 원정팀 대비 파워차 우위',
    '선제골 확률 홈팀 65%로 선취득점 기대가 높음',
    '상대전적 최근 5경기 3승으로 승리 패턴·확률 우위',
  ],
  homeOdds: '1.85',
  drawOdds: '3.40',
  awayOdds: '4.20',
  homePowerRatio: 0.62,
  homeProb: 0.45,
  drawProb: 0.25,
  awayProb: 0.30,
  teamStats: [
    TeamStatItemData(
      label: '승리',
      homeValue: 8,
      awayValue: 5,
      homeDisplay: '8',
      awayDisplay: '5',
    ),
    TeamStatItemData(
      label: '무승부',
      homeValue: 3,
      awayValue: 3,
      homeDisplay: '3',
      awayDisplay: '3',
    ),
    TeamStatItemData(
      label: '패배',
      homeValue: 2,
      awayValue: 5,
      homeDisplay: '2',
      awayDisplay: '5',
    ),
    TeamStatItemData(
      label: '득점',
      homeValue: 24,
      awayValue: 18,
      homeDisplay: '24',
      awayDisplay: '18',
    ),
  ],
  paResult: '홈 승',
  minMaxResult: '홈 승',
  firstGoalResult: '홈',
  paHomeRatio: 0.58,
  paAwayRatio: 0.42,
  minMaxHomeRatio: 0.55,
  minMaxAwayRatio: 0.45,
  firstGoalHomeRatio: 0.52,
  firstGoalAwayRatio: 0.48,
  h2hHomeWins: 12,
  h2hDraws: 4,
  h2hAwayWins: 4,
  h2hTotalMatches: 20,
  h2hMatches: [
    H2HMatchItemData(result: 'win', score: '1-0'),
    H2HMatchItemData(result: 'draw', score: '1-1'),
    H2HMatchItemData(result: 'lose', score: '0-1'),
    H2HMatchItemData(result: 'draw', score: '1-1'),
    H2HMatchItemData(result: 'lose', score: '0-1'),
  ],
  h2hAvgGoals: '2.7',
  h2hOver25: '60%',
  h2hOver25Highlight: true,
  h2hBtts: '30%',
  h2hMostCommonScores: [
    MostCommonScoreData(count: 7, score: '1 - 0'),
    MostCommonScoreData(count: 2, score: '0 - 2'),
    MostCommonScoreData(count: 2, score: '4 - 0'),
  ],
  h2hInsights: [
    '최근 5경기 중 3경기 홈팀 승리',
    '평균 득점 2.7골로 높은 편',
    '고득점 2.5 확률 60%로 공격적 경기 분석',
  ],
  homeTeamAnalysis: TeamAnalysisPremiumData(
    wins10: 6,
    draws10: 2,
    losses10: 2,
    recentForm: [
      H2HMatchItemData(result: 'win', score: '1-0'),
      H2HMatchItemData(result: 'win', score: '2-1'),
      H2HMatchItemData(result: 'draw', score: '0-0'),
      H2HMatchItemData(result: 'lose', score: '0-1'),
      H2HMatchItemData(result: 'win', score: '3-0'),
    ],
    recordWins: '2',
    recordDraws: '3',
    recordLosses: '5',
    winRate: '30%',
    goalLineO15: '90%',
    goalLineO15Highlight: true,
    goalLineO25: '50%',
    goalLineO25Highlight: true,
    goalLineO35: '40%',
    marketO25: '70%',
    marketO25Highlight: true,
    marketBtts: '80%',
    marketBttsHighlight: true,
    marketCs: '10%',
    marketFts: '20%',
    insights: [
      '홈에서 최근 10경기 중 6승 기록',
      '홈 평균 득점 2.1골',
      '세트피스 득점력 리그 상위',
    ],
  ),
  awayTeamAnalysis: TeamAnalysisPremiumData(
    wins10: 4,
    draws10: 3,
    losses10: 3,
    recentForm: [
      H2HMatchItemData(result: 'win', score: '2-0'),
      H2HMatchItemData(result: 'lose', score: '1-2'),
      H2HMatchItemData(result: 'draw', score: '1-1'),
      H2HMatchItemData(result: 'win', score: '3-1'),
      H2HMatchItemData(result: 'lose', score: '0-2'),
    ],
    recordWins: '3',
    recordDraws: '2',
    recordLosses: '5',
    winRate: '35%',
    goalLineO15: '78%',
    goalLineO15Highlight: true,
    goalLineO25: '45%',
    goalLineO25Highlight: true,
    goalLineO35: '28%',
    marketO25: '55%',
    marketO25Highlight: true,
    marketBtts: '62%',
    marketBttsHighlight: false,
    marketCs: '22%',
    marketFts: '28%',
    insights: [
      '원정 최근 10경기 4승 기록',
      '원정 실점 평균 1.3골',
      '역습 전환 속도 빠름',
    ],
  ),
);
