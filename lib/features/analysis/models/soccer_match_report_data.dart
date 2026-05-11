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

class MostCommonScoreData {
  const MostCommonScoreData({
    required this.count,
    required this.score,
  });

  final int count;
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
    '홈팀 최근 10경기 승률 80%로 원정팀 대비 파워차 우위',
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
    '오버 2.5 확률 60%로 공격적 경기 예상',
  ],
  homeAnalysis: TeamAnalysisData(
    teamName: '바르셀로나 분석',
    overallForm: '승 승 무 패 승 — 최근 5경기 3승 1무 1패',
    homeAwayForm: '홈 4승 1무 — 홈 경기에서 강세',
    goalStats: '평균 2.4골 득점 / 0.8골 실점',
    recentResults: 'UCL 조별 4승 2무, 라리가 10연승',
    strengthText:
        '안정적인 볼 점유와 빠른 역습 전환. 중앙 미드필드 장악력이 좋고 세트피스 득점력이 우수합니다.',
    weaknessText:
        '후반 체력이 떨어질 때 수비 라인 간격이 벌어지는 경향이 있습니다. 원정보다 홈에서 더 안정적입니다.',
  ),
  awayAnalysis: TeamAnalysisData(
    teamName: '바이에른 분석',
    overallForm: '패 승 승 무 패 — 최근 5경기 2승 1무 2패',
    homeAwayForm: '원정 2승 2패 1무 — 원정 경기가 들쑥날쑥',
    goalStats: '평균 1.8골 득점 / 1.2골 실점',
    recentResults: 'UCL 조별 3승 1무 2패, 분데스리가 최근 3경기 1승 2패',
    strengthText:
        '강한 프레싱과 측면 공격 위력. 개인 돌파력이 좋은 공격 라인을 갖추고 있습니다.',
    weaknessText:
        '수비 전환 속도가 느리고 세트피스 실점이 잦습니다. 최근 원정 성적이 부진합니다.',
  ),
);
