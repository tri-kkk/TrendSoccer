import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

abstract final class TsToast {
  static void success(BuildContext context, String message) {
    final sem = Theme.of(context).extension<TsSemanticColors>()!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TsType.bodyMRegular.copyWith(color: sem.surfaceRaised),
        ),
        backgroundColor: sem.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(TsSpacing.lg, 0, TsSpacing.lg, TsSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: TsColors.error500,
      duration: const Duration(seconds: 5),
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: TsColors.neutral700,
      duration: const Duration(seconds: 5),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TsType.bodyLRegular.copyWith(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(TsSpacing.lg, 0, TsSpacing.lg, TsSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: duration,
      ),
    );
  }
}
