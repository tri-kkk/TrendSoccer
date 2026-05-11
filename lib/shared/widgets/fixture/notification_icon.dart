import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({
    this.isOn = false,
    this.onTap,
    super.key,
  });

  final bool isOn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          isOn ? Icons.notifications : Icons.notifications_none,
          size: 24,
          color: isOn ? semantic.interactivePrimary : semantic.textTertiary,
        ),
      ),
    );
  }
}
