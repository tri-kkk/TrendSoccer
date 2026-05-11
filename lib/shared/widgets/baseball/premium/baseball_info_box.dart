import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class BaseballInfoBox extends StatelessWidget {
  const BaseballInfoBox({
    required this.label,
    required this.value,
    required this.valueColor,
    this.teamName,
    super.key,
  });

  final String label;
  final String value;
  final String? teamName;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            value,
            style: TsType.headingH1.copyWith(color: valueColor),
            textAlign: TextAlign.center,
          ),
          if (teamName != null) ...[
            const SizedBox(height: TsSpacing.sm),
            Text(
              teamName!,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
