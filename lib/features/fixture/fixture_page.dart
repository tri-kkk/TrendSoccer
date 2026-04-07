import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';

class FixturePage extends StatelessWidget {
  const FixturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('Fixture'),
        backgroundColor: AppColors.surfaceBase,
        foregroundColor: AppColors.textPrimary,
      ),
      body: const Center(
        child: Text(
          'Fixture Page - Coming Soon',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
