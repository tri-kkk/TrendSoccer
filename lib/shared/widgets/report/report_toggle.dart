import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

class ReportToggle extends StatefulWidget {
  const ReportToggle({
    super.key,
    required this.isStandardSelected,
    required this.onStandardTap,
    required this.onPremiumTap,
  });

  final bool isStandardSelected;
  final VoidCallback onStandardTap;
  final VoidCallback onPremiumTap;

  @override
  State<ReportToggle> createState() => _ReportToggleState();
}

class _ReportToggleState extends State<ReportToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.isStandardSelected ? 0.0 : 1.0,
    );
    _slide = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(ReportToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStandardSelected != widget.isStandardSelected) {
      if (widget.isStandardSelected) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _slide.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to compute pill position from actual rendered width.
    return LayoutBuilder(
      builder: (context, constraints) {
        final innerWidth = (constraints.maxWidth - 8).clamp(
          0.0,
          double.infinity,
        );
        // Two equal buttons separated by a 4px gap.
        final pillWidth = (innerWidth - 4) / 2;
        final maxSlide = pillWidth + 4;

        if (maxSlide <= 0 || pillWidth <= 0) {
          return const SizedBox(height: 48);
        }

        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sliding pill — explicit controller + Positioned is symmetric
              // (0 = Standard, 1 = Premium); avoids one-way padding animation glitches.
              ListenableBuilder(
                listenable: _slide,
                builder: (context, child) {
                  return Positioned(
                    left: _slide.value * maxSlide,
                    top: 0,
                    child: child!,
                  );
                },
                child: SizedBox(
                  width: pillWidth,
                  height: 40,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              // Labels — above the pill for tap handling
              Row(
                children: [
                  _TabLabel(
                    label: 'Standard',
                    isSelected: widget.isStandardSelected,
                    onTap: widget.onStandardTap,
                  ),
                  const SizedBox(width: 4),
                  _TabLabel(
                    label: 'Premium',
                    isSelected: !widget.isStandardSelected,
                    onTap: widget.onPremiumTap,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 40,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.labelLarge.copyWith(
                color: isSelected
                    ? AppColors.surfaceBase
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
