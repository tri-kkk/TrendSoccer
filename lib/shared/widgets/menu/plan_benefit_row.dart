import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class PlanBenefitRow extends StatelessWidget {
  const PlanBenefitRow({
    required this.text,
    this.isIncluded = true,
    super.key,
  });

  final String text;
  final bool isIncluded;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isIncluded ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: isIncluded ? semantic.interactivePrimary : semantic.textDisabled,
        ),
        const SizedBox(width: TsSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TsType.bodyMRegular.copyWith(
              color: isIncluded ? semantic.textPrimary : semantic.textDisabled,
            ),
          ),
        ),
      ],
    );
  }
}
