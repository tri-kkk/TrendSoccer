import 'package:flutter/material.dart';

import 'custom_badge.dart';

/// Pick-grade badge for analysis. [type] is `PICK`, `GOOD`, or `PASS` (case-insensitive).
class Badge extends StatelessWidget {
  const Badge({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final normalized = type.trim().toUpperCase();
    final badgeType = switch (normalized) {
      'GOOD' => BadgeType.good,
      'PASS' => BadgeType.pass,
      _ => BadgeType.pick,
    };
    final label = switch (normalized) {
      'GOOD' => 'GOOD',
      'PASS' => 'PASS',
      'PICK' => 'PICK',
      _ => type.trim().isNotEmpty ? type.trim() : 'PICK',
    };
    return CustomBadge(type: badgeType, label: label);
  }
}
