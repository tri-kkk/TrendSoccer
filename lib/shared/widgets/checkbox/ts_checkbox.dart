import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum TsCheckBoxState { checked, unchecked, partial }

class TsCheckBox extends StatelessWidget {
  const TsCheckBox({
    required this.state,
    this.onChanged,
    super.key,
  });

  final TsCheckBoxState state;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return GestureDetector(
      onTap: onChanged,
      child: switch (state) {
        TsCheckBoxState.checked => Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: semantic.interactivePrimary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Icon(
                Icons.check,
                size: 18,
                color: semantic.interactiveOnPrimary,
              ),
            ),
          ),
        TsCheckBoxState.unchecked => Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: semantic.borderDefault,
                width: 2,
              ),
            ),
          ),
        TsCheckBoxState.partial => Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: semantic.interactivePrimary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Icon(
                Icons.remove,
                size: 18,
                color: semantic.interactiveOnPrimary,
              ),
            ),
          ),
      },
    );
  }
}
