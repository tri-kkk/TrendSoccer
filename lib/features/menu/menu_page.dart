import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
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

  Future<void> _openGooglePlaySubscriptionManagement() async {
    final url = Uri.parse(
      'https://play.google.com/store/account/subscriptions?package=com.trendsoccer.app',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  VoidCallback? _subscribeButtonTap(PlanType planType) {
    if (planType == PlanType.premium) {
      return () => unawaited(_openGooglePlaySubscriptionManagement());
    }
    if (planType == PlanType.trial) return null;
    return () => navigateToSubscribe(context, ref);
  }

  DateTime? _planStartDate(SupabaseAuthProvider auth, PlanType planType) {
    return switch (planType) {
      PlanType.trial => auth.trialStartAt,
      PlanType.premium =>
        auth.subscriptionInfo?.startedAt ?? auth.premiumStartAt,
      PlanType.none || PlanType.free => null,
    };
  }

  DateTime? _planExpiryDate(SupabaseAuthProvider auth, PlanType planType) {
    return switch (planType) {
      PlanType.trial => auth.trialExpiryAt,
      PlanType.premium =>
        auth.subscriptionInfo?.expiresAt ?? auth.premiumExpiresAt,
      PlanType.none || PlanType.free => null,
    };
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
      backgroundColor: semantic.surfaceRaised,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
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
                Builder(
                  builder: (context) {
                    final planType = _planTicketType(auth.planType);
                    final startDate = _planStartDate(auth, planType);
                    final expiryDate = _planExpiryDate(auth, planType);
                    final sub = auth.subscriptionInfo;
                    return PlanTicket(
                      type: planType,
                      startDate: startDate,
                      expiryDate: expiryDate,
                      isCancellationPending: planType == PlanType.premium &&
                          (sub?.isCancellationPending ?? false),
                      onButtonTap: _subscribeButtonTap(planType),
                    );
                  },
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
                    onTap: () => context.push('/menu/notification-settings'),
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
