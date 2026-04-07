import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('Analysis'),
        backgroundColor: AppColors.surfaceBase,
        foregroundColor: AppColors.textPrimary,
      ),
      body: const Center(
        child: Text(
          'Analysis Page - Coming Soon',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
