import 'package:trendsoccer/core/models/auth_state.dart';

/// Display labels for [PlanType] on member app bars and plan UI.
abstract final class PlanTierLabel {
  static String forPlanType(PlanType planType) => switch (planType) {
        PlanType.free => 'FREE',
        PlanType.trial => 'TRIAL',
        PlanType.premium => 'PREMIUM',
        PlanType.none => 'FREE',
      };
}
