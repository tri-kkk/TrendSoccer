import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'main_screen.dart';

void main() {
  runApp(const ProviderScope(child: TrendSoccerApp()));
}

class TrendSoccerApp extends StatelessWidget {
  const TrendSoccerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrendSoccer',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
