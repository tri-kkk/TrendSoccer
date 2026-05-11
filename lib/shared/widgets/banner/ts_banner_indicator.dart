import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class TsBannerIndicator extends StatelessWidget {
  const TsBannerIndicator({required this.isActive, super.key});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? TsColors.brandPrimary500 : semantic.textDisabled,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
