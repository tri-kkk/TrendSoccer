import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({
    super.key,
    this.updateMessage,
    this.forceUpdate,
  });

  final String? updateMessage;
  final bool? forceUpdate;

  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.trendsoccer.app';

  Future<void> _openStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _resolveUpdateMessage(BuildContext context, AppLocalizations l10n) {
    final apiMessage = updateMessage?.trim();
    if (isKoreanLocale(context) &&
        apiMessage != null &&
        apiMessage.isNotEmpty) {
      return apiMessage;
    }
    return l10n.forceUpdateMessage;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final subtitle = _resolveUpdateMessage(context, l10n);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: semantic.surfaceRaised,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TsSpacing.xl),
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
                  const SizedBox(height: TsSpacing.xl),
                  Text(
                    l10n.forceUpdateTitle,
                    style: TsType.headingH2.copyWith(
                      color: semantic.textPrimary,
                    ),
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
                  const SizedBox(height: TsSpacing.xxl),
                  TsButton(
                    label: l10n.forceUpdateButton,
                    variant: TsButtonVariant.primary,
                    onPressed: _openStore,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
