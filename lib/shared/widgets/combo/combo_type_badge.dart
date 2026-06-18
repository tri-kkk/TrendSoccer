import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

enum ComboType { safe, highOdds }

class ComboTypeBadge extends StatelessWidget {
  const ComboTypeBadge({
    required this.type,
    super.key,
  });

  final ComboType type;

  (Color, Color, String) _style(
    TsSemanticColors semantic,
    AppLocalizations l10n,
  ) {
    return switch (type) {
      ComboType.safe => (
          TsColors.brandPrimary500.withValues(alpha: 0.2),
          semantic.interactivePrimary,
          l10n.comboTypeSafe,
        ),
      ComboType.highOdds => (
          TsColors.systemWarning500.withValues(alpha: 0.2),
          TsColors.systemWarning500,
          l10n.comboTypeHigh,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final (bg, fg, label) = _style(semantic, context.l10n);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm, vertical: TsSpacing.xs),
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
