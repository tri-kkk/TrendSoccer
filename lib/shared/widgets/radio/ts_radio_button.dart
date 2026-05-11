import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class TsRadioButton extends StatelessWidget {
  const TsRadioButton({
    required this.selected,
    this.onChanged,
    super.key,
  });

  final bool selected;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return GestureDetector(
      onTap: onChanged,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(
            width: 2,
            color: selected ? semantic.interactivePrimary : semantic.borderDefault,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: semantic.interactivePrimary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
