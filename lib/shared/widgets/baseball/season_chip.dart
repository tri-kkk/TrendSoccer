import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class SeasonChip extends StatelessWidget {
  const SeasonChip({
    required this.isCurrent,
    this.label,
    super.key,
  });

  final bool isCurrent;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final text = label ?? (isCurrent ? l10n.seasonCurrent : l10n.seasonPrevious);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm, vertical: TsSpacing.xxs),
      decoration: BoxDecoration(
        color: isCurrent ? semantic.interactivePrimary : semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TsType.labelSRegular.copyWith(
          color: isCurrent ? semantic.surfaceBase : semantic.textSecondary,
        ),
      ),
    );
  }
}
