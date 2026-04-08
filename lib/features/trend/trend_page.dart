import 'package:flutter/material.dart';

import '../../core/theme/tokens/color_tokens.dart';

class TrendPage extends StatelessWidget {
  const TrendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: const SafeArea(
        child: Center(
          child: Text(
            'Trend Page - Coming Soon',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
