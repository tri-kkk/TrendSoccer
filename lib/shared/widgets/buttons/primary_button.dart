import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// Size variants for [PrimaryButton].
enum ButtonSize {
  /// Full-width 380×48 button.
  large,

  /// Hug-content width, 40px height button.
  small,
}

/// The main CTA button used throughout TrendSoccer.
///
/// Two size variants:
/// - [ButtonSize.large]: fills parent width, 48 tall — used for form
///   submissions and primary page actions. Constrain the parent to limit
///   width (e.g. `SizedBox(width: 380, child: PrimaryButton(...))`).
/// - [ButtonSize.small]: width hugs label, 40 tall — used inline (e.g. app
///   bar "Join Now").
///
/// ```dart
/// PrimaryButton(
///   label: 'Analyze',
///   size: ButtonSize.large,
///   onPressed: () {},
/// )
///
/// PrimaryButton(
///   label: 'Join Now',
///   size: ButtonSize.small,
///   onPressed: () {},
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.size = ButtonSize.large,
    this.onPressed,
  });

  /// Button label text.
  final String label;

  /// Controls the width/height variant.
  final ButtonSize size;

  /// Called when the button is pressed. Visually disabled when `null`.
  final VoidCallback? onPressed;

  bool get _isLarge => size == ButtonSize.large;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.surfaceBase,
        disabledBackgroundColor: AppColors.surfaceContainer,
        disabledForegroundColor: AppColors.textDisabled,
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
        minimumSize: _isLarge ? const Size(0, AppSpacing.buttonHeight) : const Size(0, 40),
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
