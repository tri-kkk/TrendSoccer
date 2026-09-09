import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/services/blog_service.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_text_field.dart';
import 'package:trendsoccer/design_system/widgets/ts_toast.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;
  String? _nameError;
  String? _emailError;
  String? _subjectError;
  String? _messageError;

  static final _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  @override
  void initState() {
    super.initState();
    _applyPrefill();
  }

  void _applyPrefill() {
    final auth = ref.read(authProvider);
    if (!auth.isLoggedIn) return;
    _nameController.text = auth.userName;
    _emailController.text = auth.userEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showToast(String message, TsToastType type) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: TsToast(message: message, type: type),
      ),
    );
  }

  bool _validate(AppLocalizations l10n) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    String? nameError;
    String? emailError;
    String? subjectError;
    String? messageError;

    if (name.isEmpty) {
      nameError = l10n.formRequired;
    }
    if (email.isEmpty) {
      emailError = l10n.formRequired;
    } else if (!_emailPattern.hasMatch(email)) {
      emailError = l10n.helpEmailInvalid;
    }
    if (subject.isEmpty) {
      subjectError = l10n.formRequired;
    }
    if (message.isEmpty) {
      messageError = l10n.formRequired;
    }

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _subjectError = subjectError;
      _messageError = messageError;
    });

    return nameError == null &&
        emailError == null &&
        subjectError == null &&
        messageError == null;
  }

  Future<void> _submit() async {
    if (_isSending) return;
    final l10n = AppLocalizations.of(context)!;
    if (!_validate(l10n)) return;

    setState(() => _isSending = true);

    try {
      final result = await ref.read(blogServiceProvider).sendContactForm(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            subject: _subjectController.text.trim(),
            message: _messageController.text.trim(),
          );

      if (!mounted) return;

      if (result['success'] == true) {
        _subjectController.clear();
        _messageController.clear();
        _formKey.currentState?.reset();
        _applyPrefill();
        setState(() {
          _nameError = null;
          _emailError = null;
          _subjectError = null;
          _messageError = null;
        });
        _showToast(l10n.helpInquirySentToast, TsToastType.success);
        return;
      }

      _showToast(resolveApiError(context, result), TsToastType.error);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: l10n.menuHelp,
        onBack: () => context.go('/menu'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  TsSpacing.lg,
                  TsSpacing.lg,
                  TsSpacing.lg,
                  TsSpacing.xl,
                ),
                child: Form(
                  key: _formKey,
                  child: IgnorePointer(
                    ignoring: _isSending,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.helpScreenIntro,
                          style: TsType.bodyLMedium.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        TsTextField(
                          label: l10n.helpCenterName,
                          controller: _nameController,
                          errorText: _nameError,
                          onChanged: (_) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        TsTextField(
                          label: l10n.helpCenterEmail,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        TsTextField(
                          label: l10n.helpCenterSubject,
                          controller: _subjectController,
                          errorText: _subjectError,
                          onChanged: (_) {
                            if (_subjectError != null) {
                              setState(() => _subjectError = null);
                            }
                          },
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        TsTextField(
                          label: l10n.helpCenterMessage,
                          controller: _messageController,
                          multiline: true,
                          errorText: _messageError,
                          onChanged: (_) {
                            if (_messageError != null) {
                              setState(() => _messageError = null);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(TsSpacing.lg),
              child: TsButton(
                label: l10n.helpCenterSend,
                style: TsButtonStyle.primary,
                size: TsButtonSize.large,
                expand: true,
                onPressed: _isSending ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
