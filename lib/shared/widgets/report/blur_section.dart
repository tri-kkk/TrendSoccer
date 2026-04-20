import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

class BlurableSection extends StatelessWidget {
  const BlurableSection({
    super.key,
    required this.child,
    required this.isBlurred,
    this.blurText = 'Opens in --h --m',
  });

  final Widget child;
  final bool isBlurred;
  final String blurText;

  @override
  Widget build(BuildContext context) {
    if (!isBlurred) return child;

    return Stack(
      children: [
        IgnorePointer(child: child),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: AppColors.surfaceBase.withValues(alpha: 0.75),
                alignment: Alignment.center,
                child: Text(
                  blurText,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
