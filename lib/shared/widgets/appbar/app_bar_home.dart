import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../buttons/primary_button.dart';

/// Whether the user is authenticated.
enum AppBarState {
  /// Not signed in — shows a "Sign In" CTA.
  guest,

  /// Signed in — shows a notification bell icon.
  loggedIn,
}

/// Home screen app bar that adapts to the user's authentication state.
///
/// - [AppBarState.guest]: Logo + small "Sign In" button.
/// - [AppBarState.loggedIn]: Logo + notification icon.
///
/// Layout follows Figma node `651:49324`.
///
/// ```dart
/// AppBarHome(
///   state: AppBarState.guest,
///   onSignIn: () {},
/// )
/// ```
class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHome({
    super.key,
    required this.state,
    this.onSignIn,
    this.onNotification,
  });

  /// Current authentication state.
  final AppBarState state;

  /// Called when the "Sign In" button is pressed (guest mode).
  final VoidCallback? onSignIn;

  /// Called when the notification icon is pressed (logged-in mode).
  final VoidCallback? onNotification;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.surfaceBase,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            'assets/images/logos/logo_horizon_gradient.svg',
            height: 32,
            fit: BoxFit.contain,
          ),
          _buildTrailing(),
        ],
      ),
    );
  }

  Widget _buildTrailing() {
    return switch (state) {
      AppBarState.guest => PrimaryButton(
          label: 'Sign In',
          size: ButtonSize.small,
          onPressed: onSignIn,
        ),
      AppBarState.loggedIn => GestureDetector(
          onTap: onNotification,
          child: const Icon(
            Icons.notifications_outlined,
            size: AppSpacing.iconSize,
            color: AppColors.textPrimary,
          ),
        ),
    };
  }
}
