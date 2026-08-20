import 'package:flutter/material.dart';

class PreviewDetailScreen extends StatelessWidget {
  const PreviewDetailScreen({required this.slug, super.key});
  final String slug;
  @override
  Widget build(BuildContext c) => Scaffold(body: Center(child: Text('PreviewDetailScreen\nslug=$slug', textAlign: TextAlign.center)));
}
