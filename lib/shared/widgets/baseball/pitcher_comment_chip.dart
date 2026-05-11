import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class PitcherCommentChip extends StatelessWidget {
  const PitcherCommentChip({
    required this.text,
    required this.isStrength,
    super.key,
  });

  final String text;
  final bool isStrength;

  static const Color _strengthBg = Color(0x3300DF81);
  static const Color _weaknessBg = Color(0x33EF4444);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minWidth: 80),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isStrength ? _strengthBg : _weaknessBg,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TsType.labelSRegular.copyWith(
          color: isStrength ? semantic.interactivePrimary : TsColors.systemError500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
