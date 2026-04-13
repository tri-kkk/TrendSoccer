import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// A placeholder card for an event/promotion banner.
///
/// Renders a 1:1 aspect-ratio container with a centered icon and label.
/// Expands to fill available width; wrap with padding externally.
/// Replace the child with an actual image or rich content later.
///
/// ```dart
/// BannerEvent(onTap: () {})
/// ```
class BannerEvent extends StatelessWidget {
  const BannerEvent({super.key, this.onTap});

  /// Called when the banner is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_available,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Event Banner',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
