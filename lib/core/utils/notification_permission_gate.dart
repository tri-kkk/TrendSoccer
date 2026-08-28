import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/design_system/widgets/ts_confirm_dialog.dart';

/// Completed OS notification permission state after a status read or request.
enum NotificationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

/// Reads notification permission and requests it when the OS still allows prompting.
///
/// Does not show any in-app dialog. Returns `null` when the flow throws before a
/// determinate outcome (callers should leave retry prefs unset).
Future<NotificationPermissionStatus?> resolveNotificationPermission({
  bool requestIfNeeded = true,
}) async {
  try {
    var status = await Permission.notification.status;
    if (status.isGranted) {
      return NotificationPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return NotificationPermissionStatus.permanentlyDenied;
    }
    if (!requestIfNeeded) {
      return NotificationPermissionStatus.denied;
    }

    status = await Permission.notification.request();
    if (status.isGranted) {
      return NotificationPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return NotificationPermissionStatus.permanentlyDenied;
    }
    return NotificationPermissionStatus.denied;
  } on Object {
    return null;
  }
}

/// Returns whether the caller may proceed with notification-dependent work.
///
/// Reads status, requests the OS permission when still allowed, then shows the
/// single app-wide settings dialog when permission remains denied.
Future<bool> ensureNotificationPermissionGate(
  BuildContext context, {
  bool forMatchAlarm = false,
}) async {
  final outcome = await resolveNotificationPermission(requestIfNeeded: true);

  if (outcome == NotificationPermissionStatus.granted) {
    return context.mounted;
  }

  if (!context.mounted) return false;
  await _showNotificationPermissionDialog(
    context,
    forMatchAlarm: forMatchAlarm,
  );
  return false;
}

Future<void> _showNotificationPermissionDialog(
  BuildContext context, {
  required bool forMatchAlarm,
}) async {
  final l10n = context.l10n;
  final openSettings = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 320,
        child: TsConfirmDialog(
          type: TsDialogType.normal,
          title: l10n.notificationPermissionTitle,
          message: forMatchAlarm
              ? l10n.notificationPermissionMessageMatch
              : l10n.notificationPermissionMessage,
          confirmLabel: l10n.notificationPermissionGoSettings,
          cancelLabel: l10n.cancel,
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
        ),
      ),
    ),
  );

  if (openSettings == true) {
    await openAppSettings();
  }
}
