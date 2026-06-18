import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class BlurableSection extends StatelessWidget {
  const BlurableSection({
    required this.isBlurred,
    required this.child,
    this.blurMessage,
    super.key,
  });

  final bool isBlurred;
  final String? blurMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isBlurred) {
      return child;
    }

    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: child,
        ),
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(TsSpacing.sm),
              child: Text(
                blurMessage ?? '',
                style: TsType.bodyMRegular.copyWith(
                  color: semantic.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
