import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/features_v2/shell/exit_dialog.dart';

/// Intercepts back on a tab-branch root and shows the exit dialog.
///
/// When the active shell branch navigator can still pop (e.g. menu
/// sub-settings), back is delegated to that navigator instead.
class ShellExitPopScope extends StatelessWidget {
  const ShellExitPopScope({
    required this.navigationShell,
    required this.child,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final Widget child;

  bool _activeBranchCanPop() {
    final branch = navigationShell.route.branches[navigationShell.currentIndex];
    return branch.navigatorKey.currentState?.canPop() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final branchCanPop = _activeBranchCanPop();

    return PopScope(
      canPop: branchCanPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showExitDialog(context);
      },
      child: child,
    );
  }
}
