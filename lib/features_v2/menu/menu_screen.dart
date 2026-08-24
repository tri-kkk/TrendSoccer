import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              const Text('MenuScreen'),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('/login'),
              ),
              FilledButton(
                onPressed: () => context.go('/signup/terms'),
                child: const Text('/signup/terms'),
              ),
              FilledButton(
                onPressed: () => context.go('/signup/complete'),
                child: const Text('/signup/complete'),
              ),
              FilledButton(onPressed: () => context.go('/menu/notification-settings'), child: const Text('notification-settings')),
              FilledButton(onPressed: () => context.go('/menu/privacy'), child: const Text('privacy')),
              FilledButton(onPressed: () => context.go('/menu/terms'), child: const Text('terms')),
              FilledButton(onPressed: () => context.go('/menu/help'), child: const Text('help')),
            ],
          ),
        ),
      );
}
