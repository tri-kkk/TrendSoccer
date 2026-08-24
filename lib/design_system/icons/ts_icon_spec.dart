import 'package:flutter/widgets.dart';

sealed class TsIconSpec {
  const TsIconSpec();
}

final class TsGlyph extends TsIconSpec {
  const TsGlyph(this.icon, {this.fill = 1});

  final IconData icon;
  final double fill;
}

final class TsAssetIcon extends TsIconSpec {
  const TsAssetIcon(this.path);

  final String path;
}
