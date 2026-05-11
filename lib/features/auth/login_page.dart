import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/logo/ts_logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = isDark ? TsLogoColor.white : TsLogoColor.black;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: const TsAppBar(
        location: TsAppBarLocation.backTitle,
        title: '로그인',
      ),
      body: Padding(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TsLogo(type: TsLogoType.vertical, color: logoColor),
            const SizedBox(height: TsSpacing.sm),
            Text(
              'TrendSoccer',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: semantic.textPrimary,
              ),
            ),
            const SizedBox(height: TsSpacing.xxxl),
            _SocialLoginButton(
              leading: Icon(Icons.g_mobiledata, size: 24, color: Colors.black87),
              label: 'Google로 계속하기',
              backgroundColor: Colors.white,
              labelColor: Colors.black87,
              onTap: () => context.push('/signup/terms'),
            ),
            const SizedBox(height: TsSpacing.md),
            _SocialLoginButton(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              label: 'Naver로 계속하기',
              backgroundColor: const Color(0xFF03C75A),
              labelColor: Colors.white,
              onTap: () => context.push('/signup/terms'),
            ),
            const SizedBox(height: TsSpacing.xl),
            GestureDetector(
              onTap: () => context.go('/trend'),
              behavior: HitTestBehavior.opaque,
              child: Text(
                '비회원으로 둘러보기',
                style: TsType.bodyLRegular.copyWith(
                  color: semantic.textTertiary,
                  decoration: TextDecoration.underline,
                  decorationColor: semantic.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.leading,
    required this.label,
    required this.backgroundColor,
    required this.labelColor,
    required this.onTap,
  });

  final Widget leading;
  final String label;
  final Color backgroundColor;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24, height: 24, child: Center(child: leading)),
            const SizedBox(width: TsSpacing.md),
            Text(
              label,
              style: TsType.bodyLBold.copyWith(color: labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
