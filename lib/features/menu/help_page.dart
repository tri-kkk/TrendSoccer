import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: const TsAppBar(
        location: TsAppBarLocation.backTitle,
        title: '도움말',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '문의하기',
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: TsSpacing.lg),
            Text(
              '궁금한 점이나 문제가 있으시면 아래 양식을 작성해주세요.',
              style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: TsSpacing.lg),
            _InputField(
              label: '이름',
              controller: _nameController,
            ),
            const SizedBox(height: TsSpacing.lg),
            _InputField(
              label: '이메일',
              controller: _emailController,
            ),
            const SizedBox(height: TsSpacing.lg),
            _InputField(
              label: '제목',
              controller: _titleController,
            ),
            const SizedBox(height: TsSpacing.lg),
            _InputField(
              label: '메시지',
              controller: _messageController,
              maxLines: 5,
            ),
            const SizedBox(height: TsSpacing.lg),
            TsButton(
              label: '보내기',
              variant: TsButtonVariant.primary,
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: semantic.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: TsSpacing.lg,
            vertical: TsSpacing.md,
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
            decoration: const InputDecoration.collapsed(hintText: ''),
          ),
        ),
      ],
    );
  }
}
