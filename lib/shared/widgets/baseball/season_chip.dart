import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class SeasonChip extends StatelessWidget {
  const SeasonChip({
    required this.isCurrent,
    this.label,
    super.key,
  });

  final bool isCurrent;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final text = label ?? (isCurrent ? '이번시즌' : '이전시즌');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isCurrent ? semantic.interactivePrimary : semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TsType.labelSRegular.copyWith(
          color: isCurrent ? semantic.surfaceBase : semantic.textSecondary,
        ),
      ),
    );
  }
}
