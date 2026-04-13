import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// A placeholder banner for the subscription promotion area.
///
/// Uses a 380:160 aspect ratio so it scales with screen width.
/// Wrap with horizontal padding externally.
///
/// ```dart
/// BannerSubscription(onTap: () {})
/// ```
class BannerSubscription extends StatelessWidget {
  const BannerSubscription({super.key, this.onTap});

  /// Called when the banner is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 380 / 160,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.workspace_premium,
                size: 32,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Subscription Banner',
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
