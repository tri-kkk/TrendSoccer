import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_gauge_bar.dart';

class TsMethodRow extends StatelessWidget {
  const TsMethodRow({
    required this.methodLabel,
    required this.pickLabel,
    required this.homeFraction,
    required this.drawFraction,
    required this.awayFraction,
    this.homeLabel,
    this.drawLabel,
    this.awayLabel,
    super.key,
  });

  final String methodLabel;
  final String pickLabel;
  final double homeFraction;
  final double drawFraction;
  final double awayFraction;
  final String? homeLabel;
  final String? drawLabel;
  final String? awayLabel;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  methodLabel,
                  style: TsType.labelSMedium.copyWith(color: c.textTertiary),
                ),
              ),
              Text(
                pickLabel,
                style: TsType.bodyMBold.copyWith(color: c.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.xs),
          TsGaugeBar(
            home: homeFraction,
            draw: drawFraction,
            away: awayFraction,
            homeLabel: homeLabel,
            drawLabel: drawLabel,
            awayLabel: awayLabel,
          ),
        ],
      ),
    );
  }
}
