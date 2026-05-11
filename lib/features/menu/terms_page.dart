import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: const TsAppBar(
        location: TsAppBarLocation.backTitle,
        title: '이용약관',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: Text(
          '이용약관\n\n버전 1.0 (2026.05.01)\n\n(내용은 추후 법률 검토 후 추가됩니다.)',
          style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
        ),
      ),
    );
  }
}
