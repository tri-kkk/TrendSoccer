import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_gauge_bar.dart';

class TsStatCompareRow extends StatelessWidget {
  const TsStatCompareRow({
    required this.statLabel,
    required this.homeLabel,
    required this.awayLabel,
    required this.homeFraction,
    required this.awayFraction,
    this.homeEmphasized = false,
    this.awayEmphasized = false,
    super.key,
  });

  final String statLabel;
  final String homeLabel;
  final String awayLabel;
  final double homeFraction;
  final double awayFraction;
  final bool homeEmphasized;
  final bool awayEmphasized;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                homeLabel,
                style: TsType.tabular(
                  TsType.bodyLBold.copyWith(
                    color: homeEmphasized ? c.dataPositive : c.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                statLabel,
                style: TsType.labelSMedium.copyWith(color: c.textTertiary),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                awayLabel,
                style: TsType.tabular(
                  TsType.bodyLBold.copyWith(
                    color: awayEmphasized ? c.dataNegative : c.textPrimary,
                  ),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.xs),
        TsGaugeBar(
          home: homeFraction,
          away: awayFraction,
          line: TsGaugeLine.twoWay,
          showValues: false,
        ),
      ],
    );
  }
}
