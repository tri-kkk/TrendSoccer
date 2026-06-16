import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum MenuItemType { chevron, value }

class MenuListItem extends StatelessWidget {
  const MenuListItem({
    required this.iconAsset,
    required this.label,
    this.type = MenuItemType.chevron,
    this.value,
    this.onTap,
    super.key,
  });

  final String iconAsset;
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
          color: semantic.surfaceBase,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                semantic.textTertiary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: TsSpacing.lg),
            Expanded(
              child: Text(
                label,
                style: TsType.bodyLRegular.copyWith(
                  color: semantic.textPrimary,
                  fontFamily: 'Pretendard',
                  fontFamilyFallback: const ['Poppins'],
                ),
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
