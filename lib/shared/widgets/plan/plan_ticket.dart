import 'package:flutter/material.dart';

import '../../../core/models/subscription_state.dart';
import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../badge/custom_badge.dart';

/// A ticket-style card that shows the user's current subscription plan.
///
/// Renders differently for each [SubscriptionType]:
/// - **free** — badge, plan name, and a subscribe button.
/// - **trial** — badge, plan name, remaining time, and an upgrade button.
/// - **premium** — badge, plan name, and expiry date.
///
/// ```dart
/// PlanTicket(
///   type: SubscriptionType.trial,
///   remainingTime: Duration(hours: 36, minutes: 12),
///   onSubscribePressed: () => showPaywall(),
/// )
/// ```
class PlanTicket extends StatelessWidget {
  const PlanTicket({
    super.key,
    required this.type,
    this.expiryDate,
    this.remainingTime,
    this.onSubscribePressed,
  });

  /// Current subscription tier.
  final SubscriptionType type;

  /// Premium expiry date. Displayed when [type] is [SubscriptionType.premium].
  final DateTime? expiryDate;

  /// Trial remaining duration. Displayed when [type] is [SubscriptionType.trial].
  final Duration? remainingTime;

  /// Called when the subscribe / upgrade button is tapped.
  final VoidCallback? onSubscribePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: switch (type) {
        SubscriptionType.free => _buildFree(),
        SubscriptionType.trial => _buildTrial(),
        SubscriptionType.premium => _buildPremium(),
      },
    );
  }

  Widget _buildFree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CustomBadge(type: BadgeType.free, label: 'Free'),
            const Spacer(),
            _actionButton('Subscribe'),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Free Plan',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrial() {
    final hours = remainingTime?.inHours ?? 0;
    final minutes = (remainingTime?.inMinutes ?? 0) % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CustomBadge(type: BadgeType.trial, label: 'Trial'),
            const Spacer(),
            _actionButton('Upgrade'),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Free Trial',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${hours}h ${minutes}m remaining',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPremium() {
    final dateStr = expiryDate != null
        ? '${expiryDate!.year}-${_pad(expiryDate!.month)}-${_pad(expiryDate!.day)}'
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomBadge(type: BadgeType.premium, label: 'Premium'),
        const SizedBox(height: 12),
        Text(
          'Premium Plan',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Expires: $dateStr',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String text) {
    return SizedBox(
      width: 160,
      height: 32,
      child: ElevatedButton(
        onPressed: onSubscribePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: AppColors.surfaceBase,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(text),
      ),
    );
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
