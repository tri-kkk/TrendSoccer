import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

enum PlanType { free, trial, premium }

class PlanTicket extends StatelessWidget {
  const PlanTicket({
    required this.type,
    required this.subtitle,
    this.onButtonTap,
    this.buttonLabel,
    super.key,
  });

  final PlanType type;
  final String subtitle;
  final VoidCallback? onButtonTap;
  final String? buttonLabel;

  String get _title {
    return switch (type) {
      PlanType.free => '무료 플랜',
      PlanType.trial => '무료 체험 플랜',
      PlanType.premium => '프리미엄 플랜',
    };
  }

  static String _defaultLabel(PlanType type) {
    return switch (type) {
      PlanType.free => '구독 시작하기',
      PlanType.trial => '구독 업그레이드',
      PlanType.premium => '구독 연장하기',
    };
  }

  String get _imageAsset {
    return switch (type) {
      PlanType.free => TsAssets.planFree,
      PlanType.trial => TsAssets.planTrial,
      PlanType.premium => TsAssets.planPremium,
    };
  }

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            _imageAsset,
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: TsSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title,
                  style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                ),
                const SizedBox(height: TsSpacing.sm),
                Text(
                  subtitle,
                  style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                ),
                const SizedBox(height: TsSpacing.sm),
                TsButton(
                  label: buttonLabel ?? _defaultLabel(type),
                  variant: TsButtonVariant.primary,
                  size: TsButtonSize.small,
                  onPressed: onButtonTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
