import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class TrialBanner extends StatelessWidget {
  const TrialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: TsColors.brandPrimary500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: semantic.interactivePrimary, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '48-hour Premium Trial',
            style: TsType.bodyLBold.copyWith(color: semantic.interactivePrimary),
          ),
          const SizedBox(height: TsSpacing.xs),
          Text(
            l10n.signupTrialBannerSubtitle,
            style: TsType.labelSRegular.copyWith(color: semantic.textSecondary),
          ),
        ],
      ),
    );
  }
}
