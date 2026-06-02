import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class PlanTicket extends StatelessWidget {
  const PlanTicket({
    required this.type,
    required this.subtitle,
    this.onButtonTap,
    this.buttonLabel,
    super.key,
  });

  final PlanType type;
  final String subtitle;
  final VoidCallback? onButtonTap;
  final String? buttonLabel;

  String _title(BuildContext context) {
    final l10n = context.l10n;
    return switch (type) {
      PlanType.none || PlanType.free => l10n.planTicketFree,
      PlanType.trial => l10n.planTicketTrial,
      PlanType.premium => l10n.planTicketPremium,
    };
  }

  String _defaultLabel(BuildContext context, PlanType type) {
    final l10n = context.l10n;
    return switch (type) {
      PlanType.none || PlanType.free => l10n.menuSubscribeFree,
      PlanType.trial => l10n.planTicketUpgrade,
      PlanType.premium => l10n.planTicketRenew,
    };
  }

  String get _imageAsset {
    return switch (type) {
      PlanType.none => TsAssets.planFree,
      PlanType.free => TsAssets.planFree,
      PlanType.trial => TsAssets.planTrial,
      PlanType.premium => TsAssets.planPremium,
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(TsSpacing.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title(context),
                  style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                ),
                const SizedBox(height: TsSpacing.sm),
                Text(
                  subtitle,
                  style: TsType.labelSRegular.copyWith(
                    color: semantic.textTertiary,
                  ),
                ),
                const SizedBox(height: TsSpacing.sm),
                TsButton(
                  label: buttonLabel ?? _defaultLabel(context, type),
                  variant: TsButtonVariant.primary,
                  size: TsButtonSize.small,
                  onPressed: onButtonTap,
                ),
              ],
            ),
          ),
          const SizedBox(width: TsSpacing.lg),
          Image.asset(
            _imageAsset,
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
