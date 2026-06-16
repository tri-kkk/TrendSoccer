import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/services/app_config_service.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/version_utils.dart';
import 'package:trendsoccer/shared/widgets/logo/ts_logo.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 2), _onSplashComplete);
  }

  Future<void> _onSplashComplete() async {
    if (!mounted) return;

    final config = await ref.read(appConfigServiceProvider).fetchConfig();
    if (!mounted) return;

    if (config == null) {
      await _proceedToApp();
      return;
    }

    if (config.maintenanceMode) {
      context.go('/maintenance', extra: config.maintenanceMessage);
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    if (VersionUtils.isVersionOutdated(
      currentVersion,
      config.minSupportedVersion,
    )) {
      if (!mounted) return;
      context.go('/force-update', extra: config.updateMessage);
      return;
    }

    await _proceedToApp();
  }

  Future<void> _proceedToApp() async {
    await ref.read(authProvider).initFromStoredToken();
    if (!mounted) return;
    context.go('/trend');
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = isDark ? TsLogoColor.white : TsLogoColor.black;

    return Scaffold(
      backgroundColor: semantic.surfaceRaised,
      body: Stack(
        children: [
          Center(
            child: TsLogo(
              type: TsLogoType.vertical,
              color: logoColor,
              height: 160,
            ),
          ),
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: semantic.interactivePrimary,
                  strokeWidth: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
