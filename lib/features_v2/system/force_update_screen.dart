import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/core/services/app_config_service.dart';
import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_toast.dart';

enum ForceUpdateReason { maintenance, update }

class ForceUpdateArgs {
  const ForceUpdateArgs({required this.reason, this.message});

  final ForceUpdateReason reason;
  final String? message;
}

class ForceUpdateScreen extends ConsumerStatefulWidget {
  const ForceUpdateScreen({this.args, super.key});

  final ForceUpdateArgs? args;

  @override
  ConsumerState<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends ConsumerState<ForceUpdateScreen> {
  static const _applicationId = 'com.trendsoccer.app';

  bool _checking = false;

  ForceUpdateReason get _reason =>
      widget.args?.reason ?? ForceUpdateReason.update;

  bool get _isMaintenance => _reason == ForceUpdateReason.maintenance;

  String get _title => _isMaintenance ? 'Under maintenance' : 'Update required';

  String get _defaultSubtitle => _isMaintenance
      ? 'We are working on it. Please try again shortly.'
      : 'A new version is available. Update to keep using TrendSoccer.';

  String get _subtitle {
    final serverMessage = widget.args?.message?.trim();
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }
    return _defaultSubtitle;
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
        _showErrorToast('Still under maintenance. Please try again shortly.');
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
                          _title,
                          style: TsType.h1.copyWith(color: c.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        Text(
                          _subtitle,
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
                        label: 'Retry',
                        style: TsButtonStyle.ghost,
                        size: TsButtonSize.large,
                        expand: true,
                        onPressed: _checking ? null : _retry,
                      )
                    else
                      TsButton(
                        label: 'Update now',
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
