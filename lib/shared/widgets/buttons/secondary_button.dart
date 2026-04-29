import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import 'primary_button.dart';

/// Outlined secondary action — pairs with [PrimaryButton] on auth flows.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.size = ButtonSize.large,
    this.onPressed,
  });

  final String label;
  final ButtonSize size;
  final VoidCallback? onPressed;

  bool get _isLarge => size == ButtonSize.large;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        disabledForegroundColor: AppColors.textDisabled,
        side: BorderSide(
          color: onPressed == null
              ? AppColors.textDisabled
              : AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        padding: _isLarge
            ? const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.lg,
              )
            : const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: 10,
              ),
        minimumSize:
            _isLarge ? const Size(0, AppSpacing.buttonHeight) : const Size(0, 40),
        textStyle: AppTypography.labelLarge,
      ),
      child: Text(label),
    );

    if (_isLarge) {
      return SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: button,
      );
    }

    return button;
  }
}
