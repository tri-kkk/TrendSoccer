import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';

/// Shows notification permission dialog; opens app settings when confirmed.
Future<void> showNotificationPermissionDialog(
  BuildContext context, {
  bool forMatchAlarm = false,
}) async {
  final shouldOpen = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final semantic = Theme.of(ctx).extension<TsSemanticColors>()!;
      return AlertDialog(
        backgroundColor: semantic.surfaceOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          ctx.l10n.notificationPermissionTitle,
          style: TextStyle(color: semantic.textPrimary),
        ),
        content: Text(
          forMatchAlarm
              ? ctx.l10n.notificationPermissionMessageMatch
              : ctx.l10n.notificationPermissionMessage,
          style: TextStyle(color: semantic.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              ctx.l10n.cancel,
              style: TextStyle(color: semantic.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              ctx.l10n.notificationPermissionGoSettings,
              style: TextStyle(color: semantic.interactivePrimary),
            ),
          ),
        ],
      );
    },
  );

  if (shouldOpen == true) {
    await openAppSettings();
  }
}
