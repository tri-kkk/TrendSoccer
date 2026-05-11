import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class CardSectionTitle extends StatelessWidget {
  const CardSectionTitle({
    required this.title,
    this.isExpanded = false,
    this.onToggle,
    super.key,
  });

  final String title;
  final bool isExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          ),
          Transform.rotate(
            angle: isExpanded ? math.pi : 0,
            child: Icon(
              Icons.expand_circle_down,
              size: 24,
              color: semantic.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
