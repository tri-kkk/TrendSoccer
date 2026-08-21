import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_lock_overlay.dart';
import 'package:trendsoccer/design_system/widgets/ts_network_image.dart';

class TsPreviewCard extends StatelessWidget {
  const TsPreviewCard({
    required this.leagueIcon,
    required this.leagueLabel,
    required this.dateLabel,
    required this.titleLabel,
    required this.excerptLabel,
    this.imageUrl,
    this.locked = false,
    this.lockHeadline = 'Premium content',
    this.lockSubline = 'Subscribe to view full analysis',
    super.key,
  });

  final Widget leagueIcon;
  final String leagueLabel;
  final String dateLabel;
  final String titleLabel;
  final String excerptLabel;
  final String? imageUrl;
  final bool locked;
  final String lockHeadline;
  final String lockSubline;

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
                          leagueLabel,
                          style: TsType.labelXsMedium.copyWith(
                            color: c.textTertiary,
                          ),
                        ),
                      ),
                      Text(
                        dateLabel,
                        style: TsType.labelXsMedium.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  Text(
                    titleLabel,
                    style: TsType.h3.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  Text(
                    excerptLabel,
                    style: TsType.bodyMRegular.copyWith(color: c.textSecondary),
                  ),
                  if (locked) ...[
                    const SizedBox(height: TsSpacing.sm),
                    TsLockOverlay(
                      headline: lockHeadline,
                      subline: lockSubline,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
