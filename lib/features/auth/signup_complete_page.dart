import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../shared/widgets/auth/free_benefits_card.dart';
import '../../shared/widgets/auth/trial_banner.dart';
import '../../shared/widgets/auth/whats_next_card.dart';
import '../../shared/widgets/buttons/primary_button.dart';
import '../../shared/widgets/buttons/secondary_button.dart';

class SignupCompletePage extends StatefulWidget {
  const SignupCompletePage({super.key});

  @override
  State<SignupCompletePage> createState() => _SignupCompletePageState();
}

class _SignupCompletePageState extends State<SignupCompletePage> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    if (mounted) {
      context.go('/trend');
    }
  }

  void _handleUpgrade() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscribe page coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppColors.brandPrimary500,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Welcome !',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Column(
                        children: [
                          Text(
                            'Your account is ready.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Explore TrendSoccer now.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const TrialBanner(),
                  const SizedBox(height: AppSpacing.xxl),
                  const FreeBenefitsCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  WhatsNextCard(
                    onUpgradePressed: _handleUpgrade,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Column(
                    children: [
                      SecondaryButton(
                        label: 'Go to Home',
                        onPressed: _navigateToHome,
                        size: ButtonSize.large,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Redirecting in ${_countdown}s',
                        style: AppTypography.enLabelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
