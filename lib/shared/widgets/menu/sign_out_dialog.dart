import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

/// Dialog helpers; use static [show] only.
class SignOutDialog {
  const SignOutDialog._();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final semantic = Theme.of(ctx).extension<TsSemanticColors>()!;
        final maxW = MediaQuery.sizeOf(ctx).width - 64;
        final w = maxW < 348 ? maxW : 348.0;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            width: w,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: semantic.surfaceOverlay,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '로그아웃',
                  style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TsSpacing.lg),
                Text(
                  '정말 로그아웃 하시겠습니까?',
                  style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TsSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TsButton(
                        label: '취소',
                        variant: TsButtonVariant.secondary,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Expanded(
                      child: TsButton(
                        label: '로그아웃',
                        variant: TsButtonVariant.primary,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
