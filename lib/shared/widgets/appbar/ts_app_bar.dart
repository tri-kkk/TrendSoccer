import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/back_button.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

enum TsAppBarLocation { home, backTitle }

/// Custom app bar for pushed routes. Use [TsAppBar.preferred] with
/// [Scaffold.appBar] so status-bar inset is included in [PreferredSize]
/// (a fixed-height bar without this sits under the notch/status bar).
class TsAppBar {
  TsAppBar._();

  static double _toolbarHeight(TsAppBarLocation location) =>
      location == TsAppBarLocation.home ? 56 : 52;

  static PreferredSizeWidget preferred(
    BuildContext context, {
    required TsAppBarLocation location,
    String? title,
    VoidCallback? onBack,
    Widget? trailing,
    Widget? leading,
  }) {
    final top = MediaQuery.paddingOf(context).top;
    final toolbarHeight = _toolbarHeight(location);
    return PreferredSize(
      preferredSize: Size.fromHeight(top + toolbarHeight),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: SizedBox(
          height: toolbarHeight,
          child: _TsAppBarToolbar(
            location: location,
            title: title,
            onBack: onBack,
            trailing: trailing,
            leading: leading,
          ),
        ),
      ),
    );
  }
}

class _TsAppBarToolbar extends StatelessWidget {
  const _TsAppBarToolbar({
    required this.location,
    this.title,
    this.onBack,
    this.trailing,
    this.leading,
  });

  final TsAppBarLocation location;
  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final bottomBorder = BorderSide(
      color: semantic.textDisabled,
      width: 2,
    );

    return switch (location) {
      TsAppBarLocation.home => Container(
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            border: Border(bottom: bottomBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg, vertical: TsSpacing.md),
          child: Row(
            children: [
              leading ?? const SizedBox.shrink(),
              const Spacer(),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
        ),
      TsAppBarLocation.backTitle => Container(
          padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            border: Border(bottom: bottomBorder),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  title ?? '',
                  style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TsBackButton(onPressed: onBack),
              ),
            ],
          ),
        ),
    };
  }
}
