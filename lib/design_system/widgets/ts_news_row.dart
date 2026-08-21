import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsNewsRow extends StatelessWidget {
  const TsNewsRow({
    required this.title,
    required this.source,
    required this.timeLabel,
    this.thumbnail,
    this.showThumbnail = true,
    this.onTap,
    super.key,
  });

  final String title;
  final String source;
  final String timeLabel;
  final Widget? thumbnail;
  final bool showThumbnail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: TsSpacing.md,
          horizontal: TsSpacing.lg,
        ),
        color: c.surface,
        child: Row(
          children: [
            if (showThumbnail) ...[
              ClipRRect(
                borderRadius: TsRadius.sm,
                child: Container(
                  width: 80,
                  height: 45,
                  color: c.surfaceRaised,
                  alignment: Alignment.center,
                  child: thumbnail ??
                      TsIcon(
                        TsIcons.imageNotSupported,
                        size: TsSpacing.xl,
                        color: c.textTertiary,
                      ),
                ),
              ),
              const SizedBox(width: TsSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TsType.bodyMMedium.copyWith(color: c.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: TsSpacing.xs),
                  Row(
                    children: [
                      Text(
                        source,
                        style: TsType.labelXsMedium.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.xs),
                      Text(
                        timeLabel,
                        style: TsType.labelXsRegular.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                    ],
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
