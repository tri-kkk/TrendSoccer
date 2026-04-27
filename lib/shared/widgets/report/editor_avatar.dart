import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Circle editor mark (TrendSoccer) — 40×40.
class EditorAvatar extends StatelessWidget {
  const EditorAvatar({super.key});

  static const String _asset = 'assets/images/logos/logo_circle_editor.svg';

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: SvgPicture.asset(
        _asset,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }
}
