import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import 'agree_to_all_row.dart';
import 'terms_row.dart';

class TermsCard extends StatelessWidget {
  final bool agreeToAll;
  final bool termsAccepted;
  final bool privacyAccepted;
  final bool marketingAccepted;
  final VoidCallback onAgreeToAllChanged;
  final VoidCallback onTermsChanged;
  final VoidCallback onPrivacyChanged;
  final VoidCallback onMarketingChanged;
  final VoidCallback? onTermsViewPressed;
  final VoidCallback? onPrivacyViewPressed;

  const TermsCard({
    super.key,
    required this.agreeToAll,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.marketingAccepted,
    required this.onAgreeToAllChanged,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.onMarketingChanged,
    this.onTermsViewPressed,
    this.onPrivacyViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AgreeToAllRow(
            isChecked: agreeToAll,
            onChanged: onAgreeToAllChanged,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            height: 1,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.xl),
          TermsRow(
            title: 'Terms of Service',
            isRequired: true,
            isChecked: termsAccepted,
            onChanged: onTermsChanged,
            onViewPressed: onTermsViewPressed,
          ),
          const SizedBox(height: AppSpacing.xl),
          TermsRow(
            title: 'Privacy Policy',
            isRequired: true,
            isChecked: privacyAccepted,
            onChanged: onPrivacyChanged,
            onViewPressed: onPrivacyViewPressed,
          ),
          const SizedBox(height: AppSpacing.xl),
          TermsRow(
            title: 'Marketing Emails',
            isRequired: false,
            isChecked: marketingAccepted,
            onChanged: onMarketingChanged,
          ),
        ],
      ),
    );
  }
}
