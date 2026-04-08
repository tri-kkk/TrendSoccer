import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../buttons/back_button.dart';

/// TrendSoccer custom app bar with a back button and title.
///
/// Renders a 56px-tall bar containing [CustomBackButton] followed by
/// a 12px gap and the [title] text styled with [AppTypography.titleMedium].
///
/// ```dart
/// CustomAppBar(
///   title: 'Match Detail',
///   onBackPressed: () => Navigator.pop(context),
/// )
/// ```
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  /// Text displayed next to the back button.
  final String title;

  /// Called when the back button is tapped.
  /// If null, the back button still renders but does nothing.
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      color: AppColors.surfaceBase,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CustomBackButton(onPressed: onBackPressed),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
