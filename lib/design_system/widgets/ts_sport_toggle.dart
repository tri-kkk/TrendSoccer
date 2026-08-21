import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsSport { soccer, baseball }

class TsSportToggle extends StatelessWidget {
  const TsSportToggle({
    required this.active,
    required this.onChanged,
    super.key,
  });

  final TsSport active;
  final ValueChanged<TsSport> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      height: 36,
      padding: const EdgeInsets.all(TsSpacing.xxs),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: TsRadius.full,
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              sport: TsSport.soccer,
              active: active,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: TsSpacing.xxs),
          Expanded(
            child: _Segment(
              sport: TsSport.baseball,
              active: active,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.sport,
    required this.active,
    required this.onChanged,
  });

  final TsSport sport;
  final TsSport active;
  final ValueChanged<TsSport> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final selected = sport == active;
    final icon = sport == TsSport.soccer ? TsIcons.soccer : TsIcons.baseball;
    final label = sport == TsSport.soccer ? 'Soccer' : 'Baseball';

    return GestureDetector(
      onTap: () => onChanged(sport),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: TsSpacing.xxl,
        padding: const EdgeInsets.symmetric(
          vertical: TsSpacing.xs,
          horizontal: TsSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? c.primary : Colors.transparent,
          borderRadius: TsRadius.full,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TsIcon(
              icon,
              size: TsSpacing.lg,
              color: selected ? c.onPrimary : c.primary,
            ),
            const SizedBox(width: TsSpacing.xs),
            Text(
              label,
              style: (selected ? TsType.bodyMBold : TsType.bodyMMedium)
                  .copyWith(
                color: selected ? c.onPrimary : c.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
