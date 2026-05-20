import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({
    super.key,
    this.updateMessage,
  });

  final String? updateMessage;

  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.trendsoccer.app';

  Future<void> _openStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final subtitle = updateMessage ?? '최신 버전으로 업데이트해주세요.';

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
                  TsAssets.iconRocketLaunch,
                  width: 80,
                  height: 80,
                  colorFilter: ColorFilter.mode(
                    semantic.interactivePrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '업데이트가 필요합니다',
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
                const SizedBox(height: 32),
                TsButton(
                  label: '업데이트',
                  variant: TsButtonVariant.primary,
                  onPressed: _openStore,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
