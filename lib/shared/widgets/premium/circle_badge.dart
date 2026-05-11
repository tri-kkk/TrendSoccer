import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum MatchResult { win, draw, lose }

class CircleBadge extends StatelessWidget {
  const CircleBadge({
    required this.result,
    required this.count,
    super.key,
  });

  final MatchResult result;
  final int count;

  String get _label {
    switch (result) {
      case MatchResult.win:
        return '승';
      case MatchResult.draw:
        return '무';
      case MatchResult.lose:
        return '패';
    }
  }

  Color _background(TsSemanticColors semantic) {
    switch (result) {
      case MatchResult.win:
        return semantic.interactivePrimary;
      case MatchResult.draw:
        return semantic.textTertiary;
      case MatchResult.lose:
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
        color: _background(semantic),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _label,
            style: TsType.labelSRegular.copyWith(color: semantic.textPrimary),
          ),
          Text(
            '$count',
            style: TsType.headingH1.copyWith(color: semantic.textPrimary),
          ),
        ],
      ),
    );
  }
}
