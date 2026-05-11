import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class TsBackButton extends StatelessWidget {
  const TsBackButton({this.onPressed, super.key});

  final VoidCallback? onPressed;

  void _handleTap(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else {
      Navigator.maybeOf(context)?.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          customBorder: const CircleBorder(),
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back,
              size: 24,
              color: semantic.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
