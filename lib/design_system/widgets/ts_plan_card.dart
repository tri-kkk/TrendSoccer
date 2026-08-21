import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsPlanTier { free, premium }

class TsPlanCard extends StatelessWidget {
  const TsPlanCard({
    required this.tier,
    required this.titleLabel,
    required this.benefits,
    super.key,
  });

  final TsPlanTier tier;
  final String titleLabel;
  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final isPremium = tier == TsPlanTier.premium;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, minHeight: 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isPremium ? c.primarySubtle : c.surface,
          borderRadius: TsRadius.md,
        ),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                titleLabel,
                style: TsType.h3.copyWith(
                  color: isPremium ? c.primary : c.textPrimary,
                ),
              ),
              const SizedBox(height: TsSpacing.md),
              Column(
                children: [
                  for (var i = 0; i < benefits.length; i++) ...[
                    if (i > 0) const SizedBox(height: TsSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TsIcon(
                          isPremium
                              ? TsIcons.checkCircleOutline
                              : TsIcons.check,
                          size: TsIconSize.xs,
                          color: isPremium ? c.primary : c.textPrimary,
                        ),
                        const SizedBox(width: TsSpacing.sm),
                        Expanded(
                          child: Text(
                            benefits[i],
                            style: TsType.bodyMRegular.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
