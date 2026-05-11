import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class PositionChip extends StatelessWidget {
  const PositionChip({required this.isHome, super.key});

  final bool isHome;

  static const Color _homeBg = Color(0x3300DF81);
  static const Color _awayBg = Color(0x33EF4444);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isHome ? _homeBg : _awayBg,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        isHome ? '홈' : '원정',
        style: TsType.labelSRegular.copyWith(
          color: isHome ? semantic.interactivePrimary : TsColors.systemError500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
