import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

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
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: semantic.surfaceBase.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              blurMessage ?? '',
              style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
