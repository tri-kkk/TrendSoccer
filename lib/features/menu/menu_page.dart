import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/subscription_state.dart';
import '../../core/models/user_state.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/subscription_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../core/theme/tokens/component_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../../shared/widgets/appbar/custom_appbar.dart';
import '../../shared/widgets/cards/profile_card.dart';
import '../../shared/widgets/menu/menu_list_item.dart';
import '../../shared/widgets/bottom_sheet/custom_bottom_sheet.dart';
import '../../shared/widgets/plan/plan_ticket.dart';
import '../../shared/widgets/radio/custom_radio.dart';
import '../../shared/widgets/toggle/custom_toggle.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: 'Menu',
          onBackPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildProfileSection(user),
            const SizedBox(height: 32),
            _buildPlanSection(subscription),
            const SizedBox(height: 32),
            _buildExploreSection(),
            const SizedBox(height: 32),
            _buildSettingsSection(context, ref),
            const SizedBox(height: 32),
            _buildOthersSection(),
            const SizedBox(height: 32),
            _buildAccountSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(UserState user) {
    if (user.authStatus == AuthStatus.loggedIn) {
      return ProfileCard(
        name: user.name ?? 'User',
        email: user.email ?? 'email@example.com',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get Full Access',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '48시간 무료 체험',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.surfaceBase,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Join Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSection(SubscriptionState subscription) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        PlanTicket(
          type: subscription.type,
          expiryDate: subscription.expiryDate,
          remainingTime: subscription.remainingTime,
          onSubscribePressed: () {
            // TODO: Navigate to Subscribe page
          },
        ),
      ],
    );
  }

  Widget _buildExploreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        MenuListItem(
          icon: Icons.casino,
          title: 'Combination',
          onTap: () {
            // TODO: Navigate to Combination page
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        MenuListItem(
          icon: Icons.language,
          title: 'Language',
          onTap: () => _showLanguageBottomSheet(context, ref),
        ),
        const SizedBox(height: 12),
        MenuListItem(
          icon: Icons.palette,
          title: 'Theme',
          onTap: () => _showThemeBottomSheet(context, ref),
        ),
        const SizedBox(height: 12),
        MenuListItem(
          icon: Icons.notifications,
          title: 'Notification',
          onTap: () => _showNotificationBottomSheet(context, ref),
        ),
      ],
    );
  }

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
    var selectedLanguage = ref.read(languageProvider);

    showCustomBottomSheet(
      context: context,
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.5,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Language',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _languageOption(
                label: '한국어',
                value: Language.korean,
                selected: selectedLanguage,
                onTap: () => setState(() => selectedLanguage = Language.korean),
              ),
              _languageOption(
                label: 'English',
                value: Language.english,
                selected: selectedLanguage,
                onTap: () =>
                    setState(() => selectedLanguage = Language.english),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(languageProvider.notifier).set(selectedLanguage);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: AppColors.surfaceBase,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _languageOption({
    required String label,
    required Language value,
    required Language selected,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selected;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CustomRadio(
        state: isSelected ? RadioState.checked : RadioState.unchecked,
        onChanged: (_) => onTap(),
      ),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context, WidgetRef ref) {
    var selectedTheme = ref.read(themeModeProvider);

    showCustomBottomSheet(
      context: context,
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.55,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _themeOption(
                label: 'Light',
                value: ThemeMode.light,
                selected: selectedTheme,
                onTap: () => setState(() => selectedTheme = ThemeMode.light),
              ),
              _themeOption(
                label: 'Dark',
                value: ThemeMode.dark,
                selected: selectedTheme,
                onTap: () => setState(() => selectedTheme = ThemeMode.dark),
              ),
              _themeOption(
                label: 'System',
                value: ThemeMode.system,
                selected: selectedTheme,
                onTap: () => setState(() => selectedTheme = ThemeMode.system),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).set(selectedTheme);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: AppColors.surfaceBase,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _themeOption({
    required String label,
    required ThemeMode value,
    required ThemeMode selected,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selected;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CustomRadio(
        state: isSelected ? RadioState.checked : RadioState.unchecked,
        onChanged: (_) => onTap(),
      ),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void _showNotificationBottomSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(notificationProvider);
    var general = current.general;
    var matchEvents = current.matchEvents;
    var breakingNews = current.breakingNews;

    showCustomBottomSheet(
      context: context,
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.55,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _notificationRow(
                label: 'General Notifications',
                value: general,
                onChanged: (v) => setState(() => general = v),
              ),
              const SizedBox(height: 12),
              _notificationRow(
                label: 'Match Events',
                value: matchEvents,
                onChanged: (v) => setState(() => matchEvents = v),
              ),
              const SizedBox(height: 12),
              _notificationRow(
                label: 'Breaking News',
                value: breakingNews,
                onChanged: (v) => setState(() => breakingNews = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(notificationProvider.notifier).toggle(
                          general: general,
                          matchEvents: matchEvents,
                          breakingNews: breakingNews,
                        );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: AppColors.surfaceBase,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _notificationRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        CustomToggle(
          state: value ? ToggleState.on : ToggleState.off,
          onChanged: (toggleState) =>
              onChanged(toggleState == ToggleState.on),
        ),
      ],
    );
  }

  Widget _buildOthersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Others',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        MenuListItem(
          icon: Icons.info_outline,
          title: 'About',
          onTap: () {
            // TODO: Navigate to About page
          },
        ),
        const SizedBox(height: 12),
        MenuListItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () {
            // TODO: Navigate to Privacy Policy page
          },
        ),
        const SizedBox(height: 12),
        MenuListItem(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          onTap: () {
            // TODO: Navigate to Terms page
          },
        ),
        const SizedBox(height: 12),
        MenuListItem(
          icon: Icons.help_outline,
          title: 'Help Center',
          onTap: () {
            // TODO: Navigate to Help page
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.smartphone,
                size: 24,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 16),
              Text(
                'App Version',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '1.0.0',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _showSignOutDialog(context, ref),
          child: Text(
            'Sign Out',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          height: 16,
          width: 1,
          color: AppColors.textTertiary,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        TextButton(
          onPressed: () => _showDeleteAccountDialog(context, ref),
          child: Text(
            'Delete Account',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceOverlay,
          title: Text(
            'Sign Out',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(userProvider.notifier).logout();
                Navigator.pop(context);
              },
              child: Text(
                'Sign Out',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    var confirmText = '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final canDelete = confirmText == 'DELETE';

            return AlertDialog(
              backgroundColor: AppColors.surfaceOverlay,
              title: Text(
                'Delete Account',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you certain you wish to delete your account? This cannot be undone.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Type 'DELETE' to confirm:",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) {
                      setState(() => confirmText = value);
                    },
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'DELETE',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.textTertiary,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.primary500,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: canDelete
                      ? () {
                          ref.read(userProvider.notifier).logout();
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account deleted'),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    'Delete Account',
                    style: AppTypography.labelLarge.copyWith(
                      color: canDelete
                          ? AppColors.errorRed500
                          : AppColors.textDisabled,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

}
