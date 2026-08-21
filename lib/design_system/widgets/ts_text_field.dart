import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsTextField extends StatefulWidget {
  const TsTextField({
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.multiline = false,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final bool multiline;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  State<TsTextField> createState() => _TsTextFieldState();
}

class _TsTextFieldState extends State<TsTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final hasError = widget.errorText != null;
    final focused = _focusNode.hasFocus;

    final borderColor = hasError
        ? c.error
        : focused
            ? c.borderFocus
            : c.borderDefault;
    final borderWidth = hasError
        ? 1.0
        : focused
            ? TsSpacing.xxs
            : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: TsType.bodyLBold.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          height: widget.multiline ? 150 : null,
          padding: const EdgeInsets.all(TsSpacing.md),
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: TsRadius.sm,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.multiline ? null : 1,
            expands: widget.multiline,
            textAlignVertical:
                widget.multiline ? TextAlignVertical.top : TextAlignVertical.center,
            style: TsType.bodyLMedium.copyWith(color: c.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: TsType.bodyLMedium.copyWith(color: c.textTertiary),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: TsSpacing.sm),
          Text(
            widget.errorText!,
            style: TsType.labelSMedium.copyWith(color: c.error),
          ),
        ],
      ],
    );
  }
}
