import 'package:flutter/material.dart';

import '../../../../core/models/baseball_match_report.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../shared/widgets/baseball/comment_chip.dart';
import '../../../../shared/widgets/baseball/position_chip.dart';
import '../../../../shared/widgets/baseball/season_chip.dart';

/// Side-by-side starting pitcher cards (away / home).
class StartingPitchersSection extends StatelessWidget {
  const StartingPitchersSection({
    super.key,
    required this.leagueId,
    required this.awayPitcher,
    required this.homePitcher,
  });

  /// Drives MLB vs non-MLB stats and pitcher image rules (`KBO`, `MLB`, etc.).
  final String leagueId;

  final PitcherData awayPitcher;
  final PitcherData homePitcher;

  static bool isMlbLeague(String leagueId) =>
      leagueId.trim().toUpperCase() == 'MLB';

  @override
  Widget build(BuildContext context) {
    final isMlb = isMlbLeague(leagueId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Starting Pitchers',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _PitcherColumn(
                    pitcher: awayPitcher,
                    positionLabel: 'Away',
                    isMlb: isMlb,
                  ),
                ),
                Container(
                  width: 1,
                  color: AppColors.surfaceContainer,
                ),
                Expanded(
                  child: _PitcherColumn(
                    pitcher: homePitcher,
                    positionLabel: 'Home',
                    isMlb: isMlb,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PitcherColumn extends StatelessWidget {
  const _PitcherColumn({
    required this.pitcher,
    required this.positionLabel,
    required this.isMlb,
  });

  final PitcherData pitcher;
  final String positionLabel;
  final bool isMlb;

  static final TextStyle _nameStyle = AppTypography.titleSmall.copyWith(
    color: AppColors.textPrimary,
  );

  static final TextStyle _handednessStyle = AppTypography.labelSmall.copyWith(
    color: AppColors.textTertiary,
  );

  static final TextStyle _statLabelStyle = AppTypography.labelSmall.copyWith(
    color: AppColors.textTertiary,
  );

  static final TextStyle _statValueStyle = AppTypography.titleSmall.copyWith(
    color: AppColors.textPrimary,
  );

  bool get _hasPreviousSeason =>
      pitcher.previousSeasonEra != null ||
      pitcher.previousSeasonWhip != null ||
      pitcher.previousSeasonK != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: PositionChip(position: positionLabel)),
          const SizedBox(height: AppSpacing.lg),
          Center(child: _pitcherAvatar()),
          const SizedBox(height: AppSpacing.lg),
          Text(
            pitcher.name,
            style: _nameStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            pitcher.handedness,
            style: _handednessStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeasonChip(
                  year: '2026',
                  isActive: pitcher.currentSeason,
                ),
                const SizedBox(width: AppSpacing.md),
                SeasonChip(
                  year: '2025',
                  isActive: !pitcher.currentSeason,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, thickness: 1, color: AppColors.surfaceContainer),
          const SizedBox(height: AppSpacing.lg),
          if (isMlb) ...[
            _statRow3(
              labels: const ['ERA', 'WHIP', 'K/9'],
              values: [
                _fmtFixed(pitcher.era),
                _fmtFixed(pitcher.whip),
                _fmtFixed(pitcher.k9, fractionDigits: 1),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _statRow3(
              labels: const ['W-L', 'IP', 'K'],
              values: [
                pitcher.wl,
                _fmtFixed(pitcher.ip, fractionDigits: 1),
                '${pitcher.k}',
              ],
            ),
          ] else
            _statRow3(
              labels: const ['ERA', 'WHIP', 'K'],
              values: [
                _fmtFixed(pitcher.era),
                _fmtFixed(pitcher.whip),
                '${pitcher.k}',
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          _commentList(),
          if (_hasPreviousSeason) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, thickness: 1, color: AppColors.surfaceContainer),
            const SizedBox(height: AppSpacing.lg),
            const Center(
              child: SeasonChip(year: '2025', isActive: false),
            ),
            const SizedBox(height: AppSpacing.lg),
            _statRow3(
              labels: const ['ERA', 'WHIP', 'K'],
              values: [
                _fmtOptionalFixed(pitcher.previousSeasonEra),
                _fmtOptionalFixed(pitcher.previousSeasonWhip),
                _fmtOptionalInt(pitcher.previousSeasonK),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _pitcherAvatar() {
    const size = 80.0;
    const iconSize = 40.0;

    final url = pitcher.imageUrl;
    final useNetwork =
        isMlb && url != null && url.trim().isNotEmpty;

    if (!useNetwork) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainer,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.sports_baseball,
          size: iconSize,
          color: AppColors.textTertiary.withValues(alpha: 0.8),
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        url.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return Container(
            width: size,
            height: size,
            color: AppColors.surfaceContainer,
            alignment: Alignment.center,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textTertiary,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.sports_baseball,
            size: iconSize,
            color: AppColors.textTertiary.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _statRow3({
    required List<String> labels,
    required List<String> values,
  }) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: _StatCell(
            label: labels[i],
            value: values[i],
            labelStyle: _statLabelStyle,
            valueStyle: _statValueStyle,
          ),
        );
      }),
    );
  }

  Widget _commentList() {
    final items = <Widget>[];

    for (final text in pitcher.positiveComments) {
      items.add(CommentChip(text: text, isPositive: true));
      items.add(const SizedBox(height: AppSpacing.md));
    }
    for (final text in pitcher.negativeComments) {
      items.add(CommentChip(text: text, isPositive: false));
      items.add(const SizedBox(height: AppSpacing.md));
    }

    if (items.isNotEmpty) {
      items.removeLast();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }

  static String _fmtFixed(double v, {int fractionDigits = 2}) {
    return v.toStringAsFixed(fractionDigits);
  }

  static String _fmtOptionalFixed(double? v, {int fractionDigits = 2}) {
    if (v == null) {
      return '—';
    }
    return v.toStringAsFixed(fractionDigits);
  }

  static String _fmtOptionalInt(int? v) {
    if (v == null) {
      return '—';
    }
    return '$v';
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: valueStyle, textAlign: TextAlign.center),
      ],
    );
  }
}
