import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class BillingLoadingScreen extends StatelessWidget {
  const BillingLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: c.surfaceRaised,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _LoadingDots(color: c.primary),
                  const SizedBox(height: TsSpacing.lg),
                  Text(
                    'Processing payment',
                    style: TsType.h3.copyWith(color: c.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  Text(
                    'Do not close the app.\nThis may take a moment.',
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
              width: 10,
              height: 10,
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
