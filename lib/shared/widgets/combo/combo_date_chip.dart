import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class ComboDateChip extends StatelessWidget {
  const ComboDateChip({
    required this.label,
    this.isActive = false,
    this.onTap,
    super.key,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final bg = isActive ? semantic.interactivePrimary : semantic.surfaceContainer;
    final fg = isActive ? semantic.surfaceBase : semantic.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 52),
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm, vertical: TsSpacing.xs),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TsType.labelSBold.copyWith(color: fg),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
