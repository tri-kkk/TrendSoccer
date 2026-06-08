import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/loading/ts_loading_overlay.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  late final AnimationController _controller;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<double> _buttonFadeAnimation;
  late final Animation<Offset> _sheetSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _titleFadeAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);
    _buttonFadeAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);
    _sheetSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isSheetShowing => _controller.value > 0;

  void _handleBack() {
    if (_isSheetShowing) {
      _controller.reverse();
    } else {
      context.go('/trend');
    }
  }

  void _onStartTap() {
    if (_isLoading) return;
    _controller.forward();
  }

  Future<void> _onNaverLoginTap() async {
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(authProvider).loginWithNaver();
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['cancelled'] == true) return;

      if (result['isNewUser'] == true || result['requiresConsent'] == true) {
        context.go('/signup/terms');
      } else {
        context.go('/trend');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      TsToast.error(context, resolveApiError(context, e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      TsToast.error(context, resolveApiError(context, e));
    }
  }

  Future<void> _onGoogleLoginTap() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider).loginWithGoogle();
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!ref.read(authProvider).isLoggedIn) return;

      await ref.read(authProvider).loadProfile();
      if (!mounted) return;

      final auth = ref.read(authProvider);
      if (auth.needsConsent) {
        context.push('/signup/terms');
      } else {
        TsToast.success(context, context.l10n.loginSuccess);
        context.go('/trend');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      TsToast.error(context, resolveApiError(context, e));
    }
  }

  Widget _buildHeroTitle(TsSemanticColors semantic, List<String> titleLines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < titleLines.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          Text(
            titleLines[i],
            style: TsType.displayHero.copyWith(color: semantic.textPrimary),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required TsSemanticColors semantic,
    required String iconAsset,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: semantic.surfaceContainer,
          border: Border.all(color: semantic.borderDefault),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconAsset, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginSheet(TsSemanticColors semantic) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceOverlay,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: semantic.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.loginSheetTitle,
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.loginSheetDesc,
              style: TsType.bodyLBold.copyWith(color: semantic.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          _buildSocialLoginButton(
            semantic: semantic,
            iconAsset: TsAssets.socialGoogle,
            label: l10n.loginGoogle,
            onTap: _isLoading ? null : _onGoogleLoginTap,
          ),
          const SizedBox(height: 12),
          _buildSocialLoginButton(
            semantic: semantic,
            iconAsset: TsAssets.socialNaver,
            label: l10n.loginNaver,
            onTap: _isLoading ? null : _onNaverLoginTap,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final titleLines = l10n.loginTitle.split('\n');
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: semantic.surfaceBase,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
            onPressed: _handleBack,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: semantic.textPrimary),
          title: Text(
            l10n.loginAppBarTitle,
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          centerTitle: true,
        ),
        body: TsLoadingOverlay(
          isLoading: _isLoading,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: SvgPicture.asset(
                    TsAssets.bgLoginStadium,
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    colorFilter: ColorFilter.mode(
                      semantic.textPrimary.withValues(alpha: 0.12),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SlideTransition(
                            position: _titleSlideAnimation,
                            child: FadeTransition(
                              opacity: _titleFadeAnimation,
                              child: _buildHeroTitle(semantic, titleLines),
                            ),
                          ),
                          const SizedBox(height: 48),
                          FadeTransition(
                            opacity: _buttonFadeAnimation,
                            child: TsButton(
                              label: l10n.loginStart,
                              onPressed: _isLoading ? null : _onStartTap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: _sheetSlideAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: _buildLoginSheet(semantic),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
