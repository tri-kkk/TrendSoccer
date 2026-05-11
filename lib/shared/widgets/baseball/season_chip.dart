import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class SeasonChip extends StatelessWidget {
  const SeasonChip({required this.isCurrent, super.key});

  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isCurrent ? TsColors.brandPrimary500 : semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isCurrent ? '이번시즌' : '이전시즌',
        style: TsType.labelSRegular.copyWith(
          color: isCurrent ? semantic.surfaceBase : semantic.textSecondary,
        ),
      ),
    );
  }
}
