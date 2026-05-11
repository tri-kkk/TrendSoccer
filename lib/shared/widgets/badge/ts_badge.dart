import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum TsBadgeType { pick, good, pass, premium, trial, free }

class TsBadge extends StatelessWidget {
  const TsBadge({required this.type, super.key});

  final TsBadgeType type;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final backgroundColor = _backgroundForType(type);
    final label = _labelForType(type);
    final textColor =
        type == TsBadgeType.premium ? semantic.surfaceBase : semantic.textPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TsType.bodyMBold.copyWith(color: textColor),
        ),
      ),
    );
  }

  static Color _backgroundForType(TsBadgeType type) {
    return switch (type) {
      TsBadgeType.pick => TsColors.analysisPick500,
      TsBadgeType.good => TsColors.analysisGood500,
      TsBadgeType.pass => TsColors.analysisPass500,
      TsBadgeType.premium => TsColors.membershipPremium500,
      TsBadgeType.trial => TsColors.membershipTrial500,
      TsBadgeType.free => TsColors.membershipFree500,
    };
  }

  static String _labelForType(TsBadgeType type) {
    return switch (type) {
      TsBadgeType.pick => 'PICK',
      TsBadgeType.good => 'GOOD',
      TsBadgeType.pass => 'PASS',
      TsBadgeType.premium => 'PREMIUM',
      TsBadgeType.trial => 'Trial',
      TsBadgeType.free => 'Free',
    };
  }
}
