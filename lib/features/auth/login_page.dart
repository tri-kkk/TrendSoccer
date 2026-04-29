import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/tokens/color_tokens.dart';
import 'package:trendsoccer/core/theme/tokens/typography_tokens.dart';
import 'package:trendsoccer/shared/widgets/appbar/custom_appbar.dart';
import 'package:trendsoccer/shared/widgets/auth/login_symbol_widget.dart';
import 'package:trendsoccer/shared/widgets/auth/social_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: 'Login',
          centerTitle: true,
          showBackButton: true,
          onBackPressed: () {
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 380,
              height: 380,
              child: LoginSymbolWidget(
                platform: LoginPlatform.trendSoccer,
                width: 380,
                height: 380,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'TrendSoccer',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Read with Data Football Flow.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get Started with your social account.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SocialLoginButton(
              platform: LoginPlatform.google,
              onPressed: () {
                context.push('/signup/terms');
              },
            ),
            const SizedBox(height: 8),
            SocialLoginButton(
              platform: LoginPlatform.naver,
              onPressed: () {
                context.push('/signup/terms');
              },
            ),
          ],
        ),
      ),
    );
  }
}
