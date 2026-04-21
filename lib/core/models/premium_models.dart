/// Win / Draw / Lose result for a match.
enum MatchResult { win, draw, lose }

/// Score data for a single match.
class ScoreData {
  const ScoreData({
    required this.result,
    required this.homeScore,
    required this.awayScore,
  });

  final MatchResult result;
  final int homeScore;
  final int awayScore;
}

/// A commonly occurring score and how many times it appeared.
class CommonScore {
  const CommonScore({
    required this.count,
    required this.score,
  });

  /// Number of times this score occurred.
  final int count;

  /// Score string, e.g. "1-0", "0-2".
  final String score;
}
