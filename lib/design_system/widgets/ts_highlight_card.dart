import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_network_image.dart';

class TsHighlightCard extends StatelessWidget {
  const TsHighlightCard({
    required this.leagueIcon,
    required this.metaLabel,
    required this.titleLabel,
    this.imageUrl,
    super.key,
  });

  final Widget leagueIcon;
  final String metaLabel;
  final String titleLabel;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return ClipRRect(
      borderRadius: TsRadius.md,
      clipBehavior: Clip.antiAlias,
      child: ColoredBox(
        color: c.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TsNetworkImage(
              imageUrl: imageUrl,
              aspectRatio: 16 / 9,
              placeholderIcon: TsIcons.imageNotSupported,
              overlay: Container(
                width: TsIconSize.xl,
                height: TsIconSize.xl,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.scrim,
                ),
                alignment: Alignment.center,
                child: TsIcon(
                  TsIcons.playCircle,
                  size: TsIconSize.lg,
                  color: c.onScrim,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TsSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      leagueIcon,
                      const SizedBox(width: TsSpacing.xs),
                      Expanded(
                        child: Text(
                          metaLabel,
                          style: TsType.labelXsMedium.copyWith(
                            color: c.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  Text(
                    titleLabel,
                    style: TsType.bodyLBold.copyWith(color: c.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
