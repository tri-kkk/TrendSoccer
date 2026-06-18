import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class PositionChip extends StatelessWidget {
  const PositionChip({required this.isHome, super.key});

  final bool isHome;

  static final Color _homeBg =
      TsColors.brandPrimary500.withValues(alpha: 0.2);
  static final Color _awayBg =
      TsColors.systemError500.withValues(alpha: 0.2);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm, vertical: TsSpacing.xxs),
      decoration: BoxDecoration(
        color: isHome ? _homeBg : _awayBg,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        isHome ? l10n.labelHome : l10n.labelAway,
        style: TsType.labelSRegular.copyWith(
          color: isHome ? semantic.interactivePrimary : TsColors.systemError500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
