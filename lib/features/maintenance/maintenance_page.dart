import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({
    super.key,
    this.maintenanceMessage,
  });

  final String? maintenanceMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final subtitle = maintenanceMessage ?? l10n.maintenanceSubtitle;

    return Scaffold(
      backgroundColor: semantic.surfaceRaised,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  TsAssets.iconWarning,
                  width: 80,
                  height: 80,
                  colorFilter: ColorFilter.mode(
                    semantic.textTertiary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: TsSpacing.xl),
                Text(
                  l10n.maintenanceTitle,
                  style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TsSpacing.sm),
                Text(
                  subtitle,
                  style: TsType.bodyLRegular.copyWith(
                    color: semantic.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
