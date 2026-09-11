import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/providers/theme_provider.dart';
import 'package:trendsoccer/core/utils/notification_permission_gate.dart';
import 'package:trendsoccer/core/utils/plan_tier_label.dart';
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
import 'package:trendsoccer/l10n/app_localizations.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  static const _playPackageId = 'com.trendsoccer.app';
  static const _deleteConfirmToken = 'DELETE';

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
    showTsToast(context, message, type);
  }

  Future<void> _openNotificationSettings() async {
    if (!await ensureNotificationPermissionGate(context)) return;
    if (!mounted) return;
    context.go('/menu/notification-settings');
  }

  Future<void> _showSignOutDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 320,
          child: TsConfirmDialog(
            type: TsDialogType.destructive,
            title: l10n.menuSignOutDialogTitle,
            message: l10n.menuSignOutDialogMessage,
            confirmLabel: l10n.menuSignOut,
            cancelLabel: l10n.cancel,
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
      _showToast(l10n.signOutSuccess, TsToastType.success);
      context.go('/home');
    } catch (_) {
      if (!mounted) return;
      _showToast(l10n.menuSignOutErrorToast, TsToastType.error);
    }
  }

  Future<void> _openPlaySubscriptions() async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(
      'https://play.google.com/store/account/subscriptions?package=$_playPackageId',
    );
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showToast(l10n.menuPlaySubscriptionsErrorToast, TsToastType.error);
      }
    } catch (_) {
      if (!mounted) return;
      _showToast(l10n.menuPlaySubscriptionsErrorToast, TsToastType.error);
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    if (_deleteDialogOpen) return;
    _deleteDialogOpen = true;
    _deleteConfirmController.clear();
    final l10n = AppLocalizations.of(context)!;

    bool? confirmed;
    try {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: _deleteConfirmController,
            builder: (context, value, _) {
              final canConfirm =
                  value.text.trim() == _deleteConfirmToken;

              return Dialog(
                backgroundColor: Colors.transparent,
                child: SizedBox(
                  width: 320,
                  child: TsConfirmDialog(
                    type: TsDialogType.input,
                    title: l10n.menuDeleteAccountDialogTitle,
                    message: l10n.menuDeleteAccountDialogMessage,
                    inputLabel: l10n.menuDeleteAccountInputLabel,
                    controller: _deleteConfirmController,
                    confirmLabel: l10n.deleteAccountConfirm,
                    cancelLabel: l10n.cancel,
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
      _showToast(l10n.menuDeleteAccountSuccessToast, TsToastType.success);
      context.go('/home');
    } catch (_) {
      if (!mounted) return;
      _showToast(l10n.menuDeleteAccountErrorToast, TsToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final language = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isGuest = auth.planType == PlanType.none;

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: isGuest ? TsAppBarType.homeGuest : TsAppBarType.homeMember,
        onAuthTap: isGuest ? () => context.push('/login') : null,
        tierLabel: PlanTierLabel.forPlanType(auth.planType, l10n),
        tierTone: PlanTierTone.forPlanType(auth.planType),
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
                title: l10n.menuGuestBannerTitle,
                subtitle: l10n.menuGuestBannerSubtitle,
                actionLabel: l10n.signupPageTitle,
                onAction: () => context.push('/login'),
              ),
              const SizedBox(height: TsSpacing.lg),
              _menuGroup(
                c,
                [
                  TsMenuListItem(
                    label: l10n.menuNotifications,
                    icon: TsIcons.notificationsNone,
                    onTap: _openNotificationSettings,
                  ),
                  TsMenuListItem(
                    label: l10n.menuLanguage,
                    icon: TsIcons.language,
                    value: _languageLabel(l10n, language),
                    onTap: () => showLanguageSheet(context),
                  ),
                  TsMenuListItem(
                    label: l10n.menuTheme,
                    icon: TsIcons.theme,
                    value: _themeLabel(l10n, themeMode),
                    onTap: () => showThemeSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              _menuGroup(
                c,
                [
                  TsMenuListItem(
                    label: l10n.menuHelp,
                    icon: TsIcons.help,
                    onTap: () => context.go('/menu/help'),
                  ),
                  TsMenuListItem(
                    label: l10n.menuPrivacyPolicy,
                    icon: TsIcons.privacyTip,
                    onTap: () => context.go('/menu/privacy'),
                  ),
                  TsMenuListItem(
                    label: l10n.menuTermsOfService,
                    icon: TsIcons.article,
                    onTap: () => context.go('/menu/terms'),
                  ),
                  TsMenuListItem(
                    label: l10n.menuAppVersion,
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
                subLabel: _planSubLabel(l10n, auth),
                onAction: auth.planType == PlanType.trial
                    ? null
                    : auth.planType == PlanType.premium
                        ? _openPlaySubscriptions
                        : () => context.push('/menu/subscribe'),
              ),
              const SizedBox(height: TsSpacing.lg),
              _menuGroup(
                c,
                [
                  TsMenuListItem(
                    label: l10n.menuSubscribeInfoSection,
                    icon: TsIcons.premium,
                    onTap: auth.planType == PlanType.premium
                        ? _openPlaySubscriptions
                        : () => context.push('/menu/subscribe'),
                  ),
                  TsMenuListItem(
                    label: l10n.menuNotifications,
                    icon: TsIcons.notificationsNone,
                    onTap: _openNotificationSettings,
                  ),
                  TsMenuListItem(
                    label: l10n.menuLanguage,
                    icon: TsIcons.language,
                    value: _languageLabel(l10n, language),
                    onTap: () => showLanguageSheet(context),
                  ),
                  TsMenuListItem(
                    label: l10n.menuTheme,
                    icon: TsIcons.theme,
                    value: _themeLabel(l10n, themeMode),
                    onTap: () => showThemeSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              _menuGroup(
                c,
                [
                  TsMenuListItem(
                    label: l10n.menuHelp,
                    icon: TsIcons.help,
                    onTap: () => context.go('/menu/help'),
                  ),
                  TsMenuListItem(
                    label: l10n.menuPrivacyPolicy,
                    icon: TsIcons.privacyTip,
                    onTap: () => context.go('/menu/privacy'),
                  ),
                  TsMenuListItem(
                    label: l10n.menuTermsOfService,
                    icon: TsIcons.article,
                    onTap: () => context.go('/menu/terms'),
                  ),
                  TsMenuListItem(
                    label: l10n.menuAppVersion,
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
                    label: l10n.menuSignOut,
                    icon: TsIcons.logout,
                    onTap: _showSignOutDialog,
                  ),
                  TsMenuListItem(
                    label: l10n.menuDeleteAccount,
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

  TsPlan _tsPlan(PlanType planType) => switch (planType) {
        PlanType.free => TsPlan.free,
        PlanType.trial => TsPlan.trial,
        PlanType.premium => TsPlan.premium,
        PlanType.none => TsPlan.free,
      };

  String _planSubLabel(AppLocalizations l10n, SupabaseAuthProvider auth) =>
      switch (auth.planType) {
        PlanType.free => l10n.menuPlanFreeSubLabel,
        PlanType.trial => l10n.menuPlanTrialSubLabel(
            _trialHoursRemaining(auth),
          ),
        PlanType.premium => _premiumRenewalLabel(l10n, auth),
        PlanType.none => l10n.menuPlanFreeSubLabel,
      };

  int _trialHoursRemaining(SupabaseAuthProvider auth) {
    final expiry = auth.trialExpiryAt;
    if (expiry == null) return 0;
    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative) return 0;
    return (remaining.inMinutes / 60).ceil().clamp(1, 9999);
  }

  String _premiumRenewalLabel(
    AppLocalizations l10n,
    SupabaseAuthProvider auth,
  ) {
    final subscription = auth.subscriptionInfo;
    final expiry = subscription?.expiresAt ?? auth.premiumExpiresAt;
    final isCancellationPending =
        subscription?.isCancellationPending ?? false;

    if (isCancellationPending) {
      if (expiry != null) {
        return l10n.menuPlanPremiumCancelAccessUntil(
          _formatPlanDate(expiry),
        );
      }
      return l10n.subscriptionCancelPending;
    }

    if (expiry != null) {
      return l10n.menuPlanPremiumRenewsOn(_formatPlanDate(expiry));
    }
    return l10n.menuPlanPremiumActive;
  }

  String _formatPlanDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}.$month.$day';
  }

  String _languageLabel(AppLocalizations l10n, AppLanguage language) =>
      switch (language) {
        AppLanguage.en => l10n.languageEnglish,
        AppLanguage.ko => l10n.languageKorean,
      };

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.system => l10n.menuThemeSystem,
        ThemeMode.light => l10n.menuThemeLight,
        ThemeMode.dark => l10n.menuThemeDark,
      };
}
