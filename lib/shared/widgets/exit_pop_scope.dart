import 'package:flutter/material.dart';

import 'package:trendsoccer/shared/widgets/dialogs/exit_dialog.dart';

class ExitPopScope extends StatelessWidget {
  const ExitPopScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showExitDialog(context);
      },
      child: child,
    );
  }
}
