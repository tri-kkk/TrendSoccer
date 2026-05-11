import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/badge/ts_badge.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    required this.value,
    required this.label,
    this.isHighlight = false,
    this.isBadge = false,
    super.key,
  });

  final String value;
  final String label;
  final bool isHighlight;
  final bool isBadge;

  static const Color _highlightBg = Color(0x3300DF81);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.all(TsSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isHighlight ? _highlightBg : semantic.surfaceContainer,
        border: isHighlight
            ? Border.all(color: semantic.interactivePrimary, width: 1)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBadge)
            const TsBadge(type: TsBadgeType.pick)
          else
            Text(
              value,
              style: TsType.headingH1.copyWith(color: semantic.textPrimary),
            ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            label,
            style: TsType.labelSRegular.copyWith(
              color: isHighlight ? semantic.textSecondary : semantic.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
