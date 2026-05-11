import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum ScoreBoxResult { win, draw, lose }

class ScoreBox extends StatelessWidget {
  const ScoreBox({
    required this.score,
    required this.result,
    super.key,
  });

  final String score;
  final ScoreBoxResult result;

  Color _scoreBackground(TsSemanticColors semantic) {
    switch (result) {
      case ScoreBoxResult.win:
        return semantic.interactivePrimary;
      case ScoreBoxResult.draw:
        return semantic.surfaceContainer;
      case ScoreBoxResult.lose:
        return TsColors.systemError500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: semantic.surfaceContainer,
            border: Border.all(color: semantic.borderSubtle, width: 1),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _scoreBackground(semantic),
          ),
          alignment: Alignment.center,
          child: Text(
            score,
            style: TsType.labelSRegular.copyWith(color: semantic.textPrimary),
          ),
        ),
      ],
    );
  }
}
