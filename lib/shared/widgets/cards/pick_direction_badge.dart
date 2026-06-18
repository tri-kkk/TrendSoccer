import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

enum PickDirection { home, draw, away }

class PickDirectionBadge extends StatelessWidget {
  const PickDirectionBadge({required this.pick, super.key});

  final PickDirection pick;

  static String _label(AppLocalizations l10n, PickDirection pick) {
    return switch (pick) {
      PickDirection.home => l10n.pickDirectionHome,
      PickDirection.draw => l10n.pickDirectionDraw,
      PickDirection.away => l10n.pickDirectionAway,
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return SizedBox(
      width: 48,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm, vertical: TsSpacing.xs),
        decoration: BoxDecoration(
          color: semantic.surfaceOverlay,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          _label(context.l10n, pick),
          style: TsType.labelSBold.copyWith(color: semantic.interactivePrimary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
