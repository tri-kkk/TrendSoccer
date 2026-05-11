import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

/// Dialog helpers; use static [show] only.
class DeleteAccountDialog {
  const DeleteAccountDialog._();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => const _DeleteAccountDialogBody(),
    );
  }
}

class _DeleteAccountDialogBody extends StatefulWidget {
  const _DeleteAccountDialogBody();

  @override
  State<_DeleteAccountDialogBody> createState() => _DeleteAccountDialogBodyState();
}

class _DeleteAccountDialogBodyState extends State<_DeleteAccountDialogBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canDelete => _controller.text == 'DELETE';

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final maxW = MediaQuery.sizeOf(context).width - 64;
    final w = maxW < 348 ? maxW : 348.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        width: w,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: semantic.surfaceOverlay,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '계정 삭제',
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TsSpacing.lg),
            Text(
              '계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.\n확인을 위해 아래에 DELETE를 입력하세요.',
              style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TsSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
              decoration: BoxDecoration(
                color: semantic.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
                cursorColor: semantic.textPrimary,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'DELETE',
                  hintStyle: TsType.bodyLRegular.copyWith(color: semantic.textDisabled),
                ),
              ),
            ),
            const SizedBox(height: TsSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TsButton(
                    label: '취소',
                    variant: TsButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: TsSpacing.sm),
                Expanded(
                  child: TsButton(
                    label: '삭제',
                    variant: TsButtonVariant.primary,
                    onPressed: _canDelete ? () => Navigator.of(context).pop(true) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
