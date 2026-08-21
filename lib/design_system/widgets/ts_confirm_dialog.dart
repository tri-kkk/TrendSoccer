import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_text_field.dart';

enum TsDialogType { normal, destructive, input, loading }

class TsConfirmDialog extends StatelessWidget {
  const TsConfirmDialog({
    required this.title,
    required this.message,
    this.type = TsDialogType.normal,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.inputHint,
    this.inputLabel,
    this.controller,
    this.onConfirm,
    this.onCancel,
    super.key,
  });

  final String title;
  final String message;
  final TsDialogType type;
  final String confirmLabel;
  final String cancelLabel;
  final String? inputHint;
  final String? inputLabel;
  final TextEditingController? controller;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final confirmStyle = type == TsDialogType.destructive ||
            type == TsDialogType.input
        ? TsButtonStyle.danger
        : TsButtonStyle.primary;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.xl),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TsType.h3.copyWith(color: c.textPrimary)),
              const SizedBox(height: TsSpacing.md),
              Text(
                message,
                style: TsType.bodyLRegular.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          if (type == TsDialogType.input) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (inputHint != null)
                  Text(
                    inputHint!,
                    style:
                        TsType.bodyMRegular.copyWith(color: c.textSecondary),
                  ),
                if (inputHint != null) const SizedBox(height: TsSpacing.md),
                TsTextField(
                  label: inputLabel ?? '',
                  controller: controller,
                ),
              ],
            ),
            const SizedBox(height: TsSpacing.lg),
          ],
          if (type == TsDialogType.loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TsSpacing.md),
              child: Center(child: _RotatingHourglass(color: c.primary)),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TsButton(
                    label: cancelLabel,
                    style: TsButtonStyle.secondary,
                    onPressed: onCancel,
                  ),
                ),
                const SizedBox(width: TsSpacing.sm),
                Expanded(
                  child: TsButton(
                    label: confirmLabel,
                    style: confirmStyle,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RotatingHourglass extends StatefulWidget {
  const _RotatingHourglass({required this.color});

  final Color color;

  @override
  State<_RotatingHourglass> createState() => _RotatingHourglassState();
}

class _RotatingHourglassState extends State<_RotatingHourglass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: TsIcon(
        TsIcons.hourglassEmpty,
        size: TsSpacing.xl,
        color: widget.color,
      ),
    );
  }
}
