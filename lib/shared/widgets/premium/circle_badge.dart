import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum CircleBadgeType { win, draw, lose }

class CircleBadge extends StatelessWidget {
  const CircleBadge({
    required this.label,
    required this.value,
    required this.type,
    super.key,
  });

  final String label;
  final String value;
  final CircleBadgeType type;

  Color _background(TsSemanticColors semantic) {
    switch (type) {
      case CircleBadgeType.win:
        return semantic.interactivePrimary;
      case CircleBadgeType.draw:
        return semantic.textTertiary;
      case CircleBadgeType.lose:
        return TsColors.systemError500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _background(semantic),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TsType.labelSRegular.copyWith(color: semantic.textPrimary),
          ),
          Text(
            value,
            style: TsType.headingH1.copyWith(color: semantic.textPrimary),
          ),
        ],
      ),
    );
  }
}
