import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_combo_provider.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/cards/today_combo_card.dart';

class BaseballTodayComboCard extends ConsumerWidget {
  const BaseballTodayComboCard({
    this.onCTATap,
    super.key,
  });

  final VoidCallback? onCTATap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(baseballComboStatsProvider);
    final stats = statsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => BaseballComboStatsView.empty,
    );

    void onDefaultCtaTap() {
      final auth = ref.read(authProvider);
      if (auth.hasFullAccess) {
        context.go('/premium?sport=baseball');
      } else {
        navigateToSubscribeIfLoggedIn(context, auth.isLoggedIn);
      }
    }

    return TodayComboCard(
      comboCount: stats.displayComboCount,
      accuracy: stats.displayAccuracy,
      avgOdds: stats.displayAvgOdds,
      subtitle: stats.displaySubtitle(context.l10n),
      statusSummary: stats.resultStatusSummary(context.l10n),
      onCTATap: onCTATap ?? onDefaultCtaTap,
    );
  }
}
