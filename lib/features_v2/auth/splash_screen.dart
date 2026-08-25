import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:trendsoccer/core/models/app_config_model.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/services/app_config_service.dart';
import 'package:trendsoccer/core/utils/version_utils.dart';
import 'package:trendsoccer/design_system/icons/ts_logo.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/features_v2/system/force_update_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final Future<void> _minimumDisplay;

  @override
  void initState() {
    super.initState();
    _minimumDisplay =
        Future<void>.delayed(const Duration(milliseconds: 1500));
    _run();
  }

  Future<void> _run() async {
    final decision = await _initialize()
        .timeout(const Duration(seconds: 3), onTimeout: () => null);
    await _minimumDisplay;
    if (!mounted) return;
    if (kDebugMode &&
        const String.fromEnvironment('FORCE_GATE') == 'billing') {
      context.go('/billing-loading');
      return;
    }
    if (decision != null) {
      context.go('/force-update', extra: decision);
      return;
    }
    context.go('/home');
  }

  Future<ForceUpdateArgs?> _initialize() async {
    // Debug-only gate override. Release builds cannot reach this —
    // kDebugMode is a const false there and the branch is tree-shaken.
    // Usage: flutter run --dart-define=FORCE_GATE=maintenance|update|billing
    if (kDebugMode) {
      const forced = String.fromEnvironment('FORCE_GATE');
      if (forced == 'maintenance') {
        return const ForceUpdateArgs(reason: ForceUpdateReason.maintenance);
      }
      if (forced == 'update') {
        return const ForceUpdateArgs(reason: ForceUpdateReason.update);
      }
    }

    final results = await Future.wait<Object?>([
      _fetchConfig(),
      _restoreAuth(),
    ]);
    final config = results[0] as AppConfigData?;

    if (config != null) {
      if (config.maintenanceMode) {
        return ForceUpdateArgs(
          reason: ForceUpdateReason.maintenance,
          message: config.maintenanceMessage,
        );
      }

      try {
        final packageInfo = await PackageInfo.fromPlatform().timeout(
          const Duration(seconds: 2),
        );
        if (VersionUtils.isVersionOutdated(
          packageInfo.version,
          config.minSupportedVersion,
        )) {
          return ForceUpdateArgs(
            reason: ForceUpdateReason.update,
            message: config.updateMessage,
          );
        }
      } on Object {
        // PackageInfo failed — continue to app.
      }
    }

    return null;
  }

  Future<AppConfigData?> _fetchConfig() async {
    try {
      return await ref
          .read(appConfigServiceProvider)
          .fetchConfig()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
    } on Object {
      return null;
    }
  }

  Future<void> _restoreAuth() async {
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
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Scaffold(
      backgroundColor: c.surfaceRaised,
      body: SafeArea(
        child: Stack(
          children: [
            const Center(
              child: TsLogo(TsLogoType.vertical, height: 201),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 157,
              child: Center(child: _LoadingDots(color: c.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots({required this.color});

  final Color color;

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _opacities;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _opacities = List.generate(3, (i) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 50),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            i * 0.2,
            i * 0.2 + 0.6,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: TsSpacing.sm),
          FadeTransition(
            opacity: _opacities[i],
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
