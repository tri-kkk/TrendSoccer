import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/core/services/app_config_service.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_toast.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

enum AppGateReason { maintenance, update }

class AppGateArgs {
  const AppGateArgs({required this.reason, this.message});

  final AppGateReason reason;
  final String? message;
}

class AppGateScreen extends ConsumerStatefulWidget {
  const AppGateScreen({this.args, super.key});

  final AppGateArgs? args;

  @override
  ConsumerState<AppGateScreen> createState() => _AppGateScreenState();
}

class _AppGateScreenState extends ConsumerState<AppGateScreen> {
  static const _applicationId = 'com.trendsoccer.app';

  bool _checking = false;

  AppGateReason get _reason =>
      widget.args?.reason ?? AppGateReason.update;

  bool get _isMaintenance => _reason == AppGateReason.maintenance;

  String _title(AppLocalizations l10n) => _isMaintenance
      ? l10n.appGateMaintenanceTitle
      : l10n.appGateUpdateTitle;

  String _defaultSubtitle(AppLocalizations l10n) => _isMaintenance
      ? l10n.appGateMaintenanceSubtitle
      : l10n.appGateUpdateSubtitle;

  String _subtitle(AppLocalizations l10n) {
    final serverMessage = widget.args?.message?.trim();
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }
    return _defaultSubtitle(l10n);
  }

  Future<void> _openStore() async {
    try {
      final uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$_applicationId',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } on Object {
      // Store launch failed — non-fatal.
    }
  }

  Future<void> _retry() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final config = await ref
          .read(appConfigServiceProvider)
          .fetchConfig()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (!mounted) return;
      if (config == null || config.maintenanceMode) {
        _showErrorToast(context.l10n.appGateMaintenanceRetryToast);
        return;
      }
      context.go('/splash');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _showErrorToast(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: TsToast(message: message, type: TsToastType.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final l10n = context.l10n;
    final icon = _isMaintenance ? TsIcons.warning : TsIcons.rocketLaunch;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: c.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      TsSpacing.lg,
                      TsSpacing.lg,
                      TsSpacing.lg,
                      TsSpacing.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TsIcon(
                          icon,
                          size: TsIconSize.xl,
                          color: c.textPrimary,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        Text(
                          _title(l10n),
                          style: TsType.h1.copyWith(color: c.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        Text(
                          _subtitle(l10n),
                          style: TsType.bodyLMedium.copyWith(
                            color: c.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(TsSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isMaintenance)
                      TsButton(
                        label: l10n.retry,
                        style: TsButtonStyle.ghost,
                        size: TsButtonSize.large,
                        expand: true,
                        onPressed: _checking ? null : _retry,
                      )
                    else
                      TsButton(
                        label: l10n.appGateUpdateButton,
                        style: TsButtonStyle.primary,
                        size: TsButtonSize.large,
                        expand: true,
                        onPressed: _openStore,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
