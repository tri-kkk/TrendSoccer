import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_network_image.dart';

class TsNewsHeroCard extends StatelessWidget {
  const TsNewsHeroCard({
    required this.titleLabel,
    required this.metaLabel,
    this.imageUrl,
    super.key,
  });

  final String titleLabel;
  final String metaLabel;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TsNetworkImage(
          imageUrl: imageUrl,
          aspectRatio: 1,
          placeholderIcon: TsIcons.imageNotSupported,
          borderRadius: TsRadius.md,
        ),
        const SizedBox(height: TsSpacing.md),
        Text(
          titleLabel,
          style: TsType.h3.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: TsSpacing.md),
        Text(
          metaLabel,
          style: TsType.labelSMedium.copyWith(color: c.textTertiary),
        ),
      ],
    );
  }
}
