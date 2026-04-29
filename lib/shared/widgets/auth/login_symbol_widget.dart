import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum LoginPlatform { google, naver, trendSoccer }

class LoginSymbolWidget extends StatelessWidget {
  final LoginPlatform platform;
  final double width;
  final double height;

  const LoginSymbolWidget({
    super.key,
    required this.platform,
    this.width = 24,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    String assetPath;

    switch (platform) {
      case LoginPlatform.google:
        assetPath = 'assets/images/login_symbols/google.svg';
        break;
      case LoginPlatform.naver:
        assetPath = 'assets/images/login_symbols/naver.svg';
        break;
      case LoginPlatform.trendSoccer:
        assetPath = 'assets/images/login_symbols/trendsoccer.svg';
        break;
    }

    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
    );
  }
}
