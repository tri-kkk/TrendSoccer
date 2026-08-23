import 'package:flutter/material.dart';

enum ForceUpdateReason { maintenance, update }

class ForceUpdateArgs {
  const ForceUpdateArgs({required this.reason, this.message});

  final ForceUpdateReason reason;
  final String? message;
}

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({this.args, super.key});

  final ForceUpdateArgs? args;

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('ForceUpdateScreen')));
}
