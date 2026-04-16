import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../buttons/primary_button.dart';

// ── Data model ────────────────────────────────────────────────────────────────

/// A single historical pick record shown in the rolling ticker.
class _PickRecord {
  const _PickRecord({
    required this.homeTeam,
    required this.awayTeam,
    required this.pick,
    required this.isWin,
  });

  final String homeTeam;
  final String awayTeam;

  /// Analyst's pick — `"HOME"`, `"DRAW"`, or `"AWAY"`.
  final String pick;

  /// Whether the pick was correct.
  final bool isWin;
}

/// A premium pick card that highlights the analyst's top pick for the day.
///
/// Displays the featured match with pick and win badges, win-rate statistics,
/// countdown to the next update, a current winning streak, and a CTA button.
///
/// All parameters are optional and ship with sensible dummy defaults so the
/// card renders correctly during development without any data wiring.
///
/// ```dart
/// PremiumPickCard(
///   homeTeam: 'Chelsea',
///   awayTeam: 'Arsenal',
///   pick: 'HOME',
///   isWin: true,
///   winRate: '78%',
///   countdown: '3h 42m',
///   streak: 5,
///   onCheckTap: () => Navigator.pushNamed(context, '/pick'),
/// )
/// ```
class PremiumPickCard extends StatefulWidget {
  const PremiumPickCard({
    super.key,
    this.homeTeam = 'Chelsea',
    this.awayTeam = 'Arsenal',
    this.pick = 'HOME',
    this.isWin = true,
    this.winRate = '78%',
    this.countdown = '3h 42m',
    this.streak = 5,
    this.onCheckTap,
  });

  /// Home team name used as the first rolling ticker entry.
  final String homeTeam;

  /// Away team name used as the first rolling ticker entry.
  final String awayTeam;

  /// The analyst's pick for the first entry — `"HOME"`, `"DRAW"`, or `"AWAY"`.
  final String pick;

  /// Whether the first entry resulted in a win.
  final bool isWin;

  /// Win-rate label shown in the stats row (e.g. `"78%"`).
  final String winRate;

  /// Time until the next pick update (e.g. `"3h 42m"`).
  final String countdown;

  /// Number of consecutive wins in the current streak.
  final int streak;

  /// Called when the user taps the "Check Today's PICK" button.
  final VoidCallback? onCheckTap;

  @override
  State<PremiumPickCard> createState() => _PremiumPickCardState();
}

class _PremiumPickCardState extends State<PremiumPickCard> {
  int _currentIndex = 0;
  Timer? _timer;

  /// Rolling ticker items — first entry is seeded from widget params;
  /// the rest are historical dummy records.
  late final List<_PickRecord> _items = [
    _PickRecord(
      homeTeam: widget.homeTeam,
      awayTeam: widget.awayTeam,
      pick: widget.pick,
      isWin: widget.isWin,
    ),
    const _PickRecord(
      homeTeam: 'Barcelona',
      awayTeam: 'Real Madrid',
      pick: 'AWAY',
      isWin: true,
    ),
    const _PickRecord(
      homeTeam: 'Bayern',
      awayTeam: 'Dortmund',
      pick: 'HOME',
      isWin: false,
    ),
    const _PickRecord(
      homeTeam: 'Liverpool',
      awayTeam: 'Man City',
      pick: 'DRAW',
      isWin: true,
    ),
    const _PickRecord(
      homeTeam: 'PSG',
      awayTeam: 'Marseille',
      pick: 'HOME',
      isWin: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _items.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: AppColors.accent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xl),
          _buildRecentWinsTicker(),
          const SizedBox(height: AppSpacing.xl),
          _buildStats(),
          const SizedBox(height: AppSpacing.xl),
          _buildEarlyAccess(),
          const SizedBox(height: AppSpacing.xl),
          _buildCtaButton(),
          const SizedBox(height: AppSpacing.xl),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  // ── 1. Header ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Text(
      'PREMIUM PICK',
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  // ── 2. Recent Wins Ticker ─────────────────────────────────────────────────

  /// Rolling ticker that cycles through [_items] upward every 3 seconds.
  ///
  /// Uses [AnimatedSwitcher] with a custom [SlideTransition]:
  /// - Incoming item enters from below (`Offset(0, 1)` → `Offset.zero`).
  /// - Outgoing item exits upward (`Offset.zero` → `Offset(0, -1)`).
  Widget _buildRecentWinsTicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isIncoming =
                (child.key as ValueKey<int>?)?.value == _currentIndex;

            // Incoming  animation 0→1 : Offset(0,1)→Offset.zero  (아래→중앙)
            // Outgoing  animation 1→0 : Offset(0,-1)→Offset.zero
            //   → t=1 일 때 Offset.zero(중앙), t=0 일 때 Offset(0,-1)(위)로 탈출
            final position = (isIncoming
                    ? Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      )
                    : Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ))
                .animate(CurvedAnimation(
              parent: animation,
              curve: isIncoming ? Curves.easeOut : Curves.easeIn,
            ));

            return SlideTransition(position: position, child: child);
          },
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: _buildWinsRow(_items[_currentIndex], _currentIndex),
        ),
      ),
    );
  }

  /// Builds a single row for the given [record].
  /// [index] is used as the [ValueKey] so [AnimatedSwitcher] can track
  /// incoming vs outgoing children.
  Widget _buildWinsRow(_PickRecord record, int index) {
    return Row(
      key: ValueKey<int>(index),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          record.homeTeam,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const CircleAvatar(radius: 8, backgroundColor: AppColors.textDisabled),
        const SizedBox(width: AppSpacing.md),
        Text(
          'vs',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const CircleAvatar(radius: 8, backgroundColor: AppColors.textDisabled),
        const SizedBox(width: AppSpacing.md),
        Text(
          record.awayTeam,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildPickBadge(record.pick),
        if (record.isWin) ...[
          const SizedBox(width: AppSpacing.md),
          _buildWinBadge(),
        ],
      ],
    );
  }

  Widget _buildPickBadge(String pick) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        pick,
        style: AppTypography.labelSmallSemiBold.copyWith(
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildWinBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary500.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'WIN',
        style: AppTypography.labelSmallSemiBold.copyWith(
          color: AppColors.accent,
        ),
      ),
    );
  }

  // ── 3. Stats Row ─────────────────────────────────────────────────────────

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildWinRateColumn(),
        _buildDivider(),
        _buildCountdownColumn(),
        _buildDivider(),
        _buildStreakColumn(),
      ],
    );
  }

  Widget _buildWinRateColumn() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.winRate,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Win Rate',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownColumn() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.countdown,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Next Update',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakColumn() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${widget.streak} WIN',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Streak',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.textDisabled,
    );
  }

  // ── 4. Early Access ──────────────────────────────────────────────────────

  Widget _buildEarlyAccess() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        '24h Early Access Active',
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.accent,
        ),
      ),
    );
  }

  // ── 5. CTA Button ────────────────────────────────────────────────────────

  Widget _buildCtaButton() {
    return PrimaryButton(
      label: "Check Today's PICK →",
      onPressed: widget.onCheckTap,
    );
  }

  // ── 6. Disclaimer ────────────────────────────────────────────────────────

  Widget _buildDisclaimer() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        '⚠ For reference only. Not financial advice.',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
