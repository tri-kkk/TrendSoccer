import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/services/fcm_service.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/providers/theme_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/bottom_sheet/ts_bottom_sheet_handle.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/menu/guest_banner.dart';
import 'package:trendsoccer/shared/widgets/menu/menu_list_item.dart';
import 'package:trendsoccer/shared/widgets/menu/plan_ticket.dart';
import 'package:trendsoccer/shared/widgets/menu/profile_card.dart';
import 'package:trendsoccer/shared/widgets/loading/ts_loading_overlay.dart';
import 'package:trendsoccer/shared/widgets/radio/ts_radio_button.dart';
import 'package:trendsoccer/shared/widgets/section/ts_section_header.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/toggle/ts_toggle.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  final bool _isDeletingAccount = false;

  PlanType _planTicketType(PlanType planType) {
    return switch (planType) {
      PlanType.none || PlanType.free => PlanType.free,
      PlanType.trial => PlanType.trial,
      PlanType.premium => PlanType.premium,
    };
  }

  String _planSubtitle(BuildContext context, AuthState state) {
    final l10n = context.l10n;
    return switch (state.planType) {
      PlanType.none || PlanType.free => l10n.menuSubscribePrompt,
      PlanType.trial => _formatTrialRemaining(context, state.trialExpiresAt),
      PlanType.premium => _formatPremiumExpiry(context, state.premiumExpiresAt),
    };
  }

  String _formatTrialRemaining(BuildContext context, DateTime? expiresAt) {
    if (expiresAt == null) return '';
    final l10n = context.l10n;
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return l10n.menuTrialExpired;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    return l10n.menuTrialRemaining(hours, minutes);
  }

  String _formatPremiumExpiry(BuildContext context, DateTime? expiresAt) {
    if (expiresAt == null) return '';
    return context.l10n.menuPremiumExpiryDate(
      DateFormat('yyyy.MM.dd').format(expiresAt),
    );
  }

  String _subscribeButtonLabel(BuildContext context, PlanType planType) {
    final l10n = context.l10n;
    return switch (planType) {
      PlanType.none || PlanType.free => l10n.menuSubscribeFree,
      PlanType.trial => l10n.menuSubscribeTrial,
      PlanType.premium => l10n.menuSubscribeManage,
    };
  }

  VoidCallback? _subscribeButtonTap(PlanType planType) {
    if (planType == PlanType.trial) return null;
    return () => navigateToSubscribe(context, ref);
  }

  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ThemeBottomSheet(),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LanguageBottomSheet(),
    );
  }

  Future<void> _showPermissionSettingsDialog(BuildContext context) async {
    if (!context.mounted) return;
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final semantic = Theme.of(ctx).extension<TsSemanticColors>()!;
        return AlertDialog(
          backgroundColor: semantic.surfaceOverlay,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            ctx.l10n.notificationPermissionTitle,
            style: TextStyle(color: semantic.textPrimary),
          ),
          content: Text(
            ctx.l10n.notificationPermissionMessage,
            style: TextStyle(color: semantic.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                ctx.l10n.cancel,
                style: TextStyle(color: semantic.textTertiary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                ctx.l10n.notificationPermissionGoSettings,
                style: TextStyle(color: semantic.interactivePrimary),
              ),
            ),
          ],
        );
      },
    );
    if (shouldOpen == true) {
      await openAppSettings();
    }
  }

  Future<void> _openNotificationBottomSheet(BuildContext context) async {
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationBottomSheet(),
    );
  }

  Future<void> _showNotificationSheet(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return;
      await _showPermissionSettingsDialog(context);
      return;
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        await FCMService().unsubscribeAllTopics();
        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.notificationDisabledSnack,
              ),
              duration: Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final appGeneral = prefs.getBool(FCMService.prefAppGeneral) ?? false;
      if (!appGeneral) {
        await FCMService().subscribeAllTopics();
      }
    }

    if (!context.mounted) return;
    await _openNotificationBottomSheet(context);
  }

  void _showSignOutDialog(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final authNotifier = ref.read(authProvider);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 348,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: semantic.surfaceOverlay,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dialogContext.l10n.signOutTitle,
                    style: TsType.headingH2.copyWith(
                      color: semantic.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    dialogContext.l10n.signOutMessage,
                    style: TsType.bodyLRegular.copyWith(
                      color: semantic.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TsButton(
                          label: dialogContext.l10n.cancel,
                          variant: TsButtonVariant.secondary,
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TsButton(
                          label: dialogContext.l10n.signOutConfirm,
                          variant: TsButtonVariant.primary,
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await authNotifier.signOut();
                            if (!context.mounted) return;
                            TsToast.success(context, context.l10n.signOutSuccess);
                            context.go('/trend');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final authNotifier = ref.read(authProvider);
    final deleteController = TextEditingController();

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) {
        var isDeleting = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isDeleteTyped =
                deleteController.text.toUpperCase() == 'DELETE';
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: semantic.surfaceOverlay,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dialogContext.l10n.deleteAccountTitle,
                        style: TsType.headingH2.copyWith(
                          color: semantic.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dialogContext.l10n.deleteAccountMessage,
                        style: TsType.bodyLRegular.copyWith(
                          color: semantic.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dialogContext.l10n.deleteAccountHint,
                        style: TsType.bodyLRegular.copyWith(
                          color: semantic.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: semantic.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: semantic.borderDefault,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: deleteController,
                          onChanged: (_) => setDialogState(() {}),
                          textAlign: TextAlign.center,
                          style: TsType.labelSRegular.copyWith(
                            color: semantic.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'DELETE',
                            hintStyle: TsType.labelSRegular.copyWith(
                              color: semantic.textTertiary,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isDeleting)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(
                              color: semantic.interactivePrimary,
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: TsButton(
                                label: dialogContext.l10n.cancel,
                                variant: TsButtonVariant.secondary,
                                onPressed: () {
                                  deleteController.dispose();
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TsButton(
                                label: dialogContext.l10n.deleteAccountConfirm,
                                variant: TsButtonVariant.primary,
                                onPressed: isDeleteTyped
                                    ? () async {
                                        setDialogState(() => isDeleting = true);
                                        try {
                                          await authNotifier.deleteAccount();
                                          if (dialogContext.mounted) {
                                            Navigator.of(dialogContext).pop();
                                          }
                                          await Future<void>.delayed(
                                            const Duration(milliseconds: 100),
                                          );
                                          if (context.mounted) {
                                            context.go('/splash');
                                          }
                                        } catch (e) {
                                          deleteController.dispose();
                                          if (dialogContext.mounted) {
                                            Navigator.of(dialogContext).pop();
                                          }
                                          if (context.mounted) {
                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            messenger.clearSnackBars();
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  resolveApiError(
                                                    context,
                                                    e,
                                                  ),
                                                ),
                                                duration: const Duration(
                                                  seconds: 5,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final auth = ref.watch(authProvider);
    final isLoggedIn = auth.isLoggedIn;

    return TsLoadingOverlay(
      isLoading: _isDeletingAccount,
      child: Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isLoggedIn)
                GuestBanner(onJoinTap: () => context.push('/login'))
              else
                ProfileCard(name: auth.userName, email: auth.userEmail),
              const SizedBox(height: 16),

              if (isLoggedIn) ...[
                TsSectionHeader(title: l10n.menuSubscribeInfoSection),
                const SizedBox(height: 16),
                PlanTicket(
                  type: _planTicketType(auth.planType),
                  subtitle: _planSubtitle(context, auth.state),
                  buttonLabel: _subscribeButtonLabel(context, auth.planType),
                  onButtonTap: _subscribeButtonTap(auth.planType),
                ),
                const SizedBox(height: 16),
              ],
              TsSectionHeader(title: l10n.menuExploreSection),
              const SizedBox(height: 16),
              MenuListItem(
                iconAsset: TsAssets.iconBlog,
                label: l10n.menuMatchPreview,
                onTap: () => context.go('/menu/reports/soccer'),
              ),
              const SizedBox(height: 16),

              TsSectionHeader(title: l10n.menuSettingsSection),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuListItem(
                    iconAsset: TsAssets.iconLanguage,
                    label: l10n.menuLanguage,
                    onTap: () => _showLanguageSheet(context),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconTheme,
                    label: l10n.menuTheme,
                    onTap: () => _showThemeSheet(context),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconNotifications,
                    label: l10n.menuNotification,
                    onTap: () => _showNotificationSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TsSectionHeader(title: l10n.menuOthers),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuListItem(
                    iconAsset: TsAssets.iconInfo,
                    label: l10n.menuAbout,
                    onTap: () => context.push('/menu/about'),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconPrivacyTip,
                    label: l10n.menuPrivacyPolicy,
                    onTap: () => context.go('/menu/privacy'),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconVerified,
                    label: l10n.menuTermsOfService,
                    onTap: () => context.go('/menu/terms'),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconHelp,
                    label: l10n.menuHelpCenter,
                    onTap: () => context.go('/menu/help'),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconVersionInfo,
                    label: l10n.menuAppVersion,
                    type: MenuItemType.value,
                    value: '1.0.0',
                  ),
                ],
              ),

              if (isLoggedIn) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showSignOutDialog(context),
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          l10n.menuSignOut,
                          style: TsType.labelSRegular.copyWith(
                            color: semantic.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Opacity(
                      opacity: 0.5,
                      child: Container(
                        width: 1,
                        height: 17,
                        color: semantic.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showDeleteAccountDialog(context),
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          l10n.menuDeleteAccount,
                          style: TsType.labelSRegular.copyWith(
                            color: semantic.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _ThemeBottomSheet extends ConsumerStatefulWidget {
  const _ThemeBottomSheet();

  @override
  ConsumerState<_ThemeBottomSheet> createState() => _ThemeBottomSheetState();
}

class _ThemeBottomSheetState extends ConsumerState<_ThemeBottomSheet> {
  ThemeMode? _draftMode;

  ThemeMode get _selectedMode => _draftMode ?? ref.read(themeModeProvider);

  void _selectMode(ThemeMode mode) => setState(() => _draftMode = mode);

  Future<void> _applyTheme() async {
    await ref.read(themeModeProvider.notifier).setThemeMode(_selectedMode);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ColoredBox(
        color: semantic.surfaceOverlay,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TsBottomSheetHandle(),
              const SizedBox(height: TsSpacing.lg),
              Text(
                l10n.themeSettingsTitle,
                style: TsType.headingH2.copyWith(color: semantic.textPrimary),
              ),
              const SizedBox(height: TsSpacing.sm),
              _ThemeOption(
                label: l10n.themeDark,
                mode: ThemeMode.dark,
                currentMode: _selectedMode,
                onSelected: _selectMode,
              ),
              const SizedBox(height: TsSpacing.sm),
              _ThemeOption(
                label: l10n.themeLight,
                mode: ThemeMode.light,
                currentMode: _selectedMode,
                onSelected: _selectMode,
              ),
              const SizedBox(height: TsSpacing.sm),
              _ThemeOption(
                label: l10n.themeSystem,
                mode: ThemeMode.system,
                currentMode: _selectedMode,
                onSelected: _selectMode,
              ),
              const SizedBox(height: TsSpacing.lg),
              TsButton(
                label: l10n.apply,
                variant: TsButtonVariant.primary,
                onPressed: _applyTheme,
              ),
              const SizedBox(height: TsSpacing.sm),
              TsButton(
                label: l10n.goBack,
                variant: TsButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.onSelected,
  });

  final String label;
  final ThemeMode mode;
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          TsRadioButton(
            selected: mode == currentMode,
            onChanged: () => onSelected(mode),
          ),
          const SizedBox(width: TsSpacing.lg),
          Expanded(
            child: Text(
              label,
              style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

enum _LanguageCode { ko, en }

AppLanguage _appLanguageFromCode(_LanguageCode code) => switch (code) {
  _LanguageCode.ko => AppLanguage.ko,
  _LanguageCode.en => AppLanguage.en,
};

_LanguageCode _languageCodeFromApp(AppLanguage language) => switch (language) {
  AppLanguage.ko => _LanguageCode.ko,
  AppLanguage.en => _LanguageCode.en,
};

class _LanguageBottomSheet extends ConsumerStatefulWidget {
  const _LanguageBottomSheet();

  @override
  ConsumerState<_LanguageBottomSheet> createState() =>
      _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends ConsumerState<_LanguageBottomSheet> {
  _LanguageCode get _selected =>
      _languageCodeFromApp(ref.watch(languageProvider));

  Future<void> _selectLanguage(_LanguageCode language) async {
    await ref
        .read(languageProvider.notifier)
        .setLanguage(_appLanguageFromCode(language));
  }

  Future<void> _applyLanguage() async {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ColoredBox(
        color: semantic.surfaceOverlay,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TsBottomSheetHandle(),
              const SizedBox(height: TsSpacing.lg),
              Text(
                l10n.languageSettingsTitle,
                style: TsType.headingH2.copyWith(color: semantic.textPrimary),
              ),
              const SizedBox(height: TsSpacing.sm),
              _LanguageOptionRow(
                label: l10n.languageKorean,
                selected: _selected == _LanguageCode.ko,
                onTap: () => unawaited(_selectLanguage(_LanguageCode.ko)),
              ),
              const SizedBox(height: TsSpacing.sm),
              _LanguageOptionRow(
                label: l10n.languageEnglish,
                selected: _selected == _LanguageCode.en,
                onTap: () => unawaited(_selectLanguage(_LanguageCode.en)),
              ),
              const SizedBox(height: TsSpacing.lg),
              TsButton(
                label: l10n.apply,
                variant: TsButtonVariant.primary,
                onPressed: _applyLanguage,
              ),
              const SizedBox(height: TsSpacing.sm),
              TsButton(
                label: l10n.goBack,
                variant: TsButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionRow extends StatelessWidget {
  const _LanguageOptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          TsRadioButton(selected: selected, onChanged: onTap),
          const SizedBox(width: TsSpacing.lg),
          Expanded(
            child: Text(
              label,
              style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBottomSheet extends StatefulWidget {
  const _NotificationBottomSheet();

  @override
  State<_NotificationBottomSheet> createState() =>
      _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<_NotificationBottomSheet> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _appGeneral = true;
  bool _matchEvents = true;
  bool _marketing = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _appGeneral = prefs.getBool(FCMService.prefAppGeneral) ?? true;
      _matchEvents = prefs.getBool(FCMService.prefMatchEvents) ?? true;
      _marketing = prefs.getBool(FCMService.prefMarketing) ?? true;
      _isLoading = false;
    });
  }

  Future<void> _onToggleChanged({
    required String prefKey,
    required String topic,
    required bool value,
    required void Function(bool) updateState,
  }) async {
    if (_isSaving || _isLoading) return;
    setState(() {
      _isSaving = true;
      updateState(value);
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      if (value) {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        await prefs.setBool(prefKey, true);
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        await prefs.setBool(prefKey, false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => updateState(!value));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final togglesEnabled = !_isLoading && !_isSaving;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ColoredBox(
        color: semantic.surfaceOverlay,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TsBottomSheetHandle(),
              const SizedBox(height: 16),
              Text(
                l10n.notificationTitle,
                style: TsType.headingH3.copyWith(color: semantic.textPrimary),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: semantic.interactivePrimary,
                    ),
                  ),
                )
              else ...[
                _NotificationTopicSection(
                  semantic: semantic,
                  label: l10n.notificationAppGeneral,
                  subtitle: l10n.notificationAppGeneralDesc,
                  value: _appGeneral,
                  onChanged: togglesEnabled
                      ? (v) => _onToggleChanged(
                            prefKey: FCMService.prefAppGeneral,
                            topic: FCMService.topicAppGeneral,
                            value: v,
                            updateState: (val) => _appGeneral = val,
                          )
                      : null,
                  showDivider: true,
                ),
                _NotificationTopicSection(
                  semantic: semantic,
                  label: l10n.notificationMatchEvents,
                  subtitle: l10n.notificationMatchEventsDesc,
                  value: _matchEvents,
                  onChanged: togglesEnabled
                      ? (v) => _onToggleChanged(
                            prefKey: FCMService.prefMatchEvents,
                            topic: FCMService.topicMatchEvents,
                            value: v,
                            updateState: (val) => _matchEvents = val,
                          )
                      : null,
                  showDivider: true,
                ),
                _NotificationTopicSection(
                  semantic: semantic,
                  label: l10n.notificationMarketing,
                  subtitle: l10n.notificationMarketingDesc,
                  value: _marketing,
                  onChanged: togglesEnabled
                      ? (v) => _onToggleChanged(
                            prefKey: FCMService.prefMarketing,
                            topic: FCMService.topicMarketing,
                            value: v,
                            updateState: (val) => _marketing = val,
                          )
                      : null,
                  showDivider: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTopicSection extends StatelessWidget {
  const _NotificationTopicSection({
    required this.semantic,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.showDivider,
  });

  final TsSemanticColors semantic;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TsType.bodyLRegular.copyWith(
                  color: semantic.textPrimary,
                ),
              ),
            ),
            TsToggle(value: value, onChanged: onChanged),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Container(height: 1, color: semantic.borderSubtle),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
