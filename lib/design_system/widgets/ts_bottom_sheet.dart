import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';

class TsBottomSheet extends StatelessWidget {
  const TsBottomSheet({
    required this.child,
    this.title,
    this.showDivider = false,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  final Widget child;
  final String? title;
  final bool showDivider;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final showFooter = primaryLabel != null || secondaryLabel != null;

    return Container(
      padding: const EdgeInsets.only(
        top: TsSpacing.md,
        left: TsSpacing.lg,
        right: TsSpacing.lg,
        bottom: TsSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.topXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: TsSpacing.xxxl,
              height: TsSpacing.xs,
              decoration: BoxDecoration(
                color: c.borderDefault,
                borderRadius: TsRadius.full,
              ),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: TsSpacing.lg),
            Text(
              title!,
              style: TsType.h3.copyWith(color: c.textPrimary),
            ),
          ],
          if (showDivider) ...[
            const SizedBox(height: TsSpacing.lg),
            Container(height: 1, color: c.borderSubtle),
          ],
          const SizedBox(height: TsSpacing.lg),
          child,
          if (showFooter) ...[
            const SizedBox(height: TsSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (primaryLabel != null)
                  TsButton(
                    label: primaryLabel!,
                    style: TsButtonStyle.primary,
                    expand: true,
                    onPressed: onPrimary,
                  ),
                if (primaryLabel != null && secondaryLabel != null)
                  const SizedBox(height: TsSpacing.sm),
                if (secondaryLabel != null)
                  TsButton(
                    label: secondaryLabel!,
                    style: TsButtonStyle.secondary,
                    expand: true,
                    onPressed: onSecondary,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
