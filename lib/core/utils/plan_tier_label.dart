import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

/// Display labels for [PlanType] on member app bars and plan UI.
abstract final class PlanTierLabel {
  static String forPlanType(PlanType planType, AppLocalizations l10n) =>
      switch (planType) {
        PlanType.free => l10n.appBarTierFree,
        PlanType.trial => l10n.appBarTierTrial,
        PlanType.premium => l10n.appBarTierPremium,
        PlanType.none => l10n.appBarTierFree,
      };
}

/// Badge tones for [PlanType] on member app bars (matches [TsPlanTicket]).
abstract final class PlanTierTone {
  static TsBadgeTone forPlanType(PlanType planType) => switch (planType) {
        PlanType.free => TsBadgeTone.neutral,
        PlanType.trial => TsBadgeTone.positive,
        PlanType.premium => TsBadgeTone.primary,
        PlanType.none => TsBadgeTone.neutral,
      };
}
