import 'package:flutter/material.dart';

class ComboDetailScreen extends StatelessWidget {
  const ComboDetailScreen({required this.comboId, super.key});
  final String comboId;
  @override
  Widget build(BuildContext c) => Scaffold(body: Center(child: Text('ComboDetailScreen\ncomboId=$comboId', textAlign: TextAlign.center)));
}
