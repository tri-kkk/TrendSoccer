import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '지금 가입하고 48시간 무료 체험',
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            '분석 카드, 프리미엄 픽 등 모든 기능 이용',
            style: TsType.labelSRegular.copyWith(color: semantic.textSecondary),
          ),
          const SizedBox(height: TsSpacing.sm),
          TsButton(
            label: '지금 바로 프리미엄 체험하기 →',
            variant: TsButtonVariant.primary,
            onPressed: onJoinTap,
          ),
        ],
      ),
    );
  }
}
