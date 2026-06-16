import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/core/services/app_config_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class ForceUpdatePage extends ConsumerStatefulWidget {
  const ForceUpdatePage({
    super.key,
    this.updateMessage,
    this.forceUpdate,
  });

  final String? updateMessage;
  final bool? forceUpdate;

  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.trendsoccer.app';

  @override
  ConsumerState<ForceUpdatePage> createState() => _ForceUpdatePageState();
}

class _ForceUpdatePageState extends ConsumerState<ForceUpdatePage> {
  bool? _forceUpdate;
  bool _loadingConfig = true;

  @override
  void initState() {
    super.initState();
    _resolveForceUpdate();
  }

  Future<void> _resolveForceUpdate() async {
    if (widget.forceUpdate != null) {
      setState(() {
        _forceUpdate = widget.forceUpdate;
        _loadingConfig = false;
      });
      return;
    }

    final config = await ref.read(appConfigServiceProvider).fetchConfig();
    if (!mounted) return;
    setState(() {
      _forceUpdate = config?.forceUpdate ?? false;
      _loadingConfig = false;
    });
  }

  bool get _isForceUpdateRequired => _forceUpdate ?? false;

  Future<void> _openStore() async {
    final uri = Uri.parse(ForceUpdatePage._playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _skipUpdate() {
    context.go('/trend');
  }

  String _resolveUpdateMessage(BuildContext context, AppLocalizations l10n) {
    final apiMessage = widget.updateMessage?.trim();
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
      canPop: !_isForceUpdateRequired,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _isForceUpdateRequired) return;
        _skipUpdate();
      },
      child: Scaffold(
        backgroundColor: semantic.surfaceRaised,
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
                    l10n.forceUpdateTitle,
                    style: TsType.headingH2.copyWith(
                      color: semantic.textPrimary,
                    ),
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
                    label: l10n.forceUpdateButton,
                    variant: TsButtonVariant.primary,
                    onPressed: _openStore,
                  ),
                  if (!_loadingConfig && !_isForceUpdateRequired) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _skipUpdate,
                      child: Text(
                        l10n.forceUpdateSkip,
                        style: TsType.bodyLRegular.copyWith(
                          color: semantic.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
