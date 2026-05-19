import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum TsCheckBoxState { checked, unchecked, partial }

class TsCheckBox extends StatelessWidget {
  const TsCheckBox({
    required this.state,
    this.onChanged,
    super.key,
  });

  final TsCheckBoxState state;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final asset = switch (state) {
      TsCheckBoxState.checked => TsAssets.iconCheckboxChecked,
      TsCheckBoxState.unchecked => TsAssets.iconCheckboxUnchecked,
      TsCheckBoxState.partial => TsAssets.iconCheckboxPartial,
    };
    final color = switch (state) {
      TsCheckBoxState.checked => semantic.interactivePrimary,
      TsCheckBoxState.unchecked => semantic.borderDefault,
      TsCheckBoxState.partial => semantic.interactivePrimary,
    };

    return GestureDetector(
      onTap: onChanged,
      child: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
