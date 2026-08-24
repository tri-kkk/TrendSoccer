import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/blog_provider.dart';
import 'package:trendsoccer/features_v2/menu/legal_screen.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LegalScreen(
      title: 'Terms of service',
      provider: termsContentProvider,
    );
  }
}
