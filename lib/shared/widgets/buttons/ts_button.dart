import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum TsButtonVariant { primary, secondary }

enum TsButtonSize { large, small }

class TsButton extends StatelessWidget {
  const TsButton({
    required this.label,
    this.onPressed,
    this.variant = TsButtonVariant.primary,
    this.size = TsButtonSize.large,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final TsButtonVariant variant;
  final TsButtonSize size;

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return switch (variant) {
      TsButtonVariant.primary => _buildPrimary(semantic),
      TsButtonVariant.secondary => _buildSecondary(semantic),
    };
  }

  Widget _buildPrimary(TsSemanticColors semantic) {
    final backgroundColor =
        _enabled ? semantic.interactivePrimary : semantic.textDisabled;
    final textColor = _enabled ? semantic.surfaceBase : semantic.textTertiary;
    final labelStyle = _labelStyle.copyWith(color: textColor);

    final content = _InnerPadding(
      size: size,
      child: Text(
        label,
        style: labelStyle,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    final tapChild = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );

    return size == TsButtonSize.large
        ? SizedBox(width: double.infinity, height: 48, child: tapChild)
        : SizedBox(height: 32, child: IntrinsicWidth(child: tapChild));
  }

  Widget _buildSecondary(TsSemanticColors semantic) {
    final borderColor = _enabled ? semantic.interactivePrimary : semantic.textDisabled;
    final textColor = _enabled ? semantic.interactivePrimary : semantic.textDisabled;
    final labelStyle = _labelStyle.copyWith(color: textColor);

    final content = _InnerPadding(
      size: size,
      child: Text(
        label,
        style: labelStyle,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: content,
        ),
      ),
    );

    return size == TsButtonSize.large
        ? SizedBox(width: double.infinity, height: 48, child: decorated)
        : SizedBox(height: 32, child: IntrinsicWidth(child: decorated));
  }

  TextStyle get _labelStyle =>
      size == TsButtonSize.large ? TsType.bodyLBold : TsType.bodyMBold;
}

class _InnerPadding extends StatelessWidget {
  const _InnerPadding({required this.size, required this.child});

  final TsButtonSize size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = size == TsButtonSize.large
        ? const EdgeInsets.symmetric(
            horizontal: TsSpacing.xl,
            vertical: TsSpacing.md,
          )
        : const EdgeInsets.symmetric(
            horizontal: TsSpacing.lg,
            vertical: TsSpacing.xs,
          );
    return Padding(
      padding: padding,
      child: Center(child: child),
    );
  }
}
