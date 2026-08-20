import 'package:flutter/material.dart';
import 'package:trendsoccer/features_v2/router/app_router.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: appRouter);
}
