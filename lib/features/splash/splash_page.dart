import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/tokens/color_tokens.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/trend');  // Changed from '/login' to '/trend'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: Stack(
        children: [
          // Logo centered
          Center(
            child: SizedBox(
              height: 200,
              child: SvgPicture.asset(
                'assets/images/logos/logo_vertical_gradient.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.brandPrimary500,
                  ),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
