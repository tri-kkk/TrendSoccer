import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';

/// TrendSoccer back button component.
///
/// A simple 40×40 transparent button with arrow_back icon.
/// Commonly used in AppBar leading widget.
class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: const Icon(
          Icons.arrow_back,
          size: 24,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
