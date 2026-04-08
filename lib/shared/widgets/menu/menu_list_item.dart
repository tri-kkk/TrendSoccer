import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// A single row in a menu list with an icon, title and trailing chevron.
///
/// ```dart
/// MenuListItem(
///   icon: Icons.notifications_outlined,
///   title: 'Notifications',
///   onTap: () => context.push('/notifications'),
/// )
/// ```
class MenuListItem extends StatelessWidget {
  const MenuListItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  /// Leading icon displayed before the title.
  final IconData icon;

  /// Primary label text.
  final String title;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
