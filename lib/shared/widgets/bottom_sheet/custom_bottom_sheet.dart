import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';

/// TrendSoccer bottom sheet component.
///
/// A draggable modal sheet with a handle bar and customizable content.
/// Matches the Figma Bottom Sheet component: surfaceOverlay background,
/// top-rounded corners (16px), handle + content layout.
///
/// Use [showCustomBottomSheet] to present this sheet modally:
///
/// ```dart
/// showCustomBottomSheet(
///   context: context,
///   child: Column(
///     children: [
///       Text('Title'),
///       Text('Body text'),
///     ],
///   ),
/// );
/// ```
class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.child,
  });

  /// The content displayed below the handle.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Handle
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.cardPadding),
          // Content
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                bottom: AppSpacing.xxl,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a [CustomBottomSheet] as a modal bottom sheet.
///
/// [child] is the content rendered below the handle.
/// [initialChildSize], [minChildSize], [maxChildSize] control the
/// draggable extent (defaults match a typical half-screen sheet).
///
/// ```dart
/// showCustomBottomSheet(
///   context: context,
///   child: Text('Hello'),
/// );
/// ```
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  double initialChildSize = 0.4,
  double minChildSize = 0.2,
  double maxChildSize = 0.85,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (context, scrollController) {
          return CustomBottomSheet(
            child: SingleChildScrollView(
              controller: scrollController,
              child: child,
            ),
          );
        },
      );
    },
  );
}
