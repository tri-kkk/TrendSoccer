import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/auth/free_benefits_card.dart';
import 'package:trendsoccer/shared/widgets/auth/trial_banner.dart';
import 'package:trendsoccer/shared/widgets/auth/whats_next_card.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        _timer?.cancel();
        context.go('/trend');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: TsSpacing.xxxl),
              Icon(
                Icons.check_circle,
                size: 64,
                color: semantic.interactivePrimary,
              ),
              const SizedBox(height: TsSpacing.lg),
              Text(
                'Welcome!',
                textAlign: TextAlign.center,
                style: TsType.headingH1.copyWith(color: semantic.textPrimary),
              ),
              Text(
                '회원가입이 완료되었습니다',
                textAlign: TextAlign.center,
                style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
              ),
              const SizedBox(height: TsSpacing.xl),
              const TrialBanner(),
              const SizedBox(height: TsSpacing.xl),
              const FreeBenefitsCard(),
              const SizedBox(height: TsSpacing.lg),
              WhatsNextCard(onUpgradeTap: () => context.push('/menu/subscribe')),
              const Spacer(),
              Text(
                '$_countdown초 후 자동으로 이동합니다',
                textAlign: TextAlign.center,
                style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
              ),
              const SizedBox(height: TsSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
