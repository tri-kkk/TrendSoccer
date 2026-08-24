import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_confirm_dialog.dart';
import 'package:trendsoccer/design_system/widgets/ts_toast.dart';
import 'package:trendsoccer/features_v2/menu/privacy_screen.dart';
import 'package:trendsoccer/features_v2/menu/terms_screen.dart';

class SignupTermsScreen extends ConsumerStatefulWidget {
  const SignupTermsScreen({super.key});

  @override
  ConsumerState<SignupTermsScreen> createState() => _SignupTermsScreenState();
}

class _SignupTermsScreenState extends ConsumerState<SignupTermsScreen> {
  bool _terms = false;
  bool _privacy = false;
  bool _marketing = false;
  bool _busy = false;

  bool get _agreeAll => _terms && _privacy && _marketing;
  bool get _canSubmit => _terms && _privacy;

  Future<void> _confirmExit() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: TsConfirmDialog(
          type: TsDialogType.destructive,
          title: 'Leave sign-up?',
          message:
              'Your account will not be activated until you agree to the terms.',
          confirmLabel: 'Leave',
          cancelLabel: 'Stay',
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
        ),
      ),
    );

    if (shouldLeave != true) return;
    await ref.read(authProvider).signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final ok = await ref.read(authProvider).completeSignup(
            terms: _terms,
            privacy: _privacy,
            marketing: _marketing,
          );
      if (!mounted) return;
      if (ok) {
        context.go('/signup/complete');
      } else {
        _showErrorToast('Unable to complete sign-up. Please try again.');
      }
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

  void _toggleAgreeAll() {
    setState(() {
      final next = !_agreeAll;
      _terms = next;
      _privacy = next;
      _marketing = next;
    });
  }

  void _openTerms() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TermsScreen()),
    );
  }

  void _openPrivacy() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
    );
  }

  Widget _checkboxIcon(bool checked, Color color) {
    return TsIcon(
      checked ? TsIcons.checkBox : TsIcons.checkBoxOutlineBlank,
      size: TsIconSize.md,
      color: color,
    );
  }

  Widget _consentRow({
    required TsThemeColors c,
    required bool checked,
    required VoidCallback onToggle,
    required TextStyle labelStyle,
    required String label,
    VoidCallback? onView,
  }) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TsSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    _checkboxIcon(checked, c.textPrimary),
                    const SizedBox(width: TsSpacing.md),
                    Expanded(
                      child: Text(
                        label,
                        style: labelStyle.copyWith(color: c.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onView != null) ...[
              const SizedBox(width: TsSpacing.md),
              GestureDetector(
                onTap: onView,
                behavior: HitTestBehavior.opaque,
                child: TsIcon(
                  TsIcons.chevronRight,
                  size: TsIconSize.sm,
                  color: c.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmExit();
      },
      child: Scaffold(
        backgroundColor: c.canvas,
        appBar: TsAppBar(
          type: TsAppBarType.back,
          title: 'Terms',
          onBack: _confirmExit,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    TsSpacing.lg,
                    TsSpacing.xl,
                    TsSpacing.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Agree to terms\nto get started',
                        style: TsType.h1.copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: TsSpacing.lg),
                      _consentRow(
                        c: c,
                        checked: _agreeAll,
                        onToggle: _toggleAgreeAll,
                        labelStyle: TsType.bodyLBold,
                        label: 'Agree to all',
                      ),
                      const SizedBox(height: TsSpacing.lg),
                      Container(height: 1, color: c.borderSubtle),
                      const SizedBox(height: TsSpacing.lg),
                      _consentRow(
                        c: c,
                        checked: _terms,
                        onToggle: () => setState(() => _terms = !_terms),
                        labelStyle: TsType.bodyLMedium,
                        label: '[Required] Terms of service',
                        onView: _openTerms,
                      ),
                      const SizedBox(height: TsSpacing.lg),
                      _consentRow(
                        c: c,
                        checked: _privacy,
                        onToggle: () => setState(() => _privacy = !_privacy),
                        labelStyle: TsType.bodyLMedium,
                        label: '[Required] Privacy policy',
                        onView: _openPrivacy,
                      ),
                      const SizedBox(height: TsSpacing.lg),
                      _consentRow(
                        c: c,
                        checked: _marketing,
                        onToggle: () => setState(() => _marketing = !_marketing),
                        labelStyle: TsType.bodyLMedium,
                        label: '[Optional] Marketing messages',
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(TsSpacing.lg),
                child: TsButton(
                  label: 'Continue',
                  style: TsButtonStyle.primary,
                  size: TsButtonSize.large,
                  expand: true,
                  onPressed: _canSubmit && !_busy ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
