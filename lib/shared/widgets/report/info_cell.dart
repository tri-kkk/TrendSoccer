import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class InfoCell extends StatelessWidget {
  const InfoCell({
    required this.value,
    required this.label,
    this.valueWidget,
    this.valueStyle,
    this.valueColor,
    super.key,
  });

  final String value;
  final String label;
  final Widget? valueWidget;
  final TextStyle? valueStyle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final style = (valueStyle ?? TsType.headingH3).copyWith(
      color: valueColor ?? semantic.textPrimary,
    );

    return Container(
      padding: const EdgeInsets.all(TsSpacing.sm),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          valueWidget ??
              Text(value, style: style, textAlign: TextAlign.center),
          const SizedBox(height: TsSpacing.sm),
          Text(
            label,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
