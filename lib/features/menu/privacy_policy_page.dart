import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/back_button.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  int _selectedVersionIndex = 0;

  final List<_PolicyVersion> _versions = [
    _PolicyVersion('2026년 5월 11일', true),
    _PolicyVersion('2026년 1월 14일', false),
    _PolicyVersion('2025년 11월 25일', false),
  ];

  final List<_PolicySection> _sections = [
    _PolicySection(
      '제1조 (목적)',
      '본 개인정보처리방침은 TrendSoccer(이하 \'회사\')가 제공하는 서비스 이용과 관련하여 회원의 개인정보를 보호하고, 이와 관련한 고충을 원활하게 처리할 수 있도록 하기 위하여 다음과 같은 처리방침을 두고 있습니다.',
    ),
    _PolicySection(
      '제2조 (수집하는 개인정보의 항목)',
      '회사는 서비스 제공을 위해 다음의 개인정보를 수집합니다. 필수항목으로 이메일 주소, 닉네임, 소셜 로그인 식별자를 수집하며, 선택항목으로 마케팅 수신 동의 여부를 수집합니다.',
    ),
    _PolicySection(
      '제3조 (개인정보의 보유 및 이용기간)',
      '회원의 개인정보는 서비스 이용계약 기간 동안 보유 및 이용됩니다. 단, 관계 법령에 의한 정보 보유 사유가 있는 경우 해당 기간 동안 보유합니다. 회원 탈퇴 시에도 48시간 무료 체험 중복 방지를 위해 이메일 주소는 영구 보관됩니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final currentVersion = _versions[_selectedVersionIndex];

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: AppBar(
        backgroundColor: semantic.surfaceBase,
        elevation: 0,
        leading: TsBackButton(onPressed: () => context.pop()),
        title: Text(
          '개인정보처리방침',
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versions',
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showVersionDialog(context, semantic),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: semantic.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${currentVersion.date}${currentVersion.isCurrent ? ' (현행)' : ''}',
                      style: TsType.bodyLRegular.copyWith(color: semantic.textTertiary),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.expand_circle_down_outlined,
                      size: 24,
                      color: semantic.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ..._sections.map(
              (section) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    section.content,
                    style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: semantic.borderSubtle),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVersionDialog(BuildContext context, TsSemanticColors semantic) {
    var tempSelected = _selectedVersionIndex;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 348,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: semantic.surfaceOverlay,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '버전 선택',
                            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(dialogContext).pop(),
                            child: Icon(Icons.close, size: 24, color: semantic.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._versions.asMap().entries.map((entry) {
                        final i = entry.key;
                        final v = entry.value;
                        return Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setDialogState(() => tempSelected = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            v.date,
                                            style: TsType.bodyLRegular.copyWith(
                                              color: semantic.textPrimary,
                                            ),
                                          ),
                                          if (v.isCurrent) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              '(현행)',
                                              style: TsType.labelSRegular.copyWith(
                                                color: semantic.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: tempSelected == i
                                              ? semantic.interactivePrimary
                                              : semantic.borderDefault,
                                          width: 2,
                                        ),
                                      ),
                                      child: tempSelected == i
                                          ? Center(
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: semantic.interactivePrimary,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (i < _versions.length - 1)
                              Container(height: 1, color: semantic.borderSubtle),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TsButton(
                          label: '확인',
                          variant: TsButtonVariant.primary,
                          size: TsButtonSize.small,
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            setState(() => _selectedVersionIndex = tempSelected);
                          },
                        ),
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
}

class _PolicyVersion {
  _PolicyVersion(this.date, this.isCurrent);

  final String date;
  final bool isCurrent;
}

class _PolicySection {
  _PolicySection(this.title, this.content);

  final String title;
  final String content;
}
