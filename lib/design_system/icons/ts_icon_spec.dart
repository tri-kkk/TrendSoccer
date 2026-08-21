import 'package:flutter/widgets.dart';

sealed class TsIconSpec {
  const TsIconSpec();
}

final class TsGlyph extends TsIconSpec {
  const TsGlyph(this.icon);

  final IconData icon;
}

final class TsAssetIcon extends TsIconSpec {
  const TsAssetIcon(this.path);

  final String path;
}
