import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class BenefitText extends StatelessWidget {
  const BenefitText({
    required this.text,
    this.isPremium = false,
    super.key,
  });

  final String text;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          size: 24,
          color: isPremium ? semantic.interactivePrimary : semantic.textTertiary,
        ),
        const SizedBox(width: TsSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
          ),
        ),
      ],
    );
  }
}
