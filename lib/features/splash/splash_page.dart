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
  String? _redirectPath;
  Object? _redirectExtra;

  @override
  void initState() {
    super.initState();
    _runSplash();
  }

  Future<void> _runSplash() async {
    await Future.wait([
      Future<void>.delayed(const Duration(seconds: 2)),
      _initializeApp(),
    ]);
    if (!mounted) return;

    final redirectPath = _redirectPath;
    if (redirectPath != null) {
      context.go(redirectPath, extra: _redirectExtra);
      return;
    }
    context.go('/trend');
  }

  Future<void> _initializeApp() async {
    try {
      final config = await ref
          .read(appConfigServiceProvider)
          .fetchConfig()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (!mounted) return;

      if (config != null) {
        if (config.maintenanceMode) {
          _redirectPath = '/maintenance';
          _redirectExtra = config.maintenanceMessage;
          return;
        }

        final packageInfo = await PackageInfo.fromPlatform();
        if (VersionUtils.isVersionOutdated(
          packageInfo.version,
          config.minSupportedVersion,
        )) {
          _redirectPath = '/force-update';
          _redirectExtra = config.updateMessage;
          return;
        }
      }
    } on Object {
      // Config fetch failed — continue to app.
    }

    try {
      await ref
          .read(authProvider)
          .initFromStoredToken()
          .timeout(const Duration(seconds: 5));
    } on Object {
      // Auth init failed — continue as guest.
    }
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
