import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum MenuItemType { chevron, value }

class MenuListItem extends StatelessWidget {
  const MenuListItem({
    required this.icon,
    required this.label,
    this.type = MenuItemType.chevron,
    this.value,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final MenuItemType type;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: semantic.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: semantic.textTertiary),
            const SizedBox(width: TsSpacing.lg),
            Expanded(
              child: Text(
                label,
                style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
              ),
            ),
            if (type == MenuItemType.chevron)
              Icon(Icons.chevron_right, size: 24, color: semantic.textTertiary)
            else
              Text(
                value ?? '',
                style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}
