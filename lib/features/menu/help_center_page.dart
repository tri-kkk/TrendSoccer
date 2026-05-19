import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/back_button.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

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
      appBar: AppBar(
        backgroundColor: semantic.surfaceBase,
        elevation: 0,
        leading: TsBackButton(onPressed: () => context.pop()),
        title: Text(
          '문의하기',
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문의 사항을 남겨주시면 이메일로 답변드리겠습니다.',
              style: TsType.bodyLRegular.copyWith(color: semantic.textTertiary),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              semantic: semantic,
              label: '이름',
              hint: '홍길동',
              controller: _nameController,
              minHeight: 48,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              semantic: semantic,
              label: '이메일',
              hint: 'user@email.com',
              controller: _emailController,
              minHeight: 48,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              semantic: semantic,
              label: '제목',
              hint: '문의 제목을 입력해주세요.',
              controller: _titleController,
              minHeight: 48,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              semantic: semantic,
              label: '메시지',
              hint: '문의 내용을 입력해주세요.',
              controller: _messageController,
              minHeight: 120,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TsButton(
                label: '문의 보내기',
                variant: TsButtonVariant.primary,
                onPressed: () {
                  // TODO: Send email via backend
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('문의가 전송되었습니다.')),
                  );
                  context.pop();
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TsSemanticColors semantic,
    required String label,
    required String hint,
    required TextEditingController controller,
    required double minHeight,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TsType.labelSRegular.copyWith(color: semantic.textSecondary),
        ),
        const SizedBox(height: 4),
        Container(
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            color: semantic.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: semantic.borderDefault, width: 1),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TsType.labelSRegular.copyWith(color: semantic.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TsType.labelSRegular.copyWith(color: semantic.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
