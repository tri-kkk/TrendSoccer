import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class TsBottomSheetHandle extends StatelessWidget {
  const TsBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Center(
      child: Container(
        width: 48,
        height: 4,
        decoration: BoxDecoration(
          color: semantic.textTertiary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
