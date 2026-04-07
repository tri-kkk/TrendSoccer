import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TrendSoccerApp(),
    ),
  );
}

class TrendSoccerApp extends StatelessWidget {
  const TrendSoccerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrendSoccer',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: Color(0xFF121212), // 임시 다크 배경
        body: Center(
          child: Text(
            'TrendSoccer - Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}