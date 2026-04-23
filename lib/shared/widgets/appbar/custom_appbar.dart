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
///
/// CustomAppBar(
///   title: 'Match Report',
///   centerTitle: true,
///   onBackPressed: () => Navigator.pop(context),
/// )
/// ```
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.centerTitle = false,
  });

  /// Text displayed next to the back button.
  final String title;

  /// Called when the back button is tapped.
  /// If null, the back button still renders but does nothing.
  final VoidCallback? onBackPressed;

  /// When `true`, [title] is centered in the bar (trailing spacer balances the
  /// back control). When `false`, the title follows the back button (default).
  final bool centerTitle;

  static const double _leadingSlotWidth = 40 + 12;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTypography.titleMedium.copyWith(
      color: AppColors.textPrimary,
    );

    return Container(
      height: 56,
      width: double.infinity,
      color: AppColors.surfaceBase,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: centerTitle
          ? Row(
              children: [
                CustomBackButton(onPressed: onBackPressed),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
                const SizedBox(width: _leadingSlotWidth),
              ],
            )
          : Row(
              children: [
                CustomBackButton(onPressed: onBackPressed),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
              ],
            ),
    );
  }
}
