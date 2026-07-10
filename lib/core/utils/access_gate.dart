import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

/// Client-side gating for time-based analysis unlock and tier access (v3.1 §5-3).
///
/// All time comparisons use UTC. [matchTimestamp] should be stored or parsed in UTC.
abstract final class AccessGate {
  /// Hours from now until [matchTimestamp] (positive = match is in the future).
  static double _hoursUntilMatchUtc(DateTime matchTimestamp) {
    final now = DateTime.now().toUtc();
    final match = matchTimestamp.toUtc();
    return match.difference(now).inMinutes / 60.0;
  }

  /// Whether standard match analysis is visible for this plan at this kickoff time.
  ///
  /// - [PlanType.premium] / [PlanType.trial]: always unlocked (no time restriction).
  /// - **&lt; 1h** until match: all remaining tiers, including [PlanType.none] (guest).
  /// - **1h–2h**: logged-in only ([PlanType.free]).
  /// - **≥ 2h**: locked for [PlanType.free] and [PlanType.none].
  ///
  /// After kickoff (negative hours), the &lt; 1h rule applies → unlocked for all.
  static bool canViewStandardAnalysis({
    required DateTime matchTimestamp,
    required PlanType planType,
  }) {
    if (planType == PlanType.premium || planType == PlanType.trial) {
      return true;
    }

    final hours = _hoursUntilMatchUtc(matchTimestamp);

    if (hours < 1) return true;
    if (hours < 2) return planType != PlanType.none;
    return false;
  }

  /// Copy shown when [canViewStandardAnalysis] is false; `null` when unlocked.
  ///
  /// Message priority when locked:
  /// - Guest, **≥ 2h** before match: opens 1h before kickoff.
  /// - Guest, **1h–2h**: login required.
  /// - Free (or trial), **2h–24h**: premium subscription upsell.
  /// - **≥ 24h** (or other locked states): opens 24h before kickoff.
  static String? lockMessage({
    required DateTime matchTimestamp,
    required PlanType planType,
    required AppLocalizations l10n,
  }) {
    if (canViewStandardAnalysis(
      matchTimestamp: matchTimestamp,
      planType: planType,
    )) {
      return null;
    }

    final hours = _hoursUntilMatchUtc(matchTimestamp);

    if (planType == PlanType.none) {
      if (hours >= 2) return l10n.accessLockOpensOneHourBefore;
      if (hours >= 1) return l10n.accessLockLoginRequired;
    }
    if (planType == PlanType.free && hours >= 2 && hours < 24) {
      return l10n.accessLockPremium24h;
    }
    return l10n.accessLockOpens24HoursBefore;
  }

  /// Time remaining until this tier’s standard-analysis window opens; `null` if already unlocked.
  ///
  /// Unlock thresholds before kickoff:
  /// - [PlanType.premium] / [PlanType.trial]: no lock (`null`).
  /// - [PlanType.free]: 2 hours before match.
  /// - [PlanType.none] (guest): 1 hour before match.
  static Duration? timeUntilUnlock({
    required DateTime matchTimestamp,
    required PlanType planType,
  }) {
    if (planType == PlanType.premium || planType == PlanType.trial) {
      return null;
    }

    if (canViewStandardAnalysis(
      matchTimestamp: matchTimestamp,
      planType: planType,
    )) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final match = matchTimestamp.toUtc();
    final unlockAt = switch (planType) {
      PlanType.free => match.subtract(const Duration(hours: 2)),
      PlanType.none => match.subtract(const Duration(hours: 1)),
      PlanType.premium || PlanType.trial => match,
    };

    final remaining = unlockAt.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Countdown label for locked analysis cards (Figma copy).
  static String formatTimeUntilUnlock(
    Duration duration, {
    required AppLocalizations l10n,
  }) {
    if (duration <= Duration.zero) return l10n.accessUnlockViewAnalysis;
    if (duration.inDays >= 1) {
      return l10n.accessUnlockDaysHours(
        duration.inDays,
        duration.inHours % 24,
      );
    }
    if (duration.inHours >= 1) {
      return l10n.accessUnlockHoursMinutes(
        duration.inHours,
        duration.inMinutes % 60,
      );
    }
    if (duration.inMinutes >= 1) {
      return l10n.accessUnlockMinutes(duration.inMinutes);
    }
    return l10n.accessUnlockViewAnalysis;
  }

  /// Premium-only surfaces: H2H/deep analysis, PREMIUM PICK list, baseball AI/combos.
  static bool canViewPremiumContent({required PlanType planType}) {
    return planType == PlanType.premium || planType == PlanType.trial;
  }

  /// Grade badges are never shown on card surfaces (product spec).
  static bool canViewGradeOnCard() => false;
}
