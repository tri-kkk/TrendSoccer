import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_lock_overlay.dart';

/// Blurs [child] and centers a lock pill when [locked] is true.
///
/// When [locked] is false, returns [child] with no additional wrappers so
/// layout size is unchanged between locked and unlocked states.
class TsLockedBlock extends StatelessWidget {
  const TsLockedBlock({
    required this.child,
    required this.label,
    this.locked = true,
    this.onTap,
    super.key,
  });

  final Widget child;
  final String label;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!locked) {
      return child;
    }

    final pill = TsLockOverlay(
      size: TsLockSize.inline,
      headline: label,
    );

    final overlay = onTap != null
        ? GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: pill,
          )
        : IgnorePointer(child: pill);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: child,
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            child: Center(child: overlay),
          ),
        ),
      ],
    );
  }
}
