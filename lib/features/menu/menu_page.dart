import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
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
import 'package:trendsoccer/shared/widgets/radio/ts_radio_button.dart';
import 'package:trendsoccer/shared/widgets/section/ts_section_header.dart';
import 'package:trendsoccer/shared/widgets/toggle/ts_toggle.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  PlanType _planTicketType(PlanType planType) {
    return switch (planType) {
      PlanType.none || PlanType.free => PlanType.free,
      PlanType.trial => PlanType.trial,
      PlanType.premium => PlanType.premium,
    };
  }

  String _planSubtitle(AuthState state) {
    return switch (state.planType) {
      PlanType.none || PlanType.free => '지금 구독 시작하고 프리미엄 데이터를 확인하세요.',
      PlanType.trial => _formatTrialRemaining(state.trialExpiresAt),
      PlanType.premium => _formatPremiumExpiry(state.premiumExpiresAt),
    };
  }

  String _formatTrialRemaining(DateTime? expiresAt) {
    if (expiresAt == null) return '';
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return '체험 기간 만료';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    return '$hours시간 $minutes분 남음';
  }

  String _formatPremiumExpiry(DateTime? expiresAt) {
    if (expiresAt == null) return '';
    return '만료일 ${DateFormat('yyyy.MM.dd').format(expiresAt)}';
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

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationBottomSheet(),
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
                    '로그아웃',
                    style: TsType.headingH2.copyWith(
                      color: semantic.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '정말 로그아웃 하시겠습니까 ?',
                    style: TsType.bodyLRegular.copyWith(
                      color: semantic.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: semantic.textDisabled,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '취소',
                              style: TsType.bodyMBold.copyWith(
                                color: semantic.textDisabled,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            authNotifier.signOut();
                            Navigator.of(dialogContext).pop();
                            context.go('/trend');
                          },
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: semantic.interactivePrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '로그아웃',
                              style: TsType.bodyMBold.copyWith(
                                color: semantic.surfaceBase,
                              ),
                            ),
                          ),
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
                        '계정 삭제',
                        style: TsType.headingH2.copyWith(
                          color: semantic.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '계정을 삭제하면 모든 데이터가 삭제되며 복구할 수 없습니다.',
                        style: TsType.bodyLRegular.copyWith(
                          color: semantic.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\'DELETE\'를 입력하여 확인하세요.',
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
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                deleteController.dispose();
                                Navigator.of(dialogContext).pop();
                              },
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: semantic.textDisabled,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '취소',
                                  style: TsType.bodyMBold.copyWith(
                                    color: semantic.textDisabled,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: isDeleteTyped
                                  ? () {
                                      authNotifier.deleteAccount();
                                      deleteController.dispose();
                                      Navigator.of(dialogContext).pop();
                                      context.go('/splash');
                                    }
                                  : null,
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isDeleteTyped
                                      ? semantic.interactivePrimary
                                      : semantic.interactivePrimary.withValues(
                                          alpha: 0.3,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '계정삭제',
                                  style: TsType.bodyMBold.copyWith(
                                    color: isDeleteTyped
                                        ? semantic.surfaceBase
                                        : semantic.surfaceBase.withValues(
                                            alpha: 0.5,
                                          ),
                                  ),
                                ),
                              ),
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
    final auth = ref.watch(authProvider);
    final isLoggedIn = auth.isLoggedIn;

    return Scaffold(
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
                TsSectionHeader(title: '구독 정보'),
                const SizedBox(height: 16),
                PlanTicket(
                  type: _planTicketType(auth.planType),
                  subtitle: _planSubtitle(auth.state),
                  onButtonTap: () => navigateToSubscribe(context, ref),
                ),
                const SizedBox(height: 16),
              ],
              TsSectionHeader(title: '추가 기능'),
              const SizedBox(height: 16),
              MenuListItem(
                iconAsset: TsAssets.iconBlog,
                label: '리포트',
                onTap: () => context.push('/menu/reports/soccer'),
              ),
              const SizedBox(height: 16),

              TsSectionHeader(title: '앱 설정'),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuListItem(
                    iconAsset: TsAssets.iconLanguage,
                    label: '언어',
                    onTap: () => _showLanguageSheet(context),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconTheme,
                    label: '테마',
                    onTap: () => _showThemeSheet(context),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconNotifications,
                    label: '알림',
                    onTap: () => _showNotificationSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TsSectionHeader(title: '기타'),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuListItem(
                    iconAsset: TsAssets.iconInfo,
                    label: 'About',
                    onTap: () => context.push('/menu/about'),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconPrivacyTip,
                    label: '개인정보처리방침',
                    onTap: () => context.push('/menu/privacy'),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconInfo,
                    label: '이용약관',
                    onTap: () => context.push('/menu/terms'),
                  ),
                  const SizedBox(height: 8),
                  MenuListItem(
                    iconAsset: TsAssets.iconHelp,
                    label: '문의하기',
                    onTap: () => context.push('/menu/help'),
                  ),
                  const SizedBox(height: 8),
                  const MenuListItem(
                    iconAsset: TsAssets.iconVersionInfo,
                    label: '앱 버전',
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
                          '로그아웃',
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
                        width: 2,
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
                          '회원탈퇴',
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

  void _applyTheme() {
    ref.read(themeModeProvider.notifier).setThemeMode(_selectedMode);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

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
                '테마 설정',
                style: TsType.headingH2.copyWith(color: semantic.textPrimary),
              ),
              const SizedBox(height: TsSpacing.sm),
              _ThemeOption(
                label: '다크 모드',
                mode: ThemeMode.dark,
                currentMode: _selectedMode,
                onSelected: _selectMode,
              ),
              const SizedBox(height: TsSpacing.sm),
              _ThemeOption(
                label: '라이트 모드',
                mode: ThemeMode.light,
                currentMode: _selectedMode,
                onSelected: _selectMode,
              ),
              const SizedBox(height: TsSpacing.sm),
              _ThemeOption(
                label: '시스템 설정',
                mode: ThemeMode.system,
                currentMode: _selectedMode,
                onSelected: _selectMode,
              ),
              const SizedBox(height: TsSpacing.lg),
              TsButton(
                label: '적용하기',
                variant: TsButtonVariant.primary,
                onPressed: _applyTheme,
              ),
              const SizedBox(height: TsSpacing.sm),
              TsButton(
                label: '뒤로가기',
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

class _LanguageBottomSheet extends StatefulWidget {
  const _LanguageBottomSheet();

  @override
  State<_LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<_LanguageBottomSheet> {
  _LanguageCode _selected = _LanguageCode.ko;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

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
                '언어 설정',
                style: TsType.headingH2.copyWith(color: semantic.textPrimary),
              ),
              const SizedBox(height: TsSpacing.sm),
              _LanguageOptionRow(
                label: '한국어',
                selected: _selected == _LanguageCode.ko,
                onTap: () => setState(() => _selected = _LanguageCode.ko),
              ),
              const SizedBox(height: TsSpacing.sm),
              _LanguageOptionRow(
                label: 'English',
                selected: _selected == _LanguageCode.en,
                onTap: () => setState(() => _selected = _LanguageCode.en),
              ),
              const SizedBox(height: TsSpacing.lg),
              TsButton(
                label: '적용하기',
                variant: TsButtonVariant.primary,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: TsSpacing.sm),
              TsButton(
                label: '뒤로가기',
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
  bool _generalOn = true;
  bool _eventOn = false;
  bool _flashOn = false;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

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
                '알림 설정',
                style: TsType.headingH2.copyWith(color: semantic.textPrimary),
              ),
              const SizedBox(height: TsSpacing.sm),
              _NotificationToggleRow(
                label: '일반 알림',
                value: _generalOn,
                onChanged: (v) => setState(() => _generalOn = v),
              ),
              const SizedBox(height: TsSpacing.sm),
              _NotificationToggleRow(
                label: '경기 이벤트',
                value: _eventOn,
                onChanged: (v) => setState(() => _eventOn = v),
              ),
              const SizedBox(height: TsSpacing.sm),
              _NotificationToggleRow(
                label: '속보',
                value: _flashOn,
                onChanged: (v) => setState(() => _flashOn = v),
              ),
              const SizedBox(height: TsSpacing.lg),
              TsButton(
                label: '적용하기',
                variant: TsButtonVariant.primary,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: TsSpacing.sm),
              TsButton(
                label: '뒤로가기',
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

class _NotificationToggleRow extends StatelessWidget {
  const _NotificationToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
            ),
          ),
          TsToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
