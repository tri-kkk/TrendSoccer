import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';

class TsGuestBanner extends StatelessWidget {
  const TsGuestBanner({
    required this.title,
    required this.subtitle,
    this.actionLabel = 'Sign up',
    this.onAction,
    super.key,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: c.primaryMuted,
        borderRadius: TsRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TsType.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: TsSpacing.xs),
              Text(
                subtitle,
                style: TsType.bodyMRegular.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.md),
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
