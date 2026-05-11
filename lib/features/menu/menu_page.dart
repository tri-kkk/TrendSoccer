import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/bottom_sheet/ts_bottom_sheet.dart';
import 'package:trendsoccer/shared/widgets/menu/delete_account_dialog.dart';
import 'package:trendsoccer/shared/widgets/menu/guest_banner.dart';
import 'package:trendsoccer/shared/widgets/menu/menu_list_item.dart';
import 'package:trendsoccer/shared/widgets/menu/plan_ticket.dart';
import 'package:trendsoccer/shared/widgets/menu/sign_out_dialog.dart';
import 'package:trendsoccer/shared/widgets/section/ts_section_header.dart';

void _showSettingsPlaceholderSheet(BuildContext context, String title) {
  final semantic = Theme.of(context).extension<TsSemanticColors>()!;
  TsBottomSheet.show<void>(
    context,
    sheet: TsBottomSheet(
      title: title,
      content: Text(
        '준비 중입니다.',
        style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
      ),
      primaryButtonLabel: '확인',
      onPrimaryPressed: () => Navigator.of(context).pop(),
    ),
  );
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => _showSettingsPlaceholderSheet(context, '언어'),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  MenuListItem(
                    icon: Icons.palette,
                    label: '테마',
                    onTap: () => _showSettingsPlaceholderSheet(context, '테마'),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  MenuListItem(
                    icon: Icons.notifications,
                    label: '알림',
                    onTap: () => _showSettingsPlaceholderSheet(context, '알림'),
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
