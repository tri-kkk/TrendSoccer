import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';

enum TsPlan { free, trial, premium }

class TsPlanTicket extends StatelessWidget {
  const TsPlanTicket({
    required this.plan,
    required this.subLabel,
    this.planLabel,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final TsPlan plan;
  final String subLabel;
  final String? planLabel;
  final String? actionLabel;
  final VoidCallback? onAction;

  String get _defaultPlanLabel => switch (plan) {
        TsPlan.free => 'FREE',
        TsPlan.trial => 'TRIAL',
        TsPlan.premium => 'PREMIUM',
      };

  TsBadgeTone get _planTone => switch (plan) {
        TsPlan.free => TsBadgeTone.neutral,
        TsPlan.trial => TsBadgeTone.primary,
        TsPlan.premium => TsBadgeTone.positive,
      };

  String? get _defaultActionLabel => switch (plan) {
        TsPlan.free => 'Upgrade',
        TsPlan.trial => null,
        TsPlan.premium => 'Manage',
      };

  TsButtonStyle? get _actionStyle => switch (plan) {
        TsPlan.free => TsButtonStyle.primary,
        TsPlan.trial => null,
        TsPlan.premium => TsButtonStyle.secondary,
      };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final buttonLabel = actionLabel ?? _defaultActionLabel;
    final buttonStyle = _actionStyle;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
        border: Border.all(color: c.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TsBadge(
                  label: planLabel ?? _defaultPlanLabel,
                  tone: _planTone,
                ),
                const SizedBox(height: TsSpacing.xs),
                Text(
                  subLabel,
                  style: TsType.labelSRegular.copyWith(color: c.textTertiary),
                ),
              ],
            ),
          ),
          if (buttonLabel != null && buttonStyle != null) ...[
            const SizedBox(width: TsSpacing.md),
            TsButton(
              label: buttonLabel,
              style: buttonStyle,
              size: TsButtonSize.small,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
