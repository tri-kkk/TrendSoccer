import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';

class SignupCompleteScreen extends StatefulWidget {
  const SignupCompleteScreen({super.key});

  @override
  State<SignupCompleteScreen> createState() => _SignupCompleteScreenState();
}

class _SignupCompleteScreenState extends State<SignupCompleteScreen> {
  int _seconds = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds <= 1) {
        _goHome();
        return;
      }
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goHome() {
    _timer?.cancel();
    if (!mounted) return;
    context.go('/home');
  }

  Widget _benefitRow(TsThemeColors c, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TsIcon(
          TsIcons.checkCircleOutline,
          size: TsIconSize.sm,
          color: c.textPrimary,
        ),
        const SizedBox(width: TsSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: TsType.bodyLMedium.copyWith(color: c.textPrimary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goHome();
      },
      child: Scaffold(
        backgroundColor: c.canvas,
        body: SafeArea(
          child: Stack(
            children: [
              // Figma centres Content 40px above the frame centre (CENTER constraint).
              // Reserving 80 at the bottom reproduces that offset at any height.
              Positioned.fill(
                bottom: 80,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TsSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TsIcon(
                          TsIcons.celebration,
                          size: TsIconSize.xl,
                          color: c.textPrimary,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        Text(
                          'Welcome to TrendSoccer',
                          style: TsType.h1.copyWith(color: c.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        Text(
                          'Your 48-hour free trial has started',
                          style: TsType.bodyLMedium.copyWith(
                            color: c.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: TsRadius.md,
                          ),
                          padding: const EdgeInsets.all(TsSpacing.lg),
                          child: Column(
                            children: [
                              _benefitRow(
                                c,
                                'Soccer and baseball premium analysis',
                              ),
                              const SizedBox(height: TsSpacing.md),
                              _benefitRow(
                                c,
                                'Multi-match combination reports',
                              ),
                              const SizedBox(height: TsSpacing.md),
                              _benefitRow(c, 'Ad-free experience'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: TsSpacing.lg,
                right: TsSpacing.lg,
                bottom: TsSpacing.xxxl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TsButton(
                      label: 'Start now',
                      style: TsButtonStyle.primary,
                      size: TsButtonSize.large,
                      expand: true,
                      onPressed: _goHome,
                    ),
                    const SizedBox(height: TsSpacing.sm),
                    Text(
                      'Moving to home in ${_seconds}s',
                      style: TsType.labelSMedium.copyWith(
                        color: c.textTertiary,
                      ),
                      textAlign: TextAlign.center,
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
