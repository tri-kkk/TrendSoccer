import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../buttons/primary_button.dart';

/// Visual variant for [EmptyState].
enum EmptyStateType {
  /// Icon, title, and optional description only.
  defaultType,

  /// Adds a primary action button below the description.
  withAction,
}

/// A centered placeholder shown when a list or section has no content.
///
/// Two variants controlled by [type]:
/// - [EmptyStateType.defaultType]: icon + title + optional description.
/// - [EmptyStateType.withAction]: same as default, plus a [PrimaryButton].
///
/// Layout follows Figma node `636:29`.
///
/// ```dart
/// EmptyState(
///   icon: Icons.sports_soccer,
///   title: 'No matches available',
///   description: 'Check back later for analysis',
/// )
///
/// EmptyState(
///   icon: Icons.calendar_today,
///   title: 'No matches today',
///   description: 'Select a different date to view matches',
///   type: EmptyStateType.withAction,
///   actionText: 'View Other Dates',
///   onActionTap: () {},
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.type = EmptyStateType.defaultType,
    this.actionText,
    this.onActionTap,
  });

  /// Centred icon displayed at the top.
  final IconData icon;

  /// Primary message shown below the icon.
  final String title;

  /// Optional supporting text below the title.
  final String? description;

  /// Controls whether an action button is rendered.
  final EmptyStateType type;

  /// Label for the action button (required when [type] is
  /// [EmptyStateType.withAction]).
  final String? actionText;

  /// Called when the action button is pressed.
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (type == EmptyStateType.withAction &&
                actionText != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: actionText!,
                size: ButtonSize.small,
                onPressed: onActionTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
