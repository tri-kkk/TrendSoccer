import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class TsToggle extends StatelessWidget {
  const TsToggle({
    required this.value,
    this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: SizedBox(
        width: 51,
        height: 31,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: value ? semantic.interactivePrimary : semantic.borderDefault,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.all(TsSpacing.xxs),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: semantic.surfaceOverlay,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
