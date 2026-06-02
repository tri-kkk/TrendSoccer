import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
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
                  ctx.l10n.signOutTitle,
                  style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TsSpacing.lg),
                Text(
                  ctx.l10n.signOutMessage,
                  style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TsSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TsButton(
                        label: ctx.l10n.cancel,
                        variant: TsButtonVariant.secondary,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Expanded(
                      child: TsButton(
                        label: ctx.l10n.signOutConfirm,
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
