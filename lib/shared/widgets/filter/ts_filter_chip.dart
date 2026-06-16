import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum TsFilterChipType { textOnly, withIcon, withAPI }

class TsFilterChip extends StatelessWidget {
  const TsFilterChip({
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.type = TsFilterChipType.textOnly,
    this.iconWidget,
    this.logoUrl,
    this.activeBackgroundColor,
    this.activeTextColor,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final TsFilterChipType type;
  final Widget? iconWidget;
  final String? logoUrl;
  final Color? activeBackgroundColor;
  final Color? activeTextColor;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final backgroundColor = isSelected
        ? (activeBackgroundColor ?? semantic.textPrimary)
        : semantic.surfaceContainer;
    final textColor = isSelected
        ? (activeTextColor ?? semantic.surfaceBase)
        : semantic.textSecondary;
    final textStyle = TsType.labelSRegular.copyWith(color: textColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(
          horizontal: TsSpacing.md,
          vertical: TsSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showIcon) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: Center(child: iconWidget),
              ),
              const SizedBox(width: TsSpacing.xs),
            ] else if (_showApiLogo) ...[
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: logoUrl!,
                  width: 16,
                  height: 16,
                  fit: BoxFit.cover,
                  placeholder: (context, _) => Container(
                    width: 16,
                    height: 16,
                    color: semantic.surfaceContainer,
                  ),
                ),
              ),
              const SizedBox(width: TsSpacing.xs),
            ],
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }

  bool get _showIcon =>
      type == TsFilterChipType.withIcon && iconWidget != null;

  bool get _showApiLogo =>
      type == TsFilterChipType.withAPI &&
      logoUrl != null &&
      logoUrl!.isNotEmpty;
}
