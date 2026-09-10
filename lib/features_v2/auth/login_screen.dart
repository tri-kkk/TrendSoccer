import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/design_system/icons/ts_logo.dart';
import 'package:trendsoccer/design_system/icons/ts_social_symbol.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _busy = false;

  static const _heroBlockTopBeforeAppBar = 180;
  static const _heroBlockTop =
      _heroBlockTopBeforeAppBar - TsAppBar.toolbarHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(authProvider).isLoggedIn) {
        context.go('/home');
      }
    });
  }

  Future<void> _signIn(Future<void> Function() login) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await login();
      if (!mounted) return;

      final auth = ref.read(authProvider);
      if (auth.needsConsent) {
        context.go('/signup/terms');
        return;
      }
      _handleBack();
    } on AuthLoginException catch (e) {
      debugPrint('[login] AuthLoginException reason=${e.reason} cause=${e.cause}');
      if (e.reason == 'cancelled') return;
      if (!mounted) return;
      final causeText = e.cause?.toString() ?? '';
      if (causeText.contains('COOLDOWN_ACTIVE')) {
        final days = int.tryParse(causeText.split(':').last.trim()) ?? 7;
        _showErrorToast(l10n.loginErrorAccountDeleted(days));
        return;
      }
      _showErrorToast(_messageForAuthFailure(l10n, e.reason));
    } on Object catch (e) {
      debugPrint('[login] unexpected: $e');
      if (!mounted) return;
      _showErrorToast(l10n.loginErrorTryAgain);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showErrorToast(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: TsToast(message: message, type: TsToastType.error),
      ),
    );
  }

  String _messageForAuthFailure(AppLocalizations l10n, String reason) {
    switch (reason) {
      case 'timeout':
        debugPrint('[login] auth failure: timeout');
        return l10n.loginErrorTimeout;
      case 'network_error':
        debugPrint('[login] auth failure: network_error');
        return l10n.loginErrorNetwork;
      case 'api_error':
        debugPrint('[login] auth failure: api_error');
        return l10n.loginErrorTryAgain;
      case 'sdk_error':
        debugPrint('[login] auth failure: sdk_error');
        return l10n.loginErrorTryAgain;
      case 'token_null':
        debugPrint('[login] auth failure: token_null');
        return l10n.loginErrorTryAgain;
      case 'profile_load_failed':
        debugPrint('[login] auth failure: profile_load_failed');
        return l10n.loginErrorProfileLoadFailed;
      default:
        debugPrint('[login] auth failure: $reason');
        return l10n.loginErrorTryAgain;
    }
  }

  VoidCallback? get _googleHandler =>
      _busy ? null : () => _signIn(ref.read(authProvider).loginWithGoogle);

  VoidCallback? get _naverHandler =>
      _busy ? null : () => _signIn(ref.read(authProvider).loginWithNaver);

  VoidCallback? get _guestHandler => _busy
      ? null
      : () {
          context.go('/home');
        };

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: c.canvas,
        appBar: TsAppBar(
          type: TsAppBarType.back,
          title: l10n.authLogIn,
          onBack: _handleBack,
        ),
        body: SafeArea(
          top: false,
          child: Stack(
          children: [
            Positioned(
              left: TsSpacing.lg,
              right: TsSpacing.lg,
              top: _heroBlockTop,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const TsLogo(TsLogoType.vertical, height: 134),
                  const SizedBox(height: TsSpacing.xxxl),
                  Text(
                    l10n.loginTitle,
                    style: TsType.displayLg.copyWith(color: c.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              left: TsSpacing.lg,
              right: TsSpacing.lg,
              bottom: TsSpacing.xxxl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TsButton(
                    label: l10n.loginGoogle,
                    style: TsButtonStyle.secondary,
                    size: TsButtonSize.large,
                    iconWidget: const TsSocialSymbol(
                      TsSocialPlatform.google,
                      size: TsIconSize.sm,
                    ),
                    onPressed: _googleHandler,
                    expand: true,
                  ),
                  const SizedBox(height: TsSpacing.md),
                  TsButton(
                    label: l10n.loginNaver,
                    style: TsButtonStyle.secondary,
                    size: TsButtonSize.large,
                    iconWidget: const TsSocialSymbol(
                      TsSocialPlatform.naver,
                      size: TsIconSize.sm,
                    ),
                    onPressed: _naverHandler,
                    expand: true,
                  ),
                  const SizedBox(height: TsSpacing.md),
                  TsButton(
                    label: l10n.loginGuestButton,
                    style: TsButtonStyle.ghost,
                    size: TsButtonSize.large,
                    onPressed: _guestHandler,
                    expand: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
