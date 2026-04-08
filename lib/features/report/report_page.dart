import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../shared/widgets/appbar/custom_appbar.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: 'Reports',
          onBackPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text(
          'Report Page - Coming Soon',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
