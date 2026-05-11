import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/bottom_sheet/ts_bottom_sheet_handle.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class TsBottomSheet extends StatelessWidget {
  const TsBottomSheet({
    required this.title,
    required this.content,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
    super.key,
  });

  final String title;
  final Widget content;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;

  static Future<T?> show<T>(BuildContext context, {required TsBottomSheet sheet}) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ColoredBox(
        color: semantic.surfaceOverlay,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TsBottomSheetHandle(),
              const SizedBox(height: TsSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  content,
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TsButton(
                    label: primaryButtonLabel,
                    variant: TsButtonVariant.primary,
                    onPressed: onPrimaryPressed,
                  ),
                  if (secondaryButtonLabel != null) ...[
                    const SizedBox(height: TsSpacing.sm),
                    TsButton(
                      label: secondaryButtonLabel!,
                      variant: TsButtonVariant.secondary,
                      onPressed: onSecondaryPressed,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
