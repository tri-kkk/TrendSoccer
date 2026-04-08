import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/navigation_provider.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../shared/widgets/appbar/custom_appbar.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: 'Menu',
          onBackPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Menu Page - Coming Soon',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(currentTabProvider.notifier)
                    .setTab(getTabFromRoute('/trend'));
                context.go('/trend');
              },
              child: const Text('Go to Trend (via Provider)'),
            ),
          ],
        ),
      ),
    );
  }
}
