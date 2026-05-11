import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/back_button.dart';

enum TsAppBarLocation { home, backTitle }

class TsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TsAppBar({
    required this.location,
    this.title,
    this.onBack,
    this.trailing,
    this.leading,
    super.key,
  });

  final TsAppBarLocation location;
  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? leading;

  @override
  Size get preferredSize => Size.fromHeight(
        location == TsAppBarLocation.home ? 56 : 52,
      );

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final bottomBorder = BorderSide(
      color: semantic.textDisabled,
      width: 2,
    );

    return switch (location) {
      TsAppBarLocation.home => Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
            border: Border(bottom: bottomBorder),
          ),
          child: Row(
            children: [
              leading ?? const SizedBox.shrink(),
              const Spacer(),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
        ),
      TsAppBarLocation.backTitle => Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
            border: Border(bottom: bottomBorder),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  title ?? '',
                  style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TsBackButton(onPressed: onBack),
              ),
            ],
          ),
        ),
    };
  }
}
