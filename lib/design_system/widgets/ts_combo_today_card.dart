import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_stack_bar.dart';

class TsComboLeagueCount {
  const TsComboLeagueCount({
    required this.icon,
    required this.countLabel,
  });

  final Widget icon;
  final String countLabel;
}

class TsComboTodayCard extends StatelessWidget {
  const TsComboTodayCard({
    required this.countValue,
    required this.countLabel,
    required this.leagues,
    required this.stableLabel,
    required this.aggressiveLabel,
    required this.stableValueLabel,
    required this.aggressiveValueLabel,
    required this.stableFraction,
    required this.accuracyLabel,
    required this.ctaLabel,
    required this.onCtaPressed,
    super.key,
  });

  final String countValue;
  final String countLabel;
  final List<TsComboLeagueCount> leagues;
  final String stableLabel;
  final String aggressiveLabel;
  final String stableValueLabel;
  final String aggressiveValueLabel;
  final double stableFraction;
  final String accuracyLabel;
  final String ctaLabel;
  final VoidCallback onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: TsRadius.md,
        ),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          countValue,
                          style: TsType.displayLg.copyWith(color: c.primary),
                        ),
                        Text(
                          countLabel,
                          style: TsType.bodyMMedium.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: TsSpacing.md),
                  Row(
                    children: [
                      for (var i = 0; i < leagues.length; i++) ...[
                        if (i > 0) const SizedBox(width: TsSpacing.sm),
                        Column(
                          children: [
                            leagues[i].icon,
                            const SizedBox(height: TsSpacing.xs),
                            Text(
                              leagues[i].countLabel,
                              style: TsType.labelSBold.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.md),
              TsStackBar(
                line: TsStackLine.twoWay,
                home: stableFraction,
                away: 1 - stableFraction,
                homeLabel: stableLabel,
                awayLabel: aggressiveLabel,
                homeValue: stableValueLabel,
                awayValue: aggressiveValueLabel,
              ),
              const SizedBox(height: TsSpacing.md),
              Container(height: 1, color: c.borderSubtle),
              const SizedBox(height: TsSpacing.md),
              Text(
                accuracyLabel,
                style: TsType.labelSMedium.copyWith(color: c.textTertiary),
              ),
              const SizedBox(height: TsSpacing.md),
              TsButton(
                label: ctaLabel,
                style: TsButtonStyle.primary,
                size: TsButtonSize.large,
                expand: true,
                onPressed: onCtaPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
