import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// The sport types available in the toggle.
enum SportType { soccer, baseball }

/// A segmented toggle that lets the user switch between [SportType.soccer]
/// and [SportType.baseball].
///
/// Fixed size: 380 × 48. Wrap in a scroll view or constrained box if the
/// parent is narrower than 380 px.
///
/// ```dart
/// SportToggle(
///   selectedSport: SportType.soccer,
///   onSportChanged: (sport) => setState(() => _sport = sport),
/// )
/// ```
class SportToggle extends StatelessWidget {
  const SportToggle({
    super.key,
    required this.selectedSport,
    required this.onSportChanged,
  });

  /// The currently active sport.
  final SportType selectedSport;

  /// Called with the newly selected [SportType] when the user taps a button.
  final void Function(SportType) onSportChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          _SportButton(
            emoji: '⚽',
            label: 'Soccer',
            isSelected: selectedSport == SportType.soccer,
            onTap: () => onSportChanged(SportType.soccer),
          ),
          const SizedBox(width: AppSpacing.sm),
          _SportButton(
            emoji: '⚾',
            label: 'Baseball',
            isSelected: selectedSport == SportType.baseball,
            onTap: () => onSportChanged(SportType.baseball),
          ),
        ],
      ),
    );
  }
}

/// Internal pill button used inside [SportToggle].
class _SportButton extends StatelessWidget {
  const _SportButton({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        isSelected ? AppColors.surfaceBase : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary500 : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: 20,
                  color: foreground,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
