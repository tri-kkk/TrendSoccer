import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/premium_pick_stats.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_card.dart';

/// PREMIUM PICK summary backed by [premiumPickStatsProvider].
class PremiumPickStatsCard extends ConsumerWidget {
  const PremiumPickStatsCard({
    this.showCTA = true,
    this.onCTATap,
    this.useTrendLabels = false,
    super.key,
  });

  final bool showCTA;
  final VoidCallback? onCTATap;

  /// Trend: show pick count + update time in stat row labels.
  final bool useTrendLabels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(premiumPickStatsProvider);

    return statsAsync.when(
      loading: () => _buildCard(
        context,
        PremiumPickStatsView.placeholder,
        isLoading: true,
      ),
      error: (error, stackTrace) => _buildCard(
        context,
        PremiumPickStatsView.placeholder,
      ),
      data: (map) => _buildCard(
        context,
        map.isEmpty
            ? PremiumPickStatsView.placeholder
            : PremiumPickStatsView.fromMap(map),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    PremiumPickStatsView stats, {
    bool isLoading = false,
  }) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    final card = PremiumPickCard(
      showCTA: showCTA,
      winRate: useTrendLabels ? stats.pickCount : stats.winRate,
      countdown: stats.countdown,
      streak: stats.streak,
      recentWins: stats.recentWins,
      onCTATap: onCTATap,
      winRateLabel: useTrendLabels ? '오늘의 픽' : null,
      countdownLabel: useTrendLabels ? '업데이트' : null,
      streakLabel: useTrendLabels ? null : null,
    );

    if (!isLoading) return card;

    return Stack(
      children: [
        Opacity(opacity: 0.6, child: card),
        Positioned.fill(
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: semantic.interactivePrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
