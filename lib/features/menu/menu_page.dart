import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: AppColors.surfaceBase,
        foregroundColor: AppColors.textPrimary,
      ),
      body: const Center(
        child: Text(
          'Menu Page - Coming Soon',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
