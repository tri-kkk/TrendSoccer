import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum ComboType { safe, highOdds }

class ComboTypeBadge extends StatelessWidget {
  const ComboTypeBadge({
    required this.type,
    super.key,
  });

  final ComboType type;

  (Color, Color, String) _style(TsSemanticColors semantic) {
    return switch (type) {
      ComboType.safe => (
          const Color(0x3300DF81),
          semantic.interactivePrimary,
          '안전형',
        ),
      ComboType.highOdds => (
          const Color(0x33F59E0B),
          TsColors.systemWarning500,
          '고배당',
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
