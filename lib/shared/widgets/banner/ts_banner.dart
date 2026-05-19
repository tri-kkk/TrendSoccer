import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum TsBannerType { event, subscription, report }

class TsBanner extends StatelessWidget {
  const TsBanner({
    this.type = TsBannerType.event,
    this.child,
    this.onTap,
    super.key,
  });

  final TsBannerType type;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    Widget content({required BoxConstraints? extraConstraints}) {
      return Container(
        width: double.infinity,
        constraints: extraConstraints,
        padding: const EdgeInsets.all(TsSpacing.xl),
        color: semantic.surfaceContainer,
        alignment: Alignment.center,
        child: child ?? _Placeholder(type: type),
      );
    }

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: switch (type) {
        TsBannerType.event => AspectRatio(
            aspectRatio: 1,
            child: content(extraConstraints: null),
          ),
        TsBannerType.subscription => SizedBox(
            width: double.infinity,
            height: 160,
            child: content(extraConstraints: null),
          ),
        TsBannerType.report => content(
            extraConstraints: const BoxConstraints(minHeight: 232),
          ),
      },
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(width: double.infinity, child: clipped),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.type});

  final TsBannerType type;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final (String? iconAsset, IconData? icon, label) = switch (type) {
      TsBannerType.event => (null, Icons.image, 'event'),
      TsBannerType.subscription => (TsAssets.iconPremium, null, 'subscription'),
      TsBannerType.report => (null, Icons.image, 'report'),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (iconAsset != null)
          SvgPicture.asset(
            iconAsset,
            width: 40,
            height: 40,
            colorFilter: ColorFilter.mode(
              semantic.textTertiary,
              BlendMode.srcIn,
            ),
          )
        else
          Icon(icon, size: 40, color: semantic.textTertiary),
        Text(
          label,
          style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
