import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/theme_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/bottom_sheet/ts_bottom_sheet_handle.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/menu/delete_account_dialog.dart';
import 'package:trendsoccer/shared/widgets/menu/guest_banner.dart';
import 'package:trendsoccer/shared/widgets/menu/menu_list_item.dart';
import 'package:trendsoccer/shared/widgets/menu/plan_ticket.dart';
import 'package:trendsoccer/shared/widgets/menu/sign_out_dialog.dart';
import 'package:trendsoccer/shared/widgets/radio/ts_radio_button.dart';
import 'package:trendsoccer/shared/widgets/section/ts_section_header.dart';
import 'package:trendsoccer/shared/widgets/toggle/ts_toggle.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg, vertical: TsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GuestBanner(onJoinTap: () => context.push('/login')),
              // ProfileCard(name: 'User', email: 'user@example.com'), // when logged in
              const SizedBox(height: TsSpacing.xl),
              TsSectionHeader(title: '플랜'),
              const SizedBox(height: TsSpacing.md),
              PlanTicket(
                type: PlanType.free,
                subtitle: '지금 구독 시작하고 프리미엄 데이터를 확인하세요.',
                onButtonTap: () => context.push('/menu/subscribe'),
              ),
              const SizedBox(height: TsSpacing.xl),
              TsSectionHeader(title: '탐색'),
              const SizedBox(height: TsSpacing.md),
              MenuListItem(
                icon: Icons.article,
                label: 'Soccer Reports',
                onTap: () => context.push('/menu/reports/soccer'),
              ),
              const SizedBox(height: TsSpacing.xl),
              TsSectionHeader(title: '설정'),
              const SizedBox(height: TsSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuListItem(
                    icon: Icons.language,
                    label: '언어',
                    onTap: () => _showLanguageSheet(context),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  MenuListItem(
                    icon: Icons.palette,
                    label: '테마',
                    onTap: () => _showThemeSheet(context, ref),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  MenuListItem(
                    icon: Icons.notifications,
                    label: '알림',
                    onTap: () => _showNotificationSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.xl),
              TsSectionHeader(title: '기타'),
              const SizedBox(height: TsSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuListItem(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () => context.push('/menu/about'),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  MenuListItem(
                    icon: Icons.privacy_tip_outlined,
                    label: '개인정보처리방침',
                    onTap: () => context.push('/menu/privacy'),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  MenuListItem(
                    icon: Icons.description_outlined,
                    label: '이용약관',
                    onTap: () => context.push('/menu/terms'),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  MenuListItem(
                    icon: Icons.help_outline,
                    label: '도움말',
                    onTap: () => context.push('/menu/help'),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  const MenuListItem(
                    icon: Icons.info,
                    label: '앱 버전',
                    type: MenuItemType.value,
                    value: '1.0.0',
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.xl),
              TsSectionHeader(title: '계정'),
              const SizedBox(height: TsSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MenuListItem(
                    icon: Icons.logout,
                    label: '로그아웃',
                    onTap: () async {
                      await SignOutDialog.show(context);
                    },
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  MenuListItem(
                    icon: Icons.delete_forever,
                    label: '계정 삭제',
                    onTap: () async {
                      await DeleteAccountDialog.show(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeBottomSheet extends ConsumerWidget {
  const _ThemeBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final currentMode = ref.watch(themeModeProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ColoredBox(
        color: semantic.surfaceOverlay,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                currentMode: currentMode,
                onSelected: (mode) =>
                    ref.read(themeModeProvider.notifier).setThemeMode(mode),
              ),
              const SizedBox(height: TsSpacing.sm),
              _ThemeOption(
                label: '라이트 모드',
                mode: ThemeMode.light,
                currentMode: currentMode,
                onSelected: (mode) =>
                    ref.read(themeModeProvider.notifier).setThemeMode(mode),
              ),
              const SizedBox(height: TsSpacing.sm),
              _ThemeOption(
                label: '시스템 설정',
                mode: ThemeMode.system,
                currentMode: currentMode,
                onSelected: (mode) =>
                    ref.read(themeModeProvider.notifier).setThemeMode(mode),
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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
