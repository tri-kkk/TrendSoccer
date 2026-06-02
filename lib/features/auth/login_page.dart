import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/loading/ts_loading_overlay.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;

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
      if (e.code == 'ACCOUNT_DELETED') {
        TsToast.error(context, e.message);
      } else {
        TsToast.error(context, context.l10n.loginNaverFailed);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      TsToast.error(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final titleLines = l10n.loginTitle.split('\n');
    final subtitleLines = l10n.loginSubtitle.split('\n');

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
          onPressed: () => context.go('/trend'),
        ),
        backgroundColor: semantic.surfaceBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: semantic.textPrimary),
        title: Text(
          l10n.loginAppBarTitle,
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
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
                SvgPicture.asset(
                  TsAssets.logoSymbol(Theme.of(context).brightness),
                  width: 240,
                  height: 240,
                ),
                const SizedBox(height: 48),
                for (var i = 0; i < titleLines.length; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  Text(
                    titleLines[i],
                    style: TsType.displayHero.copyWith(color: semantic.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                for (var i = 0; i < subtitleLines.length; i++)
                  Text(
                    subtitleLines[i],
                    style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: _isLoading ? null : _onGoogleLoginTap,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: semantic.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          TsAssets.socialGoogle,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.loginGoogle,
                          style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _isLoading ? null : _onNaverLoginTap,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: semantic.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          TsAssets.socialNaver,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.loginNaver,
                          style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
