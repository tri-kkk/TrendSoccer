import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/back_button.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  int _selectedVersionIndex = 0;

  final List<_TermsVersion> _versions = [
    _TermsVersion('2026년 5월 11일', true),
    _TermsVersion('2026년 1월 14일', false),
    _TermsVersion('2025년 11월 25일', false),
  ];

  final List<_TermsSection> _sections = [
    _TermsSection(
      '제1조 (목적)',
      null,
      '본 약관은 TrendSoccer(이하 \'회사\')가 제공하는 스포츠 분석 서비스(이하 \'서비스\')의 이용조건 및 절차, 회원과 회사의 권리 및 의무, 책임사항과 기타 필요한 사항을 규정하는 것을 목적으로 합니다.',
    ),
    _TermsSection(
      '제2조 (서비스의 내용)',
      null,
      '회사는 축구 및 야구 경기에 대한 통계 데이터 분석, AI 기반 경기 예측, PREMIUM PICK 정보, 실시간 스코어 및 경기 일정 정보를 제공합니다. 서비스의 구체적인 내용은 회사의 정책에 따라 변경될 수 있습니다.',
    ),
    _TermsSection(
      '제3조 (구독 및 결제)',
      '3.1 구독',
      '프리미엄 서비스는 유료 구독을 통해 이용 가능하며, 구독 상품은 1개월(₩4,900) 및 3개월(₩9,900)으로 구분됩니다. 결제는 외부 웹뷰를 통해 진행되며, 구독 기간 중 추가 결제 시 남은 기간에 신규 기간이 합산됩니다',
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
          '이용약관',
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
                  if (section.subtitle != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      section.subtitle!,
                      style: TsType.bodyLBold.copyWith(color: semantic.textPrimary),
                    ),
                  ],
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

class _TermsVersion {
  _TermsVersion(this.date, this.isCurrent);

  final String date;
  final bool isCurrent;
}

class _TermsSection {
  _TermsSection(this.title, this.subtitle, this.content);

  final String title;
  final String? subtitle;
  final String content;
}
