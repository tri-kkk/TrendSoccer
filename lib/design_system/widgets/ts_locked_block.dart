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
    this.size = TsLockSize.inline,
    this.subline,
    this.actionLabel,
    super.key,
  });

  final Widget child;
  final String label;
  final bool locked;
  final VoidCallback? onTap;
  final TsLockSize size;
  final String? subline;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    if (!locked) {
      return child;
    }

    final pill = switch ((subline, actionLabel)) {
      (null, null) => TsLockOverlay(
          size: size,
          headline: label,
        ),
      (null, final String action) => TsLockOverlay(
          size: size,
          headline: label,
          actionLabel: action,
          onAction: onTap,
        ),
      (final String sub, null) => TsLockOverlay(
          size: size,
          headline: label,
          subline: sub,
        ),
      (final String sub, final String action) => TsLockOverlay(
          size: size,
          headline: label,
          subline: sub,
          actionLabel: action,
          onAction: onTap,
        ),
    };

    final Widget overlay;
    if (actionLabel != null && onTap != null) {
      overlay = pill;
    } else if (onTap != null) {
      overlay = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: pill,
      );
    } else {
      overlay = IgnorePointer(child: pill);
    }

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
          child: size == TsLockSize.inline
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
                  child: Center(child: overlay),
                )
              : overlay,
        ),
      ],
    );
  }
}
