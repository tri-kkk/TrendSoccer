import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.name,
    required this.email,
    super.key,
  });

  final String name;
  final String email;

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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: semantic.surfaceContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              TsAssets.iconAccountCircle,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                semantic.interactivePrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: TsSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                ),
                const SizedBox(height: TsSpacing.xs),
                Text(
                  email,
                  style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
