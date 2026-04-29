import 'package:flutter/material.dart';
import 'package:trendsoccer/core/theme/tokens/color_tokens.dart';
import 'package:trendsoccer/core/theme/tokens/typography_tokens.dart';
import 'package:trendsoccer/shared/widgets/auth/login_symbol_widget.dart';

class SocialLoginButton extends StatelessWidget {
  final LoginPlatform platform;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.platform,
    required this.onPressed,
  });

  String get buttonText {
    switch (platform) {
      case LoginPlatform.google:
        return 'Continue with Google';
      case LoginPlatform.naver:
        return 'Continue with Naver';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F1F1F),
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            LoginSymbolWidget(platform: platform),
            const SizedBox(width: 16),
            Text(
              buttonText,
              style: AppTypography.enLabelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
