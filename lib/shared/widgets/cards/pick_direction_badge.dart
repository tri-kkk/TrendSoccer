import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum PickDirection { home, draw, away }

class PickDirectionBadge extends StatelessWidget {
  const PickDirectionBadge({required this.pick, super.key});

  final PickDirection pick;

  static String _label(PickDirection pick) {
    return switch (pick) {
      PickDirection.home => '홈',
      PickDirection.draw => '무',
      PickDirection.away => '원정',
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return SizedBox(
      width: 48,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: semantic.surfaceOverlay,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          _label(pick),
          style: TsType.labelSBold.copyWith(color: semantic.interactivePrimary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
