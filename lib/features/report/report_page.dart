import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: AppColors.surfaceBase,
        foregroundColor: AppColors.textPrimary,
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
