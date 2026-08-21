import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';

enum TsSocialPlatform { google, naver }

class TsSocialSymbol extends StatelessWidget {
  const TsSocialSymbol(this.platform, {this.size = 24, super.key});

  final TsSocialPlatform platform;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = switch (platform) {
      TsSocialPlatform.google => TsAssets.socialGoogle,
      TsSocialPlatform.naver => TsAssets.socialNaver,
    };
    return SvgPicture.asset(path, width: size, height: size);
  }
}
