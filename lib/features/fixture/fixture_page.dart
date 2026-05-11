import 'package:flutter/material.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class FixturePage extends StatelessWidget {
  const FixturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: Center(
        child: Text(
          'Fixture',
          style: TsType.headingH1.copyWith(color: semantic.textPrimary),
        ),
      ),
    );
  }
}
