import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({
    super.key,
    this.maintenanceMessage,
  });

  final String? maintenanceMessage;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final subtitle =
        maintenanceMessage ?? '잠시 후 다시 시도해주세요.';

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                const SizedBox(height: 24),
                Text(
                  '서비스 점검 중',
                  style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
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
