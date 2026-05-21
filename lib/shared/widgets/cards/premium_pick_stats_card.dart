import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/premium_pick_stats.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_card.dart';

/// PREMIUM PICK summary backed by [premiumPickStatsProvider].
class PremiumPickStatsCard extends ConsumerStatefulWidget {
  const PremiumPickStatsCard({
    this.showCTA = true,
    this.onCTATap,
    super.key,
  });

  final bool showCTA;
  final VoidCallback? onCTATap;

  @override
  ConsumerState<PremiumPickStatsCard> createState() =>
      _PremiumPickStatsCardState();
}

class _PremiumPickStatsCardState extends ConsumerState<PremiumPickStatsCard> {
  Timer? _countdownTimer;
  late String _countdown;

  @override
  void initState() {
    super.initState();
    _countdown = _formatLiveCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickCountdown();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _tickCountdown() {
    if (!mounted) return;
    setState(() => _countdown = _formatLiveCountdown());
  }

  String _formatLiveCountdown() {
    final remaining = nextKstUpdateRemaining();
    if (remaining.isNegative || remaining.inSeconds <= 0) {
      return '업데이트 중...';
    }
    return formatCountdown(remaining);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(premiumPickStatsProvider);
    final teamLogoMap = ref.watch(teamLogoMapProvider);

    return statsAsync.when(
      loading: () => _buildCard(
        context,
        PremiumPickStatsView.placeholder,
        teamLogoMap: teamLogoMap,
        isLoading: true,
      ),
      error: (error, stackTrace) => _buildCard(
        context,
        PremiumPickStatsView.placeholder,
        teamLogoMap: teamLogoMap,
      ),
      data: (map) => _buildCard(
        context,
        map.isEmpty
            ? PremiumPickStatsView.placeholder
            : PremiumPickStatsView.fromMap(map),
        teamLogoMap: teamLogoMap,
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    PremiumPickStatsView stats, {
    required Map<String, String> teamLogoMap,
    bool isLoading = false,
  }) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    final card = PremiumPickCard(
      showCTA: widget.showCTA,
      winRate: stats.winRate,
      countdown: _countdown,
      streak: stats.streak,
      recentWins: stats.recentWins,
      teamLogoMap: teamLogoMap,
      onCTATap: widget.onCTATap,
      streakLabel: '현재 연승',
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
