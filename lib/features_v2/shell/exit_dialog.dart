import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:trendsoccer/design_system/widgets/ts_confirm_dialog.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

Future<void> showExitDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 320,
        child: TsConfirmDialog(
          title: l10n.exitDialogTitle,
          message: l10n.exitDialogMessage,
          confirmLabel: l10n.exitDialogConfirm,
          cancelLabel: l10n.cancel,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            SystemNavigator.pop();
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
        ),
      ),
    ),
  );
}
