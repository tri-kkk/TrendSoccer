import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';

/// An 8×8 circular dot used as a page/carousel indicator.
///
/// [isActive] toggles between the brand primary colour and the tertiary
/// text colour.
///
/// ```dart
/// Row(
///   children: [
///     BannerIndicator(isActive: true),
///     SizedBox(width: 8),
///     BannerIndicator(isActive: false),
///   ],
/// )
/// ```
class BannerIndicator extends StatelessWidget {
  const BannerIndicator({
    super.key,
    required this.isActive,
  });

  /// Whether this dot represents the currently visible page.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary500 : AppColors.textTertiary,
      ),
    );
  }
}
