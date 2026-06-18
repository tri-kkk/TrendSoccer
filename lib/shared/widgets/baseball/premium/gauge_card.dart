import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/report/ratio_bar.dart';

class GaugeCard extends StatelessWidget {
  const GaugeCard({
    required this.label,
    required this.homeRatio,
    this.homeLabel,
    this.awayLabel,
    super.key,
  });

  final String label;
  final double homeRatio;
  final String? homeLabel;
  final String? awayLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final hr = homeRatio.clamp(0.0, 1.0);
    final ar = (1.0 - hr).clamp(0.0, 1.0);
    final resolvedHomeLabel = homeLabel ?? l10n.labelHome;
    final resolvedAwayLabel = awayLabel ?? l10n.labelAway;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.xs),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          RatioBar(
            segments: [
              RatioSegment(
                flex: hr,
                color: semantic.interactivePrimary,
                bottomLabel: resolvedHomeLabel,
              ),
              RatioSegment(
                flex: ar,
                color: TsColors.systemError500,
                bottomLabel: resolvedAwayLabel,
              ),
            ],
            height: 8,
            showLabels: true,
          ),
        ],
      ),
    );
  }
}
