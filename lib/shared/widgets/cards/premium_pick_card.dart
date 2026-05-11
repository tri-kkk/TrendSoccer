import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/pick_direction_badge.dart';
import 'package:trendsoccer/shared/widgets/icons/sports_icon.dart';

class RecentWinData {
  const RecentWinData({
    required this.homeTeam,
    required this.awayTeam,
    required this.pickDirection,
  });

  final String homeTeam;
  final String awayTeam;

  /// "홈" or "원정" (표시 라벨과 픽 배지 매핑)
  final String pickDirection;
}

class PremiumPickCard extends StatefulWidget {
  const PremiumPickCard({
    super.key,
    this.showCTA = true,
    required this.winRate,
    required this.countdown,
    required this.streak,
    required this.recentWins,
    this.onCTATap,
  });

  final bool showCTA;
  final String winRate;
  final String countdown;
  final String streak;
  final List<RecentWinData> recentWins;
  final VoidCallback? onCTATap;

  static const Color winBadgeBackground = Color(0x3310B981);

  @override
  State<PremiumPickCard> createState() => _PremiumPickCardState();
}

PickDirection pickDirectionFromWinLabel(String label) {
  if (label == '홈') return PickDirection.home;
  if (label == '무' || label == '무승부') return PickDirection.draw;
  return PickDirection.away;
}

class _PremiumPickCardState extends State<PremiumPickCard>
    with TickerProviderStateMixin {
  Timer? _rotateTimer;
  late AnimationController _slideController;
  late Animation<Offset> _enterAnimation;
  late Animation<Offset> _exitAnimation;
  int _currentIndex = 0;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..value = 1.0;

    final curve =
        CurvedAnimation(parent: _slideController, curve: Curves.easeInOut);
    _enterAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(curve);
    _exitAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(curve);

    _restartRotationTimerIfNeeded();
  }

  void _restartRotationTimerIfNeeded() {
    _rotateTimer?.cancel();
    _rotateTimer = null;
    if (widget.recentWins.length <= 1) return;
    _rotateTimer = Timer.periodic(const Duration(seconds: 3), (_) => _advanceWin());
  }

  void _advanceWin() {
    if (!mounted || widget.recentWins.length <= 1) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = (_currentIndex + 1) % widget.recentWins.length;
    });
    _slideController.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant PremiumPickCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recentWins.length != widget.recentWins.length) {
      _currentIndex = 0;
      _previousIndex = 0;
      _slideController.value = 1.0;
      _restartRotationTimerIfNeeded();
    }
  }

  @override
  void dispose() {
    _rotateTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  Widget _logoDot(TsSemanticColors semantic) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: semantic.surfaceContainer,
      ),
    );
  }

  Widget _buildWinRow(RecentWinData data, {required Key key}) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final pick = pickDirectionFromWinLabel(data.pickDirection);
    return SizedBox(
      key: key,
      height: 32,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.homeTeam,
              style: TsType.labelSRegular.copyWith(
                color: semantic.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: TsSpacing.xs),
          _logoDot(semantic),
          const SizedBox(width: TsSpacing.xs),
          Text(
            'VS',
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
          ),
          const SizedBox(width: TsSpacing.xs),
          _logoDot(semantic),
          const SizedBox(width: TsSpacing.xs),
          Expanded(
            child: Text(
              data.awayTeam,
              style: TsType.labelSRegular.copyWith(
                color: semantic.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: TsSpacing.sm),
          PickDirectionBadge(pick: pick),
          const SizedBox(width: TsSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TsSpacing.sm,
              vertical: TsSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: PremiumPickCard.winBadgeBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'WIN',
              style: TsType.labelSBold.copyWith(
                color: TsColors.systemSuccess500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRollingWins() {
    final wins = widget.recentWins;
    if (wins.isEmpty) {
      return const SizedBox.shrink();
    }
    final current = wins[_currentIndex.clamp(0, wins.length - 1)];
    final previous = wins[_previousIndex.clamp(0, wins.length - 1)];

    return ClipRect(
      child: SizedBox(
        height: 32,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          children: [
            if (_slideController.isAnimating)
              SlideTransition(
                position: _exitAnimation,
                child: _buildWinRow(
                  previous,
                  key: ValueKey<String>(
                    'exit-$_previousIndex-${previous.homeTeam}',
                  ),
                ),
              ),
            SlideTransition(
              position: _enterAnimation,
              child: _buildWinRow(
                current,
                key: ValueKey<String>(
                  'in-$_currentIndex-${current.homeTeam}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final wins = widget.recentWins;
    if (wins.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: semantic.interactivePrimary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TsSportsIcon(
                sport: SportType.soccer,
                fill: SportsIconFill.primary,
                size: 24,
              ),
              const SizedBox(width: TsSpacing.sm),
              Text(
                '오늘의 추천 경기',
                style: TsType.headingH3.copyWith(color: semantic.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Container(
            padding: const EdgeInsets.all(TsSpacing.sm),
            decoration: BoxDecoration(
              color: semantic.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildRollingWins(),
          ),
          const SizedBox(height: TsSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: widget.winRate,
                  label: '적중률',
                  valueColor: semantic.interactivePrimary,
                  semantic: semantic,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Container(
                width: 1,
                height: 40,
                color: semantic.textDisabled,
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: _StatCell(
                  value: widget.countdown,
                  label: '다음 업데이트',
                  valueColor: semantic.textPrimary,
                  semantic: semantic,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Container(
                width: 1,
                height: 40,
                color: semantic.textDisabled,
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: _StatCell(
                  value: widget.streak,
                  label: '연속 적중',
                  valueColor: semantic.interactivePrimary,
                  semantic: semantic,
                ),
              ),
            ],
          ),
          if (widget.showCTA) ...[
            const SizedBox(height: TsSpacing.lg),
            Container(
              height: 1,
              color: semantic.borderSubtle,
            ),
            const SizedBox(height: TsSpacing.lg),
            TsButton(
              label: '오늘의 픽 확인하기 →',
              variant: TsButtonVariant.primary,
              onPressed: widget.onCTATap,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.semantic,
  });

  final String value;
  final String label;
  final Color valueColor;
  final TsSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TsType.headingH1.copyWith(color: valueColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.xs),
        Text(
          label,
          style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
