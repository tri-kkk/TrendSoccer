import 'package:trendsoccer/core/models/match_header_data.dart';

/// How a past meeting was mapped onto the current fixture's home/away columns.
enum H2HMeetingOrientation {
  /// Meeting home/away already match the fixture home/away.
  aligned,
  /// Meeting home/away are swapped relative to the fixture.
  reversed,
  /// Could not match both sides to the fixture — row left as-is.
  unmatched,
}

/// Past meeting labels and score re-framed to the current fixture orientation.
class H2HNormalizedMeeting {
  const H2HNormalizedMeeting({
    required this.homeTeamEn,
    this.homeTeamKo,
    required this.awayTeamEn,
    this.awayTeamKo,
    required this.scoreLabel,
    required this.orientation,
  });

  final String homeTeamEn;
  final String? homeTeamKo;
  final String awayTeamEn;
  final String? awayTeamKo;
  final String scoreLabel;
  final H2HMeetingOrientation orientation;
}

/// English and Korean name variants for the current fixture (trimmed, non-empty).
({List<String> home, List<String> away}) h2hFixtureNameSets(
  MatchHeaderData header,
) {
  return (
    home: _teamNameVariants(header.homeTeam, header.homeTeamKo),
    away: _teamNameVariants(header.awayTeam, header.awayTeamKo),
  );
}

/// Re-frames [meetingHome*] / [meetingAway*] and the score into the fixture's
/// home (left) and away (right) columns.
H2HNormalizedMeeting normalizeH2HMeetingToFixture({
  required List<String> fixtureHomeNames,
  required List<String> fixtureAwayNames,
  required String meetingHomeEn,
  String? meetingHomeKo,
  required String meetingAwayEn,
  String? meetingAwayKo,
  int? homeScore,
  int? awayScore,
  String? rawScoreLabel,
}) {
  final meetingHomeNames =
      _teamNameVariants(meetingHomeEn, meetingHomeKo);
  final meetingAwayNames =
      _teamNameVariants(meetingAwayEn, meetingAwayKo);

  final aligned = _teamsOverlap(meetingHomeNames, fixtureHomeNames) &&
      _teamsOverlap(meetingAwayNames, fixtureAwayNames);
  final reversed = _teamsOverlap(meetingHomeNames, fixtureAwayNames) &&
      _teamsOverlap(meetingAwayNames, fixtureHomeNames);

  if (aligned) {
    return H2HNormalizedMeeting(
      homeTeamEn: meetingHomeEn,
      homeTeamKo: meetingHomeKo,
      awayTeamEn: meetingAwayEn,
      awayTeamKo: meetingAwayKo,
      scoreLabel: _scoreLabel(
        homeScore: homeScore,
        awayScore: awayScore,
        rawScoreLabel: rawScoreLabel,
        swap: false,
      ),
      orientation: H2HMeetingOrientation.aligned,
    );
  }

  if (reversed) {
    return H2HNormalizedMeeting(
      homeTeamEn: meetingAwayEn,
      homeTeamKo: meetingAwayKo,
      awayTeamEn: meetingHomeEn,
      awayTeamKo: meetingHomeKo,
      scoreLabel: _scoreLabel(
        homeScore: homeScore,
        awayScore: awayScore,
        rawScoreLabel: rawScoreLabel,
        swap: true,
      ),
      orientation: H2HMeetingOrientation.reversed,
    );
  }

  return H2HNormalizedMeeting(
    homeTeamEn: meetingHomeEn,
    homeTeamKo: meetingHomeKo,
    awayTeamEn: meetingAwayEn,
    awayTeamKo: meetingAwayKo,
    scoreLabel: _scoreLabel(
      homeScore: homeScore,
      awayScore: awayScore,
      rawScoreLabel: rawScoreLabel,
      swap: false,
    ),
    orientation: H2HMeetingOrientation.unmatched,
  );
}

List<String> _teamNameVariants(String? primary, [String? secondary]) {
  final variants = <String>{};
  for (final value in [primary, secondary]) {
    if (value == null) continue;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '-') continue;
    variants.add(trimmed);
  }
  return variants.toList();
}

bool _teamsOverlap(List<String> left, List<String> right) {
  if (left.isEmpty || right.isEmpty) return false;
  final rightNorm = right.map((name) => name.toLowerCase()).toSet();
  for (final name in left) {
    if (rightNorm.contains(name.toLowerCase())) return true;
  }
  return false;
}

String _scoreLabel({
  required int? homeScore,
  required int? awayScore,
  required String? rawScoreLabel,
  required bool swap,
}) {
  if (homeScore != null && awayScore != null) {
    if (swap) {
      return '$awayScore-$homeScore';
    }
    return '$homeScore-$awayScore';
  }

  final raw = rawScoreLabel?.trim();
  if (raw != null && raw.isNotEmpty) {
    if (swap) {
      final swapped = _trySwapScoreString(raw);
      return swapped ?? raw;
    }
    return raw;
  }

  return '-';
}

/// Swaps two integer score parts separated by `-`, `:`, or `–`.
/// Returns null when the string is not exactly `left sep right` (digits only).
String? _trySwapScoreString(String raw) {
  final match = RegExp(r'^(\d+)\s*[-:–]\s*(\d+)$').firstMatch(raw.trim());
  if (match == null) return null;
  return '${match.group(2)}-${match.group(1)}';
}
