import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/report/info_cell.dart';

class OddsSection extends StatelessWidget {
  const OddsSection({
    required this.homeOdds,
    required this.drawOdds,
    required this.awayOdds,
    super.key,
  });

  final String homeOdds;
  final String drawOdds;
  final String awayOdds;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.labelOdds,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(child: InfoCell(value: homeOdds, label: l10n.soccerOddsHome)),
              const SizedBox(width: TsSpacing.sm),
              Expanded(child: InfoCell(value: drawOdds, label: l10n.soccerOddsDraw)),
              const SizedBox(width: TsSpacing.sm),
              Expanded(child: InfoCell(value: awayOdds, label: l10n.soccerOddsAway)),
            ],
          ),
        ),
      ],
    );
  }
}
