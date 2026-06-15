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
    final score = isHome ? match.homeScore : match.awayScore;
    return score?.toString();
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
      return l10n.liveMinutes(live.elapsed);
    }
    if (live != null && live.isFinished) {
      return l10n.fixtureStatusFinal;
    }
    switch (match.status) {
      case 'live':
        if (isHalftimeStatus(match.rawStatus) ||
            (live != null && isHalftimeStatus(live.status))) {
          return 'HT';
        }
        return live != null && live.elapsed > 0
            ? l10n.liveMinutes(live.elapsed)
            : l10n.fixtureLive;
      case 'finished':
        return l10n.fixtureStatusFinal;
      case 'postponed':
        return l10n.matchPostponed;
      case 'cancelled':
        return l10n.matchCancelled;
      case 'interrupted':
        return l10n.fixtureInterrupted;
      default:
        return fixtureMatchTimeKst(match);
    }
  }
}
