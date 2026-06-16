import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class GuestBanner extends StatelessWidget {
  const GuestBanner({
    this.onJoinTap,
    super.key,
  });

  final VoidCallback? onJoinTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceBase,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.guestBannerTitle,
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            l10n.guestBannerSubtitle,
            style: TsType.labelSRegular.copyWith(color: semantic.textSecondary),
          ),
          const SizedBox(height: TsSpacing.sm),
          TsButton(
            label: l10n.guestBannerCta,
            variant: TsButtonVariant.primary,
            onPressed: onJoinTap,
          ),
        ],
      ),
    );
  }
}
