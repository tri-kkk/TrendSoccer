import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

enum ComboStatus { inProgress, partial, hit, miss }

class ComboStatusBadge extends StatelessWidget {
  const ComboStatusBadge({
    required this.status,
    super.key,
  });

  final ComboStatus status;

  (Color, Color, String) _style(TsSemanticColors s, AppLocalizations l10n) {
    return switch (status) {
      ComboStatus.inProgress => (
          TsColors.analysisPass500.withValues(alpha: 0.2),
          s.textSecondary,
          l10n.comboStatusInProgress,
        ),
      ComboStatus.partial => (
          TsColors.systemWarning500.withValues(alpha: 0.2),
          TsColors.systemWarning500,
          l10n.comboStatusPartial,
        ),
      ComboStatus.hit => (
          TsColors.systemSuccess500.withValues(alpha: 0.2),
          TsColors.systemSuccess500,
          l10n.comboStatusHit,
        ),
      ComboStatus.miss => (
          TsColors.systemError500.withValues(alpha: 0.2),
          TsColors.systemError500,
          l10n.comboStatusMiss,
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
