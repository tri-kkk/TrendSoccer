import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/auth/agree_to_all_row.dart';
import 'package:trendsoccer/shared/widgets/auth/terms_row.dart';

class TermsCard extends StatelessWidget {
  const TermsCard({
    required this.termsChecked,
    required this.privacyChecked,
    required this.marketingChecked,
    this.onTermsChanged,
    this.onPrivacyChanged,
    this.onMarketingChanged,
    this.onAgreeAllChanged,
    this.onTermsView,
    this.onPrivacyView,
    super.key,
  });

  final bool termsChecked;
  final bool privacyChecked;
  final bool marketingChecked;
  final VoidCallback? onTermsChanged;
  final VoidCallback? onPrivacyChanged;
  final VoidCallback? onMarketingChanged;
  final VoidCallback? onAgreeAllChanged;
  final VoidCallback? onTermsView;
  final VoidCallback? onPrivacyView;

  bool get _allChecked => termsChecked && privacyChecked && marketingChecked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AgreeToAllRow(isChecked: _allChecked, onChanged: onAgreeAllChanged),
        const SizedBox(height: TsSpacing.lg),
        Container(height: 1, color: semantic.borderSubtle),
        const SizedBox(height: TsSpacing.lg),
        TermsRow(
          title: l10n.signupTermsAgree,
          isRequired: true,
          isChecked: termsChecked,
          onChanged: onTermsChanged,
          onViewTap: onTermsView,
        ),
        const SizedBox(height: TsSpacing.md),
        TermsRow(
          title: l10n.signupPrivacyAgree,
          isRequired: true,
          isChecked: privacyChecked,
          onChanged: onPrivacyChanged,
          onViewTap: onPrivacyView,
        ),
        const SizedBox(height: TsSpacing.md),
        TermsRow(
          title: l10n.signupMarketingAgree,
          isRequired: false,
          isChecked: marketingChecked,
          onChanged: onMarketingChanged,
        ),
      ],
    );
  }
}
