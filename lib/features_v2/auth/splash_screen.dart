import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              const Text('SplashScreen'),
              FilledButton(onPressed: () => context.go('/home'), child: const Text('Enter shell')),
              FilledButton(onPressed: () => context.go('/reports'), child: const Text('redirect /reports')),
              FilledButton(onPressed: () => context.go('/feed/'), child: const Text('redirect /feed/')),
              FilledButton(onPressed: () => context.go('/matches/soccer/12345'), child: const Text('deep link')),
            ],
          ),
        ),
      );
}
