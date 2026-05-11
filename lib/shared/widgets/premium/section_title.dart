import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class CardSectionTitle extends StatelessWidget {
  const CardSectionTitle({
    required this.title,
    this.isExpanded = false,
    this.onTap,
    super.key,
  });

  final String title;
  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 24,
            color: semantic.textTertiary,
          ),
        ],
      ),
    );
  }
}
