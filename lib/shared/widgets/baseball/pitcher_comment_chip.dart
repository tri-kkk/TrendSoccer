import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class PitcherCommentChip extends StatelessWidget {
  const PitcherCommentChip({
    required this.text,
    required this.isStrength,
    super.key,
  });

  final String text;
  final bool isStrength;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final textColor =
        isStrength ? semantic.interactivePrimary : TsColors.error500;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isStrength
            // No interactiveSurfaceStrong token — 20% interactivePrimary matches Figma
            ? semantic.interactivePrimary.withValues(alpha: 0.2)
            : TsColors.error500.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          fontSize: 11,
          height: 17 / 11,
          letterSpacing: 0.11,
          color: textColor,
        ),
      ),
    );
  }
}
