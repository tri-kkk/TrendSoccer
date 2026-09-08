import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';

class TsNetworkImage extends StatelessWidget {
  const TsNetworkImage({
    required this.imageUrl,
    required this.aspectRatio,
    required this.placeholderIcon,
    this.borderRadius,
    this.overlay,
    super.key,
  });

  final String? imageUrl;
  final double aspectRatio;
  final TsIconSpec placeholderIcon;
  final BorderRadius? borderRadius;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;

    Widget errorPanel() => Center(
          child: TsIcon(
            placeholderIcon,
            size: TsIconSize.lg,
            color: c.textTertiary,
          ),
        );

    Widget slotContent;
    if (!hasUrl) {
      slotContent = errorPanel();
    } else {
      slotContent = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, _) => const SizedBox.expand(),
        errorWidget: (_, _, _) => errorPanel(),
      );
    }

    if (overlay != null) {
      slotContent = Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: slotContent),
          overlay!,
        ],
      );
    }

    final frame = AspectRatio(
      aspectRatio: aspectRatio,
      child: ColoredBox(
        color: c.surfaceRaised,
        child: slotContent,
      ),
    );

    if (borderRadius == null) return frame;
    return ClipRRect(
      borderRadius: borderRadius!,
      clipBehavior: Clip.antiAlias,
      child: frame,
    );
  }
}
