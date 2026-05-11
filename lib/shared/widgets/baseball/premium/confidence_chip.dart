import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum ConfidenceLevel { high, medium, low }

class ConfidenceChip extends StatelessWidget {
  const ConfidenceChip({required this.level, super.key});

  final ConfidenceLevel level;

  (Color, String) _style(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return switch (level) {
      ConfidenceLevel.high => (semantic.interactivePrimary, '높음'),
      ConfidenceLevel.medium => (TsColors.systemWarning500, '보통'),
      ConfidenceLevel.low => (TsColors.systemError500, '낮음'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (color, label) = _style(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: TsSpacing.sm),
        Text(
          label,
          style: TsType.bodyLRegular.copyWith(color: color),
        ),
      ],
    );
  }
}
