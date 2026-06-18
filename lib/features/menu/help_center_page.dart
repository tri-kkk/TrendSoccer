import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/blog_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class HelpCenterPage extends ConsumerStatefulWidget {
  const HelpCenterPage({super.key});

  @override
  ConsumerState<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends ConsumerState<HelpCenterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(TsSemanticColors colors) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TsSpacing.sm),
        borderSide: BorderSide(color: colors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TsSpacing.sm),
        borderSide: BorderSide(color: colors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TsSpacing.sm),
        borderSide: BorderSide(color: colors.interactivePrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TsSpacing.sm),
        borderSide: const BorderSide(color: TsColors.error500),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TsSpacing.sm),
        borderSide: const BorderSide(color: TsColors.error500, width: 2),
      ),
      filled: true,
      fillColor: colors.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TsSpacing.md,
        vertical: TsSpacing.md,
      ),
    );
  }

  Widget _buildField({
    required TsSemanticColors colors,
    required String title,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TsType.bodyLBold.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        TextFormField(
          controller: controller,
          enabled: !_isSending,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          validator: validator,
          decoration: _inputDecoration(colors),
          style: TsType.bodyLRegular.copyWith(color: colors.textPrimary),
          cursorColor: colors.interactivePrimary,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_isSending) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSending = true);

    final service = ref.read(blogServiceProvider);
    final result = await service.sendContactForm(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      subject: _titleController.text.trim(),
      message: _messageController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSending = false);

    final success = result['success'] == true;
    if (success) {
      _nameController.clear();
      _emailController.clear();
      _titleController.clear();
      _messageController.clear();
      _formKey.currentState?.reset();
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.helpCenterSubmitSuccess),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          resolveApiError(context, result),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.surfaceRaised,
      appBar: AppBar(
        title: Text(
          l10n.helpCenterTitle,
          style: TsType.headingH3.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.surfaceRaised,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: colors.textDisabled),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: TsSpacing.lg,
          right: TsSpacing.lg,
          top: TsSpacing.lg,
          bottom: TsSpacing.lg + MediaQuery.paddingOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.helpCenterIntro,
                style: TsType.bodyLRegular.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: TsSpacing.lg),
              _buildField(
                colors: colors,
                title: l10n.helpCenterName,
                controller: _nameController,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? l10n.formRequired : null,
              ),
              const SizedBox(height: TsSpacing.lg),
              _buildField(
                colors: colors,
                title: l10n.helpCenterEmail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.isEmpty ?? true) return l10n.formRequired;
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v!)) {
                    return l10n.formInvalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: TsSpacing.lg),
              _buildField(
                colors: colors,
                title: l10n.helpCenterSubject,
                controller: _titleController,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? l10n.formRequired : null,
              ),
              const SizedBox(height: TsSpacing.lg),
              _buildField(
                colors: colors,
                title: l10n.helpCenterMessage,
                controller: _messageController,
                minLines: 6,
                maxLines: 10,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? l10n.formRequired : null,
              ),
              const SizedBox(height: TsSpacing.lg),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: TsButton(
                      label: l10n.helpCenterSend,
                      variant: TsButtonVariant.primary,
                      onPressed: _isSending ? null : _submit,
                    ),
                  ),
                  if (_isSending)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.surfaceBase,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: TsSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
