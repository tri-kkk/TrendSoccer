import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/access_gate.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/pick_direction_badge.dart';
import 'package:trendsoccer/shared/widgets/league/ts_league_icon.dart';

class AnalysisCard extends StatelessWidget {
  const AnalysisCard({
    required this.leagueId,
    required this.leagueName,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchTime,
    this.homeLogoUrl,
    this.awayLogoUrl,
    this.leagueLogoUrl,
    this.matchTimestamp,
    this.planType,
    this.onAnalyze,
    this.isPremiumPick = false,
    this.pickDirection,
    this.winRate,
    this.alwaysActiveAnalyzeButton = false,
    super.key,
  });

  final String leagueId;
  final String leagueName;
  final String date;
  final String homeTeam;
  final String awayTeam;
  final String matchTime;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final String? leagueLogoUrl;
  final DateTime? matchTimestamp;
  final PlanType? planType;
  final VoidCallback? onAnalyze;
  final bool isPremiumPick;
  final PickDirection? pickDirection;
  final String? winRate;
  final bool alwaysActiveAnalyzeButton;

  Widget _teamLogo(BuildContext context, String? url) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    const logoSize = 48.0;
    Widget image(String u) {
      return CachedNetworkImage(
        imageUrl: u,
        width: logoSize,
        height: logoSize,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(
          width: logoSize,
          height: logoSize,
          color: semantic.surfaceContainer,
        ),
        errorWidget: (context, _, _) => Container(
          width: logoSize,
          height: logoSize,
          color: semantic.surfaceContainer,
        ),
      );
    }

    return ClipOval(
      child: url != null && url.isNotEmpty
          ? image(url)
          : Container(
              width: logoSize,
              height: logoSize,
              color: semantic.surfaceContainer,
            ),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, TsSemanticColors semantic) {
    final l10n = context.l10n;
    if (alwaysActiveAnalyzeButton) {
      return TsButton(
        label: l10n.analysisCardView,
        variant: TsButtonVariant.primary,
        onPressed: onAnalyze,
      );
    }

    final timestamp = matchTimestamp;
    final tier = planType;
    if (timestamp != null && tier != null) {
      final kickoff = timestamp.toUtc();
      final canView = AccessGate.canViewStandardAnalysis(
        matchTimestamp: kickoff,
        planType: tier,
      );
      if (canView) {
        return TsButton(
          label: l10n.analysisCardView,
          variant: TsButtonVariant.primary,
          onPressed: onAnalyze,
        );
      }

      final until = AccessGate.timeUntilUnlock(
        matchTimestamp: kickoff,
        planType: tier,
      );
      final label = until != null
          ? AccessGate.formatTimeUntilUnlock(until, l10n: l10n)
          : l10n.analysisCardView;

      return SizedBox(
        width: double.infinity,
        height: 48,
        child: Material(
          color: semantic.textDisabled,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onAnalyze,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                label,
                style: TsType.bodyLBold.copyWith(color: semantic.textTertiary),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      );
    }

    return TsButton(
      label: l10n.analysisCardViewAnalysis,
      variant: TsButtonVariant.primary,
      onPressed: onAnalyze,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return SizedBox(
      width: double.infinity,
      child: Container(
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TsLeagueIcon(
                      leagueId: leagueId,
                      size: 24,
                      logoUrl: leagueLogoUrl,
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Text(
                      leagueName,
                      style: TsType.labelSRegular.copyWith(
                        color: semantic.textTertiary,
                      ),
                    ),
                  ],
                ),
                Text(
                  date,
                  style: TsType.labelSRegular.copyWith(
                    color: semantic.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TsSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _teamLogo(context, homeLogoUrl),
                      const SizedBox(height: 6),
                      Text(
                        homeTeam,
                        style: TsType.bodyMBold.copyWith(
                          color: semantic.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TsSpacing.lg),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VS',
                      style: TsType.bodyMBold.copyWith(
                        color: semantic.textPrimary,
                      ),
                    ),
                    const SizedBox(height: TsSpacing.xs),
                    Text(
                      matchTime,
                      style: TsType.labelSRegular.copyWith(
                        color: semantic.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: TsSpacing.lg),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _teamLogo(context, awayLogoUrl),
                      const SizedBox(height: 6),
                      Text(
                        awayTeam,
                        style: TsType.bodyMBold.copyWith(
                          color: semantic.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TsSpacing.md),
            if (isPremiumPick &&
                pickDirection != null &&
                winRate != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TsSpacing.md,
                  vertical: TsSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: semantic.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PickDirectionBadge(pick: pickDirection!),
                    const SizedBox(width: 10),
                    Text(
                      winRate!,
                      style: TsType.bodyMBold.copyWith(
                        color: semantic.interactivePrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TsSpacing.lg),
            ],
            _buildAnalyzeButton(context, semantic),
          ],
        ),
      ),
    );
  }
}
