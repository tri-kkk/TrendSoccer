import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_status.dart';

/// Soccer-specific fixture row presentation helpers.
abstract final class FixtureSoccerContent {
  static bool isHalftimeStatus(String? status) {
    if (status == null || status.isEmpty) return false;
    final normalized = status.trim().toUpperCase();
    return normalized == 'HT' || normalized.contains('HALFTIME');
  }

  static FixtureMatchStatus toFixtureStatus(FixtureMatch match) {
    final raw = match.rawStatus.trim().toUpperCase();
    if (raw == 'POST' || raw == 'PST' || raw == 'POSTPONED') {
      return FixtureMatchStatus.postponed;
    }
    if (raw == 'INTR') {
      return FixtureMatchStatus.interrupted;
    }
    switch (match.status) {
      case 'live':
        return FixtureMatchStatus.live;
      case 'finished':
        return FixtureMatchStatus.finished;
      case 'postponed':
        return FixtureMatchStatus.postponed;
      case 'cancelled':
        return FixtureMatchStatus.cancelled;
      case 'interrupted':
        return FixtureMatchStatus.interrupted;
      default:
        return FixtureMatchStatus.scheduled;
    }
  }

  static String? scoreText(FixtureMatch match, {required bool isHome}) {
    if (match.status == 'scheduled') return null;
    if (match.status == 'postponed' || match.status == 'interrupted') {
      if (match.homeScore == null && match.awayScore == null) {
        return null;
      }
    }
    final score = isHome ? match.homeScore : match.awayScore;
    return score?.toString();
  }

  static String formatSoccerElapsedTime(
    int elapsed,
    String status, {
    int? elapsedExtra,
  }) {
    if (elapsedExtra != null && elapsedExtra > 0) {
      return '$elapsed+$elapsedExtra';
    }

    final normalized = status.trim().toUpperCase();
    if (normalized == '1H' && elapsed > 45) {
      return '45+${elapsed - 45}';
    }
    if (normalized == '2H' && elapsed > 90) {
      return '90+${elapsed - 90}';
    }
    return '$elapsed';
  }

  static String liveElapsedText(
    int elapsed,
    String status, {
    int? elapsedExtra,
  }) {
    return "${formatSoccerElapsedTime(elapsed, status, elapsedExtra: elapsedExtra)}'";
  }

  static String? statusTimeText(
    FixtureMatch match, {
    required AppLocalizations l10n,
    LiveMatchData? live,
  }) {
    if (live != null && isHalftimeStatus(live.status)) {
      return 'HT';
    }
    if (isHalftimeStatus(match.rawStatus)) {
      return 'HT';
    }
    if (live != null && live.isLive) {
      return liveElapsedText(
        live.elapsed,
        live.status,
        elapsedExtra: live.elapsedExtra,
      );
    }
    if (live != null && live.isFinished) {
      return l10n.fixtureStatusFinal;
    }
    final raw = match.rawStatus.trim().toUpperCase();
    if (raw == 'POST' || raw == 'PST' || raw == 'POSTPONED') {
      return l10n.statusPostponed;
    }
    if (raw == 'INTR') {
      return l10n.statusInterrupted;
    }
    switch (match.status) {
      case 'live':
        if (isHalftimeStatus(match.rawStatus) ||
            (live != null && isHalftimeStatus(live.status))) {
          return 'HT';
        }
        return live != null && live.elapsed > 0
            ? liveElapsedText(
                live.elapsed,
                live.status,
                elapsedExtra: live.elapsedExtra,
              )
            : l10n.fixtureLive;
      case 'finished':
        return l10n.fixtureStatusFinal;
      case 'postponed':
        return l10n.statusPostponed;
      case 'cancelled':
        return l10n.matchCancelled;
      case 'interrupted':
        return l10n.statusInterrupted;
      default:
        return fixtureMatchTimeKst(match);
    }
  }
}
