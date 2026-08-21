import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsNavTab { home, matches, reports, feed, menu }

class TsBottomNavigation extends StatelessWidget {
  const TsBottomNavigation({
    required this.active,
    required this.onTap,
    super.key,
  });

  final TsNavTab active;
  final ValueChanged<TsNavTab> onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.borderSubtle, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: TsSpacing.sm),
      child: Row(
        children: [
          for (final tab in TsNavTab.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onTap(tab),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TsIcon(
                      _icon(tab),
                      size: TsIconSize.md,
                      color: tab == active ? c.primary : c.textTertiary,
                    ),
                    const SizedBox(height: TsSpacing.xxs),
                    Text(
                      _label(tab),
                      style: (tab == active
                              ? TsType.labelSBold
                              : TsType.labelSMedium)
                          .copyWith(
                        color:
                            tab == active ? c.primary : c.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static TsIconSpec _icon(TsNavTab tab) => switch (tab) {
        TsNavTab.home => TsIcons.homeFilled,
        TsNavTab.matches => TsIcons.fixture,
        TsNavTab.reports => TsIcons.article,
        TsNavTab.feed => TsIcons.newspaper,
        TsNavTab.menu => TsIcons.menu,
      };

  static String _label(TsNavTab tab) => switch (tab) {
        TsNavTab.home => 'Home',
        TsNavTab.matches => 'Matches',
        TsNavTab.reports => 'Reports',
        TsNavTab.feed => 'Feed',
        TsNavTab.menu => 'Menu',
      };
}
