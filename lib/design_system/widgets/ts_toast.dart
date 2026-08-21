import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsToastType { success, error, info }

class TsToast extends StatelessWidget {
  const TsToast({
    required this.message,
    this.type = TsToastType.info,
    super.key,
  });

  final String message;
  final TsToastType type;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final Color background;
    final TsIconSpec icon;
    switch (type) {
      case TsToastType.success:
        background = c.success;
        icon = TsIcons.checkCircleOutline;
      case TsToastType.error:
        background = c.error;
        icon = TsIcons.warning;
      case TsToastType.info:
        background = c.info;
        icon = TsIcons.info;
    }

    return Container(
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: TsRadius.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TsIcon(icon, size: 20, color: c.onScrim),
          const SizedBox(width: TsSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TsType.bodyLMedium.copyWith(color: c.onScrim),
            ),
          ),
        ],
      ),
    );
  }
}
