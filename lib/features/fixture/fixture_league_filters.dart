import 'package:flutter/material.dart';

import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_logo.dart';

class FixtureLeagueFilters extends StatelessWidget {
  const FixtureLeagueFilters({
    required this.leagues,
    required this.selectedLeague,
    required this.filterAllLabel,
    required this.liveLabel,
    required this.locale,
    required this.showLiveChip,
    required this.isLiveFilter,
    required this.onSelectAll,
    required this.onLiveTap,
    required this.onSelectLeague,
    super.key,
  });

  final List<FixtureLeagueOption> leagues;
  final String? selectedLeague;
  final String filterAllLabel;
  final String liveLabel;
  final String locale;
  final bool showLiveChip;
  final bool isLiveFilter;
  final VoidCallback onSelectAll;
  final VoidCallback onLiveTap;
  final ValueChanged<String> onSelectLeague;

  @override
  Widget build(BuildContext context) {
    final liveOffset = showLiveChip ? 1 : 0;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: leagues.length + 1 + liveOffset,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TsFilterChip(
              label: filterAllLabel,
              isSelected: selectedLeague == null && !isLiveFilter,
              type: TsFilterChipType.textOnly,
              onTap: onSelectAll,
            );
          }

          if (showLiveChip && index == 1) {
            return _LiveFilterChip(
              label: liveLabel,
              isActive: isLiveFilter,
              onTap: onLiveTap,
            );
          }

          final league = leagues[index - 1 - liveOffset];
          final displayName = locale == 'en'
              ? (league.nameEn ?? league.name)
              : league.name;

          return TsFilterChip(
            label: displayName,
            isSelected: !isLiveFilter && selectedLeague == league.code,
            type: TsFilterChipType.withIcon,
            iconWidget: FixtureLeagueLogo(
              leagueName: displayName,
              leagueCode: league.code,
              leagueLogoUrl: league.logo,
              size: 16,
            ),
            onTap: () => onSelectLeague(league.code),
          );
        },
      ),
    );
  }
}

class _LiveFilterChip extends StatelessWidget {
  const _LiveFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final backgroundColor =
        isActive ? semantic.textPrimary : semantic.surfaceBase;
    final textColor = isActive ? semantic.surfaceBase : semantic.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(
          horizontal: TsSpacing.md,
          vertical: TsSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: TsColors.systemError500,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: TsSpacing.xs),
            Text(
              label,
              style: TsType.labelSRegular.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
