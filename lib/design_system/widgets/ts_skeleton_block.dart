import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';

enum TsSkeletonType { line, title, block, circle }

class TsSkeletonBlock extends StatefulWidget {
  const TsSkeletonBlock(this.type, {this.width, super.key});

  final TsSkeletonType type;
  final double? width;

  @override
  State<TsSkeletonBlock> createState() => _TsSkeletonBlockState();
}

class _TsSkeletonBlockState extends State<TsSkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final double width;
    final double height;
    final BorderRadius borderRadius;

    switch (widget.type) {
      case TsSkeletonType.line:
        width = widget.width ?? double.infinity;
        height = 14;
        borderRadius = TsRadius.xs;
      case TsSkeletonType.title:
        width = widget.width ?? double.infinity;
        height = 20;
        borderRadius = TsRadius.xs;
      case TsSkeletonType.block:
        width = widget.width ?? double.infinity;
        height = 80;
        borderRadius = TsRadius.sm;
      case TsSkeletonType.circle:
        width = 40;
        height = 40;
        borderRadius = TsRadius.full;
    }

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
