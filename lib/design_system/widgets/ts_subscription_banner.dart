import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';

class TsSubscriptionBanner extends StatelessWidget {
  const TsSubscriptionBanner({
    required this.headline,
    required this.subline,
    this.actionLabel = 'View plans',
    this.onAction,
    super.key,
  });

  final String headline;
  final String subline;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: c.primaryMuted,
        borderRadius: TsRadius.md,
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
                  headline,
                  style: TsType.h3.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: TsSpacing.xs),
                Text(
                  subline,
                  style: TsType.bodyMRegular.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: TsSpacing.md),
          TsButton(
            label: actionLabel,
            style: TsButtonStyle.primary,
            size: TsButtonSize.small,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
