import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';

enum TsEmptyType { noData, withAction, failure }

class TsEmptyState extends StatelessWidget {
  const TsEmptyState({
    this.type = TsEmptyType.noData,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final TsEmptyType type;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final icon = switch (type) {
      TsEmptyType.noData => TsIcons.imageNotSupported,
      TsEmptyType.withAction => TsIcons.info,
      TsEmptyType.failure => TsIcons.warning,
    };
    final showAction =
        actionLabel != null &&
        (type == TsEmptyType.withAction || type == TsEmptyType.failure);
    final actionStyle = type == TsEmptyType.failure
        ? TsButtonStyle.primary
        : TsButtonStyle.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TsIcon(icon, size: TsSpacing.xxxl, color: c.textTertiary),
          const SizedBox(height: TsSpacing.sm),
          Text(
            title,
            style: TsType.h3.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            description,
            style: TsType.bodyLRegular.copyWith(color: c.textTertiary),
            textAlign: TextAlign.center,
          ),
          if (showAction) ...[
            const SizedBox(height: TsSpacing.sm),
            TsButton(
              label: actionLabel!,
              style: actionStyle,
              size: TsButtonSize.small,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
