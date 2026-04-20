enum PickGrade { pick, good, pass }

class ReasoningItem {
  final String label;
  final String value;

  const ReasoningItem({required this.label, required this.value});
}

class TeamStat {
  final String label;
  final double homeValue; // 0.0~1.0
  final double awayValue;

  const TeamStat({
    required this.label,
    required this.homeValue,
    required this.awayValue,
  });
}

class MethodStat {
  final String label;
  final double homeRatio; // 0.0~1.0
  final double awayRatio;

  const MethodStat({
    required this.label,
    required this.homeRatio,
    required this.awayRatio,
  });
}

class SoccerMatchReport {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final String leagueId;
  final DateTime matchDateTime;
  final String predict;
  final int winPercent;
  final int powerDiff;
  final int matchCount;
  final String pattern;
  final PickGrade recommendGrade;
  final List<ReasoningItem> reasoningItems;
  final double homeOdds;
  final double drawOdds;
  final double awayOdds;
  final double homePower; // 0.0~1.0
  final double awayPower;
  final int homeProbability;
  final int drawProbability;
  final int awayProbability;
  final List<TeamStat> teamStats;
  final List<MethodStat> methodAnalysis;

  const SoccerMatchReport({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.leagueId,
    required this.matchDateTime,
    required this.predict,
    required this.winPercent,
    required this.powerDiff,
    required this.matchCount,
    required this.pattern,
    required this.recommendGrade,
    required this.reasoningItems,
    required this.homeOdds,
    required this.drawOdds,
    required this.awayOdds,
    required this.homePower,
    required this.awayPower,
    required this.homeProbability,
    required this.drawProbability,
    required this.awayProbability,
    required this.teamStats,
    required this.methodAnalysis,
  });

  factory SoccerMatchReport.dummy() => SoccerMatchReport(
        matchId: 'match_001',
        homeTeam: 'Chelsea',
        awayTeam: 'Arsenal',
        leagueId: 'epl',
        matchDateTime: DateTime.now().add(const Duration(hours: 20)),
        predict: 'Home',
        winPercent: 78,
        powerDiff: 44,
        matchCount: 3839,
        pattern: '1-3-2',
        recommendGrade: PickGrade.pick,
        reasoningItems: const [
          ReasoningItem(
            label: 'Power Diff',
            value: 'Chelsea holds +44pt advantage in recent form',
          ),
          ReasoningItem(
            label: 'Prob edge',
            value: 'Home win probability 24% above draw baseline',
          ),
          ReasoningItem(
            label: 'Home 1st goal',
            value: 'Chelsea scores first in 68% of home matches',
          ),
        ],
        homeOdds: 1.85,
        drawOdds: 3.40,
        awayOdds: 4.20,
        homePower: 0.62,
        awayPower: 0.38,
        homeProbability: 55,
        drawProbability: 24,
        awayProbability: 21,
        teamStats: const [
          TeamStat(label: '1st Goal Win', homeValue: 0.68, awayValue: 0.54),
          TeamStat(label: 'Comeback', homeValue: 0.42, awayValue: 0.35),
          TeamStat(label: 'Recent Form', homeValue: 0.72, awayValue: 0.58),
          TeamStat(label: 'Goal Ratio', homeValue: 0.65, awayValue: 0.51),
        ],
        methodAnalysis: const [
          MethodStat(label: 'P/A Compare', homeRatio: 0.62, awayRatio: 0.38),
          MethodStat(label: 'Min-Max', homeRatio: 0.58, awayRatio: 0.42),
          MethodStat(label: 'First Goal', homeRatio: 0.68, awayRatio: 0.32),
        ],
      );
}
