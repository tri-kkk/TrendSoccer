import 'package:trendsoccer/core/models/auth_state.dart';

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
  /// Unlock windows before kickoff (web `premium/page.tsx` pattern):
  /// - **&lt; 1h** until match: all tiers, including [PlanType.none] (guest).
  /// - **1h–2h**: logged-in only ([PlanType.free], [PlanType.trial], [PlanType.premium]).
  /// - **2h–24h**: [PlanType.premium] or [PlanType.trial] only.
  /// - **≥ 24h**: locked for everyone.
  ///
  /// After kickoff (negative hours), the &lt; 1h rule applies → unlocked for all.
  static bool canViewStandardAnalysis({
    required DateTime matchTimestamp,
    required PlanType planType,
  }) {
    final hours = _hoursUntilMatchUtc(matchTimestamp);

    if (hours < 1) return true;
    if (hours < 2) return planType != PlanType.none;
    if (hours < 24) {
      return planType == PlanType.premium || planType == PlanType.trial;
    }
    return false;
  }

  /// Korean copy shown when [canViewStandardAnalysis] is false; `null` when unlocked.
  ///
  /// Message priority when locked:
  /// - Guest, **≥ 2h** before match: opens 1h before kickoff.
  /// - Guest, **1h–2h**: login required.
  /// - Free (or trial), **2h–24h**: premium subscription upsell.
  /// - **≥ 24h** (or other locked states): opens 24h before kickoff.
  static String? lockMessage({
    required DateTime matchTimestamp,
    required PlanType planType,
  }) {
    if (canViewStandardAnalysis(
      matchTimestamp: matchTimestamp,
      planType: planType,
    )) {
      return null;
    }

    final hours = _hoursUntilMatchUtc(matchTimestamp);

    if (planType == PlanType.none) {
      if (hours >= 2) return '경기 시작 1시간 전에 오픈됩니다.';
      if (hours >= 1) return '로그인 후 확인 가능합니다.';
    }
    if (planType == PlanType.free && hours >= 2 && hours < 24) {
      return '프리미엄 구독 시 경기 시작 24시간 전부터 확인 가능합니다.';
    }
    return '경기 시작 24시간 전에 오픈됩니다.';
  }

  /// Time remaining until this tier’s standard-analysis window opens; `null` if already unlocked.
  ///
  /// Unlock thresholds before kickoff:
  /// - [PlanType.premium] / [PlanType.trial]: 24 hours before match.
  /// - [PlanType.free]: 2 hours before match.
  /// - [PlanType.none] (guest): 1 hour before match.
  static Duration? timeUntilUnlock({
    required DateTime matchTimestamp,
    required PlanType planType,
  }) {
    if (canViewStandardAnalysis(
      matchTimestamp: matchTimestamp,
      planType: planType,
    )) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final match = matchTimestamp.toUtc();
    final unlockAt = switch (planType) {
      PlanType.premium || PlanType.trial =>
        match.subtract(const Duration(hours: 24)),
      PlanType.free => match.subtract(const Duration(hours: 2)),
      PlanType.none => match.subtract(const Duration(hours: 1)),
    };

    final remaining = unlockAt.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Countdown label for locked analysis cards (Figma copy).
  static String formatTimeUntilUnlock(Duration duration) {
    if (duration <= Duration.zero) return '분석보기';
    if (duration.inDays >= 1) {
      return '${duration.inDays}일 ${duration.inHours % 24}시간 후 오픈';
    }
    if (duration.inHours >= 1) {
      return '${duration.inHours}시간 ${duration.inMinutes % 60}분 후 오픈';
    }
    if (duration.inMinutes >= 1) {
      return '${duration.inMinutes}분 후 오픈';
    }
    return '분석보기';
  }

  /// Premium-only surfaces: H2H/deep analysis, PREMIUM PICK list, baseball AI/combos.
  static bool canViewPremiumContent({required PlanType planType}) {
    return planType == PlanType.premium || planType == PlanType.trial;
  }

  /// Grade badges are never shown on card surfaces (product spec).
  static bool canViewGradeOnCard() => false;
}
