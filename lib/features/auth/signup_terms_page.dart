import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/features/menu/privacy_policy_page.dart';
import 'package:trendsoccer/features/menu/terms_of_service_page.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/loading/ts_loading_overlay.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class SignupTermsPage extends ConsumerStatefulWidget {
  const SignupTermsPage({super.key});

  @override
  ConsumerState<SignupTermsPage> createState() => _SignupTermsPageState();
}

class _SignupTermsPageState extends ConsumerState<SignupTermsPage> {
  bool _termsAgreed = false;
  bool _privacyAgreed = false;
  bool _marketingAgreed = false;
  bool _isLoading = false;

  bool get _agreeAll => _termsAgreed && _privacyAgreed && _marketingAgreed;
  bool get _canSubmit => _termsAgreed && _privacyAgreed;

  Future<void> _cancelSignupAndGoLogin() async {
    await ref.read(authProvider).signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _onSubmit() async {
    setState(() => _isLoading = true);
    final ok = await ref.read(authProvider).completeSignup(
          terms: _termsAgreed,
          privacy: _privacyAgreed,
          marketing: _marketingAgreed,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!ok) {
      TsToast.error(context, context.l10n.signupErrorProcessing);
    }
    context.push('/signup/complete');
  }

  void _toggleAgreeAll() {
    setState(() {
      if (_agreeAll) {
        _termsAgreed = false;
        _privacyAgreed = false;
        _marketingAgreed = false;
      } else {
        _termsAgreed = true;
        _privacyAgreed = true;
        _marketingAgreed = true;
      }
    });
  }

  Widget _checkIcon(bool checked, TsSemanticColors semantic) {
    return SvgPicture.asset(
      checked ? TsAssets.iconCheckboxChecked : TsAssets.iconCheckboxUnchecked,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        checked ? semantic.interactivePrimary : semantic.textDisabled,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _radioIcon(bool checked, TsSemanticColors semantic) {
    return SvgPicture.asset(
      checked ? TsAssets.iconRadioChecked : TsAssets.iconRadioUnchecked,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        checked ? semantic.interactivePrimary : semantic.textDisabled,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _requiredTag(BuildContext context) {
    return Text(
      context.l10n.signupRequired,
      style: TsType.labelSRegular.copyWith(color: TsColors.systemError500),
    );
  }

  Widget _optionalTag(BuildContext context, TsSemanticColors semantic) {
    return Text(
      context.l10n.signupOptional,
      style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
    );
  }

  Widget _termsRow({
    required BuildContext context,
    required TsSemanticColors semantic,
    required bool checked,
    required VoidCallback onToggle,
    required Widget tag,
    required String label,
    VoidCallback? onView,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: _checkIcon(checked, semantic),
        ),
        const SizedBox(width: 8),
        tag,
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Text(
              label,
              style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
            ),
          ),
        ),
        if (onView != null)
          GestureDetector(
            onTap: onView,
            behavior: HitTestBehavior.opaque,
            child: Text(
              context.l10n.signupView,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _cancelSignupAndGoLogin();
      },
      child: Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
          onPressed: _cancelSignupAndGoLogin,
        ),
        title: Text(
          l10n.signupPageTitle,
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        backgroundColor: semantic.surfaceBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: semantic.textPrimary),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: TsLoadingOverlay(
        isLoading: _isLoading,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 48,
              bottom: 48 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      TsAssets.logoSymbol(Theme.of(context).brightness),
                      width: 240,
                      height: 240,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.signupTermsHeadingLine1,
                      style: TsType.headingH2.copyWith(color: semantic.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.signupTermsHeadingLine2,
                      style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.signupTermsHint,
                      style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: semantic.surfaceRaised,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _toggleAgreeAll,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: semantic.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _radioIcon(_agreeAll, semantic),
                              const SizedBox(width: 8),
                              Text(
                                l10n.signupAgreeAll,
                                style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: semantic.borderSubtle),
                      const SizedBox(height: 16),
                      _termsRow(
                        context: context,
                        semantic: semantic,
                        checked: _termsAgreed,
                        onToggle: () => setState(() => _termsAgreed = !_termsAgreed),
                        tag: _requiredTag(context),
                        label: l10n.signupTermsRequired,
                        onView: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TermsOfServicePage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _termsRow(
                        context: context,
                        semantic: semantic,
                        checked: _privacyAgreed,
                        onToggle: () => setState(() => _privacyAgreed = !_privacyAgreed),
                        tag: _requiredTag(context),
                        label: l10n.signupPrivacyRequired,
                        onView: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _termsRow(
                        context: context,
                        semantic: semantic,
                        checked: _marketingAgreed,
                        onToggle: () => setState(() => _marketingAgreed = !_marketingAgreed),
                        tag: _optionalTag(context, semantic),
                        label: l10n.signupMarketingOptional,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TsButton(
                  label: l10n.signupSubmit,
                  variant: TsButtonVariant.primary,
                  onPressed: _canSubmit && !_isLoading ? _onSubmit : null,
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
