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
            const SizedBox(height: 24),
            _buildTestControls(ref),
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

  Widget _buildTestControls(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEST Controls',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ref.read(userProvider.notifier).logout();
            },
            child: const Text('Switch to Guest'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ref.read(userProvider.notifier).login(
                    name: 'Son Heung-min',
                    email: 'son@spurs.com',
                  );
            },
            child: const Text('Switch to Logged In'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ref.read(subscriptionProvider.notifier).reset();
            },
            child: const Text('Set Free Plan'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ref.read(subscriptionProvider.notifier).activate(
                    SubscriptionType.trial,
                    remainingTime: const Duration(hours: 36),
                  );
            },
            child: const Text('Set Trial (36h)'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ref.read(subscriptionProvider.notifier).activate(
                    SubscriptionType.premium,
                    expiryDate: DateTime.now().add(const Duration(days: 30)),
                  );
            },
            child: const Text('Set Premium (30 days)'),
          ),
        ),
      ],
    );
  }
}
