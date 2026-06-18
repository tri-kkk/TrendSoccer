import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/router/app_router.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

/// Double-tap back to exit on root tabs; defers to GoRouter for sub-pages and
/// shell navigator for bottom sheets.
class ExitBackHandler extends ConsumerStatefulWidget {
  const ExitBackHandler({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ExitBackHandler> createState() => _ExitBackHandlerState();
}

class _ExitBackHandlerState extends ConsumerState<ExitBackHandler> {
  static DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: widget.child,
    );
  }

  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }

    final shellNav = AppRouter.shellNavigatorKey.currentState;
    if (shellNav != null && shellNav.canPop()) {
      shellNav.pop();
      return;
    }

    final now = DateTime.now();
    if (_lastBackPress != null &&
        now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPress = now;

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.exitToastMessage,
          style: TsType.bodyMRegular.copyWith(color: Colors.white),
        ),
        backgroundColor: TsColors.error500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TsSpacing.sm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
