import 'package:flutter/material.dart';

class MatchReportScreen extends StatelessWidget {
  const MatchReportScreen({required this.sport, required this.matchId, super.key});
  final String sport;
  final String matchId;
  @override
  Widget build(BuildContext c) => Scaffold(body: Center(child: Text('MatchReportScreen\nsport=$sport\nmatchId=$matchId', textAlign: TextAlign.center)));
}
