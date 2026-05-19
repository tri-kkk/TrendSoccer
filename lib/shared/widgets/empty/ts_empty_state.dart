import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

enum TsEmptyStateType { defaultState, withAction, premiumPickEmpty }

class TsEmptyState extends StatelessWidget {
  const TsEmptyState({
    this.type = TsEmptyStateType.defaultState,
    this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
    super.key,
  });

  final TsEmptyStateType type;
  final String? title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    final (String? iconAsset, IconData? icon, defaultTitle, defaultSubtitle) =
        switch (type) {
      TsEmptyStateType.premiumPickEmpty => (
          TsAssets.iconHourglassEmpty,
          null,
          '오늘의 픽이 없습니다.',
          '오전 6시 또는 오후 6시에 다시 확인해 주세요.',
        ),
      _ => (
          null,
          Icons.inbox,
          '데이터가 없습니다.',
          '나중에 다시 확인해 주세요.',
        ),
    };

    final resolvedTitle = title ?? defaultTitle;
    final resolvedSubtitle = subtitle ?? defaultSubtitle;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(TsSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconAsset != null)
              SvgPicture.asset(
                iconAsset,
                width: 48,
                height: 48,
                colorFilter: ColorFilter.mode(
                  semantic.textTertiary,
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(icon, size: 48, color: semantic.textTertiary),
            const SizedBox(height: TsSpacing.md),
            Text(
              resolvedTitle,
              style: TsType.bodyLBold.copyWith(color: semantic.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TsSpacing.md),
            Text(
              resolvedSubtitle,
              style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
            if (type == TsEmptyStateType.withAction) ...[
              const SizedBox(height: TsSpacing.md),
              TsButton(
                label: buttonLabel ?? '날짜 변경',
                variant: TsButtonVariant.primary,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
