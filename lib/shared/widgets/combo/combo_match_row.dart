import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_status_badge.dart';

class ComboMatchRow extends StatelessWidget {
  const ComboMatchRow({
    required this.homeTeam,
    required this.awayTeam,
    required this.predictTeam,
    required this.predictDirection,
    required this.odds,
    required this.winRate,
    required this.winRateRatio,
    required this.comment,
    this.homeLogoUrl,
    this.awayLogoUrl,
    this.matchResult,
    this.homeScore,
    this.awayScore,
    super.key,
  });

  final String homeTeam;
  final String awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final String predictTeam;
  final String predictDirection;
  final String odds;
  final String winRate;
  final double winRateRatio;
  final String comment;
  final ComboStatus? matchResult;
  final int? homeScore;
  final int? awayScore;

  bool _homePredicted(BuildContext context) {
    final home = context.l10n.labelHome;
    return predictDirection == home || predictDirection == '홈';
  }

  bool get _isFinished =>
      matchResult == ComboStatus.hit || matchResult == ComboStatus.miss;

  Widget _scoreCell(
    TsSemanticColors semantic, {
    required int? score,
    required bool? isWinner,
  }) {
    final text = score?.toString() ?? '-';
    final Color color;
    if (!_isFinished || score == null) {
      color = semantic.textTertiary;
    } else if (isWinner == true) {
      color = semantic.textPrimary;
    } else if (isWinner == false) {
      color = semantic.textDisabled;
    } else {
      color = semantic.textPrimary;
    }

    return SizedBox(
      width: 24,
      child: Text(
        text,
        style: TsType.bodyMBold.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _avatar(
    TsSemanticColors semantic, {
    required String? url,
    required bool faded,
  }) {
    Widget circle(Color bg) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
      );
    }

    Widget img = url == null || url.isEmpty
        ? circle(semantic.surfaceContainer)
        : ClipOval(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => circle(semantic.surfaceContainer),
                errorWidget: (context, url, error) => circle(semantic.surfaceContainer),
              ),
            ),
          );
    if (faded) {
      return Opacity(opacity: 0.35, child: img);
    }
    return img;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final homePredicted = _homePredicted(context);
    final homeFaded = !homePredicted;
    final awayFaded = homePredicted;

    bool? homeWinner;
    bool? awayWinner;
    if (_isFinished && homeScore != null && awayScore != null) {
      if (homeScore! > awayScore!) {
        homeWinner = true;
        awayWinner = false;
      } else if (awayScore! > homeScore!) {
        homeWinner = false;
        awayWinner = true;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 8,
                          child: Text(
                            'H',
                            style: TsType.labelSBold.copyWith(color: semantic.textPrimary),
                          ),
                        ),
                        const SizedBox(width: TsSpacing.xs),
                        _avatar(semantic, url: homeLogoUrl, faded: homeFaded),
                        const SizedBox(width: TsSpacing.xs),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  homeTeam,
                                  style: TsType.bodyMBold.copyWith(
                                    color: homeFaded ? semantic.textDisabled : semantic.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _scoreCell(
                          semantic,
                          score: homeScore,
                          isWinner: homeWinner,
                        ),
                      ],
                    ),
                    const SizedBox(height: TsSpacing.xs),
                    Row(
                      children: [
                        SizedBox(
                          width: 8,
                          child: Text(
                            'A',
                            style: TsType.labelSBold.copyWith(color: semantic.textTertiary),
                          ),
                        ),
                        const SizedBox(width: TsSpacing.xs),
                        _avatar(semantic, url: awayLogoUrl, faded: awayFaded),
                        const SizedBox(width: TsSpacing.xs),
                        Expanded(
                          child: Text(
                            awayTeam,
                            style: TsType.bodyMBold.copyWith(
                              color: awayFaded ? semantic.textDisabled : semantic.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _scoreCell(
                          semantic,
                          score: awayScore,
                          isWinner: awayWinner,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TsSpacing.lg),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  predictTeam,
                                  style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: TsSpacing.xs),
                              Text(
                                l10n.comboWin,
                                style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        if (matchResult != null) ...[
                          const SizedBox(width: TsSpacing.xs),
                          ComboStatusBadge(status: matchResult!),
                        ],
                      ],
                    ),
                    const SizedBox(height: TsSpacing.xs),
                    Text(
                      odds,
                      style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
                    ),
                    const SizedBox(height: TsSpacing.xs),
                    Row(
                      children: [
                        Text(
                          winRate,
                          style: TsType.labelSRegular.copyWith(color: semantic.interactivePrimary),
                        ),
                        const SizedBox(width: TsSpacing.xs),
                        SizedBox(
                          width: 80,
                          height: 4,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: semantic.surfaceContainer,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 80 * winRateRatio.clamp(0.0, 1.0),
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: semantic.interactivePrimary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            comment,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
