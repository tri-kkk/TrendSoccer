import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/blog_provider.dart';
import 'package:trendsoccer/features_v2/menu/legal_screen.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return LegalScreen(
      title: l10n.menuPrivacyPolicy,
      provider: privacyContentProvider,
    );
  }
}
