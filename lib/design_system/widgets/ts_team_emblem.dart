import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';

class TsTeamEmblem extends StatelessWidget {
  const TsTeamEmblem(this.logoUrl, {this.size = TsIconSize.sm, super.key});

  final String? logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final placeholder = TsIcon(
      TsIcons.imageNotSupported,
      size: size,
      color: c.textTertiary,
    );

    final url = logoUrl;
    if (url == null || url.isEmpty) {
      return placeholder;
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => placeholder,
          errorWidget: (context, url, error) => placeholder,
        ),
      ),
    );
  }
}
