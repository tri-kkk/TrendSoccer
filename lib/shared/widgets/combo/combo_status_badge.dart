import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum ComboStatus { inProgress, partial, hit, miss }

class ComboStatusBadge extends StatelessWidget {
  const ComboStatusBadge({
    required this.status,
    super.key,
  });

  final ComboStatus status;

  (Color, Color, String) _style(TsSemanticColors s) {
    return switch (status) {
      ComboStatus.inProgress => (
          const Color(0x336B7280),
          s.textSecondary,
          '진행중',
        ),
      ComboStatus.partial => (
          const Color(0x33F59E0B),
          TsColors.systemWarning500,
          '부분',
        ),
      ComboStatus.hit => (
          const Color(0x3310B981),
          TsColors.systemSuccess500,
          '적중',
        ),
      ComboStatus.miss => (
          const Color(0x33EF4444),
          TsColors.systemError500,
          '미적중',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final (bg, fg, label) = _style(semantic);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TsType.labelSBold.copyWith(color: fg),
      ),
    );
  }
}
