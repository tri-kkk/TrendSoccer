import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';

class PreviewDetailScreen extends StatelessWidget {
  const PreviewDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: 'Preview',
        onBack: () => context.pop(),
      ),
      body: Center(
        child: Text(
          'PreviewDetailScreen\nslug=$slug',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
