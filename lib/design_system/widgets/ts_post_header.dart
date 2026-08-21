import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_logo.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_network_image.dart';

class TsPostHeader extends StatelessWidget {
  const TsPostHeader({
    required this.authorLabel,
    required this.roleLabel,
    required this.leagueLogo,
    required this.dateLabel,
    required this.titleLabel,
    this.imageUrl,
    super.key,
  });

  final String authorLabel;
  final String roleLabel;
  final Widget leagueLogo;
  final String dateLabel;
  final String titleLabel;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TsNetworkImage(
          imageUrl: imageUrl,
          aspectRatio: 16 / 9,
          placeholderIcon: TsIcons.imageNotSupported,
          borderRadius: TsRadius.md,
        ),
        const SizedBox(height: TsSpacing.lg),
        Row(
          children: [
            const TsLogo(TsLogoType.editor, height: 40),
            const SizedBox(width: TsSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorLabel,
                    style: TsType.bodyLMedium.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: TsSpacing.xs),
                  Text(
                    roleLabel,
                    style: TsType.labelSRegular.copyWith(color: c.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leagueLogo,
            Text(
              dateLabel,
              style: TsType.labelSRegular.copyWith(color: c.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.lg),
        Text(
          titleLabel,
          style: TsType.h1.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}
