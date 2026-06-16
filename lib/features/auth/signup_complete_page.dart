import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class SignupCompletePage extends ConsumerStatefulWidget {
  const SignupCompletePage({super.key});

  @override
  ConsumerState<SignupCompletePage> createState() => _SignupCompletePageState();
}

class _SignupCompletePageState extends ConsumerState<SignupCompletePage> {
  Timer? _redirectTimer;
  int _countdown = 5;
  bool _countdownFinished = false;

  bool get _showManualHome => _countdownFinished || _redirectTimer == null;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _cancelRedirect();
    _countdown = 5;
    _countdownFinished = false;
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _cancelRedirect();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        _countdownFinished = true;
        _cancelRedirect();
        TsToast.success(context, context.l10n.signupCompleteSuccessToast);
        context.go('/trend');
      }
    });
  }

  void _goHome() {
    _cancelRedirect();
    context.go('/trend');
  }

  void _cancelRedirect() {
    _redirectTimer?.cancel();
    _redirectTimer = null;
  }

  @override
  void dispose() {
    _cancelRedirect();
    super.dispose();
  }

  Widget _benefitRow({
    required String text,
    required Color textColor,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          TsAssets.iconCheckSmall,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TsType.bodyLRegular.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _benefitsCard({
    required TsSemanticColors semantic,
    required String header,
    required Color headerColor,
    required Color iconColor,
    required Color textColor,
    required List<String> benefits,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceBase,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TsType.bodyLRegular.copyWith(color: headerColor),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < benefits.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _benefitRow(
              text: benefits[i],
              textColor: textColor,
              iconColor: iconColor,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goHome();
      },
      child: Scaffold(
        backgroundColor: semantic.surfaceRaised,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: semantic.surfaceRaised,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
            onPressed: _goHome,
          ),
          title: Text(
            l10n.signupCompleteAppBarTitle,
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(height: 2, color: semantic.textDisabled),
          ),
        ),
        body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 32,
            bottom: 32 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                TsAssets.iconCheckCircle,
                width: 80,
                height: 80,
                colorFilter: ColorFilter.mode(
                  semantic.interactivePrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.signupCompleteTitle,
                style: TsType.displayHero.copyWith(color: semantic.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.signupCompleteStartPrompt,
                style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: semantic.interactivePrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: semantic.interactivePrimary, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.signupCompleteTrialBanner,
                  style: TsType.bodyLRegular.copyWith(color: semantic.interactivePrimary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              _benefitsCard(
                semantic: semantic,
                header: l10n.signupCompleteFreeBenefitsHeader,
                headerColor: semantic.textPrimary,
                iconColor: semantic.textSecondary,
                textColor: semantic.textSecondary,
                benefits: [
                  l10n.signupCompleteFreeBenefit1,
                  l10n.signupCompleteFreeBenefit2,
                  l10n.signupCompleteFreeBenefit3,
                ],
              ),
              const SizedBox(height: 16),
              _benefitsCard(
                semantic: semantic,
                header: l10n.signupCompletePremiumBenefitsHeader,
                headerColor: semantic.interactivePrimary,
                iconColor: semantic.interactivePrimary,
                textColor: semantic.textPrimary,
                benefits: [
                  l10n.signupCompletePremiumBenefit1,
                  l10n.signupCompletePremiumBenefit2,
                  l10n.signupCompletePremiumBenefit3,
                ],
              ),
              const SizedBox(height: 16),
              TsButton(
                label: l10n.signupCompletePremiumUpgrade,
                variant: TsButtonVariant.primary,
                onPressed: () {
                  _cancelRedirect();
                  context.go('/menu/subscribe');
                },
              ),
              const SizedBox(height: 16),
              if (_showManualHome)
                TsButton(
                  label: l10n.signupCompleteGoHome,
                  variant: TsButtonVariant.secondary,
                  onPressed: _goHome,
                )
              else
                Text(
                  l10n.signupCompleteCountdown(_countdown),
                  style: TsType.labelSRegular.copyWith(
                    color: semantic.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
