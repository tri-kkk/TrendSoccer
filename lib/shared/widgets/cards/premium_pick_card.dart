import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/icons/sports_icon.dart';

String _pickDirectionLabel(BuildContext context, String code) {
  final l10n = context.l10n;
  return switch (code) {
    'home' => l10n.pickDirectionHome,
    'draw' => l10n.pickDirectionDraw,
    'away' => l10n.pickDirectionAway,
    _ => code,
  };
}

class RecentWinData {
  const RecentWinData({
    required this.homeTeam,
    required this.awayTeam,
    required this.pickDirection,
  });

  final String homeTeam;
  final String awayTeam;

  /// `home`, `draw`, `away`, or display fallback.
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
    this.countdownValue,
    this.teamLogoMap = const {},
    this.onCTATap,
    this.winRateLabel,
    this.countdownLabel,
    this.streakLabel,
  });

  final bool showCTA;
  final String winRate;
  final String countdown;
  final Widget? countdownValue;
  final String streak;
  final List<RecentWinData> recentWins;
  final Map<String, String> teamLogoMap;
  final VoidCallback? onCTATap;
  final String? winRateLabel;
  final String? countdownLabel;
  final String? streakLabel;

  static final Color winBadgeBackground =
      TsColors.systemSuccess500.withValues(alpha: 0.2);

  @override
  State<PremiumPickCard> createState() => _PremiumPickCardState();
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

  Widget _teamLogoPlaceholder(TsSemanticColors semantic) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: semantic.surfaceOverlay,
        border: Border.all(
          color: semantic.borderSubtle,
          width: 1,
        ),
      ),
    );
  }

  Widget _teamLogo(TsSemanticColors semantic, String teamName) {
    final url = findTeamLogo(widget.teamLogoMap, teamName);
    if (url == null || url.isEmpty) {
      return _teamLogoPlaceholder(semantic);
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 16,
        height: 16,
        fit: BoxFit.cover,
        placeholder: (context, _) => _teamLogoPlaceholder(semantic),
        errorWidget: (context, _, _) => _teamLogoPlaceholder(semantic),
      ),
    );
  }

  Widget _buildWinRow(RecentWinData data, {required Key key}) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return SizedBox(
      key: key,
      height: 32,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      data.homeTeam,
                      style: TsType.labelSRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: TsSpacing.xs),
                _teamLogo(semantic, data.homeTeam),
                const SizedBox(width: TsSpacing.xs),
                Text(
                  'VS',
                  style: TsType.labelSRegular.copyWith(
                    color: semantic.textTertiary,
                  ),
                ),
                const SizedBox(width: TsSpacing.xs),
                _teamLogo(semantic, data.awayTeam),
                const SizedBox(width: TsSpacing.xs),
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.awayTeam,
                      style: TsType.labelSRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: TsSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TsSpacing.sm,
                  vertical: TsSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: semantic.surfaceOverlay,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _pickDirectionLabel(context, data.pickDirection),
                  style: TsType.labelSBold.copyWith(
                    color: semantic.interactivePrimary,
                  ),
                ),
              ),
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
    final l10n = context.l10n;
    final wins = widget.recentWins;
    if (wins.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceBase,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  semantic.textPrimary,
                  BlendMode.srcIn,
                ),
                child: const TsSportsIcon(
                  sport: SportType.soccer,
                  fill: SportsIconFill.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Text(
                l10n.cardTodayPick,
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
                  label: widget.winRateLabel ?? l10n.cardHitRate,
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
                  valueWidget: widget.countdownValue,
                  label: widget.countdownLabel ?? l10n.cardNextUpdate,
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
                  label: widget.streakLabel ?? l10n.cardStreak,
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
              label: l10n.cardCheckPick,
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
    required this.label,
    required this.valueColor,
    required this.semantic,
    this.value,
    this.valueWidget,
  }) : assert(value != null || valueWidget != null);

  final String? value;
  final Widget? valueWidget;
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
        valueWidget ??
            Text(
              value!,
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
