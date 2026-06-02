import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/premium_pick_stats.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
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
  Timer? _blinkTimer;
  bool _colonVisible = true;
  late String _countdown;
  var _countdownInitialized = false;

  @override
  void initState() {
    super.initState();
    _countdown = '';
    _countdownTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _tickCountdown();
    });
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          _colonVisible = !_colonVisible;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_countdownInitialized) {
      _countdownInitialized = true;
      _countdown = _formatLiveCountdown(context);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _tickCountdown() {
    if (!mounted) return;
    setState(() => _countdown = _formatLiveCountdown(context));
  }

  String _formatLiveCountdown(BuildContext context) {
    final remaining = nextKstUpdateRemaining();
    if (remaining.isNegative || remaining.inSeconds <= 0) {
      return context.l10n.cardUpdating;
    }
    return formatCountdown(remaining);
  }

  bool _isHhMmCountdown(String value) {
    final parts = value.split(':');
    return parts.length == 2 &&
        parts[0].length == 2 &&
        parts[1].length == 2 &&
        int.tryParse(parts[0]) != null &&
        int.tryParse(parts[1]) != null;
  }

  Widget _buildCountdownValue(TsSemanticColors semantic) {
    final countdownStyle = TsType.headingH1.copyWith(
      color: semantic.textPrimary,
    );

    if (!_isHhMmCountdown(_countdown)) {
      return Text(
        _countdown,
        style: countdownStyle,
        textAlign: TextAlign.center,
      );
    }

    final parts = _countdown.split(':');
    final hours = parts[0];
    final minutes = parts[1];

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: hours),
          TextSpan(
            text: ':',
            style: countdownStyle.copyWith(
              color: _colonVisible
                  ? countdownStyle.color
                  : Colors.transparent,
            ),
          ),
          TextSpan(text: minutes),
        ],
        style: countdownStyle,
      ),
      textAlign: TextAlign.center,
    );
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
      countdownValue: _buildCountdownValue(semantic),
      streak: stats.streak,
      recentWins: stats.recentWins,
      teamLogoMap: teamLogoMap,
      onCTATap: widget.onCTATap,
      streakLabel: context.l10n.cardStreak,
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
