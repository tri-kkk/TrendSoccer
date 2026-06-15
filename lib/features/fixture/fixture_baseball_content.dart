import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/utils/baseball_status.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_status.dart';

/// Baseball-specific fixture row presentation helpers.
abstract final class FixtureBaseballContent {
  static FixtureMatchStatus toFixtureStatus(FixtureMatch match) {
    if (BaseballStatus.isInterrupted(match.rawStatus)) {
      return FixtureMatchStatus.interrupted;
    }
    if (BaseballStatus.isCancelled(match.rawStatus) ||
        match.status == 'cancelled') {
      return FixtureMatchStatus.cancelled;
    }
    if (BaseballStatus.isPostponed(match.rawStatus) ||
        match.status == 'postponed') {
      return FixtureMatchStatus.postponed;
    }
    if (BaseballStatus.isLive(match.rawStatus)) {
      return FixtureMatchStatus.live;
    }
    switch (match.status) {
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
    if (match.status == 'scheduled' ||
        match.status == 'postponed' ||
        match.status == 'cancelled') {
      return null;
    }
    final score = isHome ? match.homeScore : match.awayScore;
    return score?.toString();
  }

  static String? statusTimeText(
    FixtureMatch match,
    AppLocalizations l10n,
  ) {
    if (match.status == 'postponed' ||
        BaseballStatus.isPostponed(match.rawStatus)) {
      return l10n.matchPostponed;
    }
    if (match.status == 'cancelled' ||
        BaseballStatus.isCancelled(match.rawStatus)) {
      return l10n.matchCancelled;
    }
    if (BaseballStatus.isInterrupted(match.rawStatus)) {
      return l10n.fixtureInterrupted;
    }

    if (BaseballStatus.isScheduled(match.rawStatus) ||
        match.status == 'scheduled') {
      return fixtureMatchTimeKst(match);
    }

    if (match.status == 'finished' ||
        BaseballStatus.isFinished(match.rawStatus)) {
      return l10n.fixtureStatusFinal;
    }

    if (BaseballStatus.isLive(match.rawStatus)) {
      final display = localizeStatusCode(
        BaseballStatus.displayStatus(match.rawStatus),
        l10n,
      );
      if (display.isNotEmpty) return display;
      return l10n.fixtureLive;
    }

    return localizeStatusCode(
      BaseballStatus.displayStatus(match.rawStatus),
      l10n,
    );
  }

  static String localizeStatusCode(String code, AppLocalizations l10n) {
    if (code.isEmpty) return code;
    if (code == 'INT') return l10n.fixtureInterrupted;
    final topMatch = RegExp(r'^(\d+)T$').firstMatch(code);
    if (topMatch != null) {
      return l10n.baseballInningTop(int.parse(topMatch.group(1)!));
    }
    final bottomMatch = RegExp(r'^(\d+)B$').firstMatch(code);
    if (bottomMatch != null) {
      return l10n.baseballInningBottom(int.parse(bottomMatch.group(1)!));
    }
    return code;
  }
}
