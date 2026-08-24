import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/providers/theme_provider.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_confirm_dialog.dart';
import 'package:trendsoccer/design_system/widgets/ts_guest_banner.dart';
import 'package:trendsoccer/design_system/widgets/ts_menu_list_item.dart';
import 'package:trendsoccer/design_system/widgets/ts_plan_ticket.dart';
import 'package:trendsoccer/design_system/widgets/ts_profile_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_toast.dart';
import 'package:trendsoccer/features_v2/menu/settings_sheets.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  static const _playPackageId = 'com.trendsoccer.app';

  String _appVersion = '-';
  final _deleteConfirmController = TextEditingController();
  bool _deleteDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  @override
  void dispose() {
    _deleteConfirmController.dispose();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = 'v${info.version}';
    });
  }

  void _showToast(String message, TsToastType type) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        content: TsToast(message: message, type: type),
      ),
    );
  }

  Future<void> _showSignOutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 320,
          child: TsConfirmDialog(
            type: TsDialogType.destructive,
            title: 'Sign out?',
            message: 'You can sign back in anytime.',
            confirmLabel: 'Sign out',
            cancelLabel: 'Cancel',
            onConfirm: () => Navigator.of(dialogContext).pop(true),
            onCancel: () => Navigator.of(dialogContext).pop(false),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(authProvider).signOut();
      if (!mounted) return;
      _showToast('Signed out successfully.', TsToastType.success);
      context.go('/home');
    } catch (_) {
      if (!mounted) return;
      _showToast('Unable to sign out. Please try again.', TsToastType.error);
    }
  }

  Future<void> _openPlaySubscriptions() async {
    final uri = Uri.parse(
      'https://play.google.com/store/account/subscriptions?package=$_playPackageId',
    );
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showToast(
          'Unable to open Google Play subscriptions.',
          TsToastType.error,
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showToast(
        'Unable to open Google Play subscriptions.',
        TsToastType.error,
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    if (_deleteDialogOpen) return;
    _deleteDialogOpen = true;
    _deleteConfirmController.clear();

    bool? confirmed;
    try {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: _deleteConfirmController,
            builder: (context, value, _) {
              final canConfirm = value.text.trim() == 'DELETE';

              return Dialog(
                backgroundColor: Colors.transparent,
                child: SizedBox(
                  width: 320,
                  child: TsConfirmDialog(
                    type: TsDialogType.input,
                    title: 'Delete account?',
                    message:
                        'All data is permanently removed. Type DELETE to confirm.',
                    inputLabel: 'Confirmation',
                    controller: _deleteConfirmController,
                    confirmLabel: 'Delete',
                    cancelLabel: 'Cancel',
                    onConfirm: canConfirm
                        ? () => Navigator.of(dialogContext).pop(true)
                        : null,
                    onCancel: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      _deleteDialogOpen = false;
    }

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(authProvider).deleteAccount();
      if (!mounted) return;
      _showToast('Account deleted successfully.', TsToastType.success);
      context.go('/home');
    } catch (_) {
      if (!mounted) return;
      _showToast('Unable to delete account. Please try again.', TsToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final auth = ref.watch(authProvider);
    final language = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isGuest = auth.planType == PlanType.none;

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: isGuest ? TsAppBarType.homeGuest : TsAppBarType.homeMember,
        authLabel: 'Log in',
        onAuthTap: isGuest ? () => context.go('/login') : null,
        tierLabel: _tierLabel(auth.planType),
        onAvatarTap: null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          TsSpacing.lg,
          TsSpacing.lg,
          TsSpacing.lg,
          TsSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isGuest) ...[
              TsGuestBanner(
                title: 'Start your 48-hour free trial',
                subtitle: 'Sign up to unlock full analysis reports.',
                actionLabel: 'Sign up',
                onAction: () => context.go('/login'),
              ),
              const SizedBox(height: TsSpacing.lg),
              _menuGroup(
                c,
                [
                  TsMenuListItem(
                    label: 'Notifications',
                    icon: TsIcons.notificationsNone,
                    onTap: () => context.go('/menu/notification-settings'),
                  ),
                  TsMenuListItem(
                    label: 'Language',
                    icon: TsIcons.language,
                    value: _languageLabel(language),
                    onTap: () => showLanguageSheet(context),
                  ),
                  TsMenuListItem(
                    label: 'Theme',
                    icon: TsIcons.theme,
                    value: _themeLabel(themeMode),
                    onTap: () => showThemeSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              _menuGroup(
                c,
                [
                  TsMenuListItem(
                    label: 'Help',
                    icon: TsIcons.help,
                    onTap: () => context.go('/menu/help'),
                  ),
                  TsMenuListItem(
                    label: 'Privacy policy',
                    icon: TsIcons.privacyTip,
                    onTap: () => context.go('/menu/privacy'),
                  ),
                  TsMenuListItem(
                    label: 'Terms of service',
                    icon: TsIcons.article,
                    onTap: () => context.go('/menu/terms'),
                  ),
                  TsMenuListItem(
                    label: 'App version',
                    icon: TsIcons.versionInfo,
                    value: _appVersion,
                  ),
                ],
              ),
            ] else ...[
              TsProfileCard(
                name: auth.userName,
                email: auth.userEmail,
              ),
              const SizedBox(height: TsSpacing.lg),
              TsPlanTicket(
                plan: _tsPlan(auth.planType),
                subLabel: _planSubLabel(auth),
                onAction: auth.planType == PlanType.trial
                    ? null
                    : auth.planType == PlanType.premium
                        ? _openPlaySubscriptions
                        : () => context.go('/menu/subscribe'),
              ),
              const SizedBox(height: TsSpacing.lg),
              _menuGroup(
                c,
                [
                  TsMenuListItem(
                    label: 'Subscription',
                    icon: TsIcons.premium,
                    onTap: auth.planType == PlanType.premium
                        ? _openPlaySubscriptions
                        : () => context.go('/menu/subscribe'),
                  ),
                  TsMenuListItem(
                    label: 'Notifications',
                    icon: TsIcons.notificationsNone,
                    onTap: () => context.go('/menu/notification-settings'),
                  ),
                  TsMenuListItem(
                    label: 'Language',
                    icon: TsIcons.language,
                    value: _languageLabel(language),
                    onTap: () => showLanguageSheet(context),
                  ),
                  TsMenuListItem(
                    label: 'Theme',
                    icon: TsIcons.theme,
                    value: _themeLabel(themeMode),
                    onTap: () => showThemeSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              _menuGroup(
                c,
                [
                  TsMenuListItem(
                    label: 'Help',
                    icon: TsIcons.help,
                    onTap: () => context.go('/menu/help'),
                  ),
                  TsMenuListItem(
                    label: 'Privacy policy',
                    icon: TsIcons.privacyTip,
                    onTap: () => context.go('/menu/privacy'),
                  ),
                  TsMenuListItem(
                    label: 'Terms of service',
                    icon: TsIcons.article,
                    onTap: () => context.go('/menu/terms'),
                  ),
                  TsMenuListItem(
                    label: 'App version',
                    icon: TsIcons.versionInfo,
                    value: _appVersion,
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              _menuGroup(
                c,
                [
                  TsMenuListItem(
                    label: 'Sign out',
                    icon: TsIcons.logout,
                    onTap: _showSignOutDialog,
                  ),
                  TsMenuListItem(
                    label: 'Delete account',
                    icon: TsIcons.delete,
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuGroup(TsThemeColors c, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: items),
    );
  }

  String _tierLabel(PlanType planType) => switch (planType) {
        PlanType.free => 'FREE',
        PlanType.trial => 'TRIAL',
        PlanType.premium => 'PREMIUM',
        PlanType.none => 'FREE',
      };

  TsPlan _tsPlan(PlanType planType) => switch (planType) {
        PlanType.free => TsPlan.free,
        PlanType.trial => TsPlan.trial,
        PlanType.premium => TsPlan.premium,
        PlanType.none => TsPlan.free,
      };

  String _planSubLabel(SupabaseAuthProvider auth) => switch (auth.planType) {
        PlanType.free => 'Basic analysis only',
        PlanType.trial =>
          'Trial ends in ${_trialHoursRemaining(auth)} hours · billing unavailable during trial',
        PlanType.premium => _premiumRenewalLabel(auth),
        PlanType.none => 'Basic analysis only',
      };

  int _trialHoursRemaining(SupabaseAuthProvider auth) {
    final expiry = auth.trialExpiryAt;
    if (expiry == null) return 0;
    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative) return 0;
    return (remaining.inMinutes / 60).ceil().clamp(1, 9999);
  }

  String _premiumRenewalLabel(SupabaseAuthProvider auth) {
    final subscription = auth.subscriptionInfo;
    final expiry = subscription?.expiresAt ?? auth.premiumExpiresAt;
    final isCancellationPending =
        subscription?.isCancellationPending ?? false;

    if (isCancellationPending) {
      if (expiry != null) {
        return 'Cancellation pending · access until ${_formatPlanDate(expiry)}';
      }
      return 'Cancellation pending';
    }

    if (expiry != null) {
      return 'Renews on ${_formatPlanDate(expiry)}';
    }
    return 'Premium active';
  }

  String _formatPlanDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}.$month.$day';
  }

  String _languageLabel(AppLanguage language) => switch (language) {
        AppLanguage.en => 'English',
        AppLanguage.ko => '한국어',
      };

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };
}
