import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/design_system/icons/ts_logo.dart';
import 'package:trendsoccer/design_system/icons/ts_social_symbol.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _busy = false;

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
    try {
      await login().timeout(const Duration(seconds: 30));
      if (!mounted) return;

      final auth = ref.read(authProvider);
      if (auth.needsConsent) {
        context.go('/signup/terms');
        return;
      }
      context.go('/home');
    } on AuthLoginException catch (e) {
      if (e.reason == 'cancelled') return;
      debugPrint('[login] AuthLoginException reason=${e.reason} cause=${e.cause}');
      if (!mounted) return;
      final causeText = e.cause?.toString() ?? '';
      if (causeText.contains('COOLDOWN_ACTIVE')) {
        final days = int.tryParse(causeText.split(':').last.trim()) ?? 7;
        _showErrorToast(
          'This account was deleted. You can sign up again in $days days.',
        );
        return;
      }
      _showErrorToast(_messageForAuthFailure(e.reason));
    } on TimeoutException {
      if (!mounted) return;
      _showErrorToast('Sign-in timed out. Please try again.');
    } on Object catch (e) {
      debugPrint('[login] unexpected: $e');
      if (!mounted) return;
      _showErrorToast('Sign-in failed. Please try again.');
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

  String _messageForAuthFailure(String reason) => switch (reason) {
        'timeout' => 'Sign-in timed out. Please try again.',
        'network_error' =>
          'Network error. Check your connection and try again.',
        'api_error' =>
          // TODO(diagnostic): remove code from user-facing copy once the cause is found
          'Sign-in was rejected by the server. (api_error)',
        'sdk_error' =>
          // TODO(diagnostic): remove code from user-facing copy once the cause is found
          'The sign-in provider reported an error. (sdk_error)',
        'token_null' =>
          // TODO(diagnostic): remove code from user-facing copy once the cause is found
          'No sign-in token was returned. (token_null)',
        'profile_load_failed' =>
          // TODO(diagnostic): remove code from user-facing copy once the cause is found
          'Signed in, but the profile could not load. (profile_load_failed)',
        _ => 'Sign-in failed. Please try again.',
      };

  VoidCallback? get _googleHandler =>
      _busy ? null : () => _signIn(ref.read(authProvider).loginWithGoogle);

  VoidCallback? get _naverHandler =>
      _busy ? null : () => _signIn(ref.read(authProvider).loginWithNaver);

  VoidCallback? get _guestHandler => _busy
      ? null
      : () {
          context.go('/home');
        };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: TsSpacing.lg,
              right: TsSpacing.lg,
              top: 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const TsLogo(TsLogoType.vertical, height: 134),
                  const SizedBox(height: TsSpacing.xxxl),
                  Text(
                    'Better Data,\nSmarter Analysis Reports,\nFor Your Choice.',
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
                    label: 'Continue with Google',
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
                    label: 'Continue with Naver',
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
                    label: 'Continue as guest',
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
    );
  }
}
