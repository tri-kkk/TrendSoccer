import 'package:flutter/material.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

/// Stub for Menu > Explore; routing TBD.
class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: Center(
        child: Text(
          'Report',
          style: TsType.headingH1.copyWith(color: semantic.textPrimary),
        ),
      ),
    );
  }
}
