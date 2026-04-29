import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../shared/widgets/appbar/custom_appbar.dart';
import '../../shared/widgets/auth/terms_card.dart';
import '../../shared/widgets/buttons/primary_button.dart';
import '../../shared/widgets/buttons/secondary_button.dart';

class SignupTermsPage extends StatefulWidget {
  const SignupTermsPage({super.key});

  @override
  State<SignupTermsPage> createState() => _SignupTermsPageState();
}

class _SignupTermsPageState extends State<SignupTermsPage> {
  bool _agreeToAll = false;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _marketingAccepted = false;

  bool get _canSignUp => _termsAccepted && _privacyAccepted;

  void _syncAgreeToAllFromItems() {
    _agreeToAll = _termsAccepted && _privacyAccepted && _marketingAccepted;
  }

  void _handleAgreeToAll() {
    setState(() {
      _agreeToAll = !_agreeToAll;
      _termsAccepted = _agreeToAll;
      _privacyAccepted = _agreeToAll;
      _marketingAccepted = _agreeToAll;
    });
  }

  void _handleTermsChanged() {
    setState(() {
      _termsAccepted = !_termsAccepted;
      _syncAgreeToAllFromItems();
    });
  }

  void _handlePrivacyChanged() {
    setState(() {
      _privacyAccepted = !_privacyAccepted;
      _syncAgreeToAllFromItems();
    });
  }

  void _handleMarketingChanged() {
    setState(() {
      _marketingAccepted = !_marketingAccepted;
      _syncAgreeToAllFromItems();
    });
  }

  void _handleTermsView() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service view coming soon')),
    );
  }

  void _handlePrivacyView() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy view coming soon')),
    );
  }

  void _handleSignUp() {
    if (_canSignUp) {
      context.push('/signup/complete');
    }
  }

  void _handleBackToSignIn() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: 'Sign Up',
          centerTitle: true,
          showBackButton: true,
          onBackPressed: () => context.pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/logos/logo_vertical_gradient.svg',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  TermsCard(
                    agreeToAll: _agreeToAll,
                    termsAccepted: _termsAccepted,
                    privacyAccepted: _privacyAccepted,
                    marketingAccepted: _marketingAccepted,
                    onAgreeToAllChanged: _handleAgreeToAll,
                    onTermsChanged: _handleTermsChanged,
                    onPrivacyChanged: _handlePrivacyChanged,
                    onMarketingChanged: _handleMarketingChanged,
                    onTermsViewPressed: _handleTermsView,
                    onPrivacyViewPressed: _handlePrivacyView,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: 'Sign Up',
                    onPressed: _canSignUp ? _handleSignUp : null,
                    size: ButtonSize.large,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SecondaryButton(
                    label: 'Back to Sign In',
                    onPressed: _handleBackToSignIn,
                    size: ButtonSize.large,
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
