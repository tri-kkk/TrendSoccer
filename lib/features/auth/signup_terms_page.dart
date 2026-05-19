import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class SignupTermsPage extends StatefulWidget {
  const SignupTermsPage({super.key});

  @override
  State<SignupTermsPage> createState() => _SignupTermsPageState();
}

class _SignupTermsPageState extends State<SignupTermsPage> {
  bool _termsAgreed = false;
  bool _privacyAgreed = false;
  bool _marketingAgreed = false;

  bool get _agreeAll => _termsAgreed && _privacyAgreed && _marketingAgreed;
  bool get _canSubmit => _termsAgreed && _privacyAgreed;

  void _toggleAgreeAll() {
    setState(() {
      if (_agreeAll) {
        _termsAgreed = false;
        _privacyAgreed = false;
        _marketingAgreed = false;
      } else {
        _termsAgreed = true;
        _privacyAgreed = true;
        _marketingAgreed = true;
      }
    });
  }

  Widget _checkIcon(bool checked, TsSemanticColors semantic) {
    return Icon(
      checked ? Icons.check_box : Icons.check_box_outline_blank,
      size: 24,
      color: checked ? semantic.interactivePrimary : semantic.textDisabled,
    );
  }

  Widget _radioIcon(bool checked, TsSemanticColors semantic) {
    return Icon(
      checked ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      size: 24,
      color: checked ? semantic.interactivePrimary : semantic.textDisabled,
    );
  }

  Widget _requiredTag() {
    return Text(
      '[필수]',
      style: TsType.labelSRegular.copyWith(color: TsColors.systemError500),
    );
  }

  Widget _optionalTag(TsSemanticColors semantic) {
    return Text(
      '[선택]',
      style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
    );
  }

  Widget _termsRow({
    required TsSemanticColors semantic,
    required bool checked,
    required VoidCallback onToggle,
    required Widget tag,
    required String label,
    VoidCallback? onView,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: _checkIcon(checked, semantic),
        ),
        const SizedBox(width: 8),
        tag,
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Text(
              label,
              style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
            ),
          ),
        ),
        if (onView != null)
          GestureDetector(
            onTap: onView,
            behavior: HitTestBehavior.opaque,
            child: Text(
              '보기',
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: AppBar(
        backgroundColor: semantic.surfaceBase,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '회원가입',
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 48,
            bottom: 48 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    TsAssets.logoSymbol(Theme.of(context).brightness),
                    width: 240,
                    height: 240,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '서비스 이용을 위해',
                    style: TsType.headingH2.copyWith(color: semantic.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '약관에 동의해주세요.',
                    style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '필수 항목에 동의하시면 가입이 완료됩니다.',
                    style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: semantic.surfaceRaised,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _toggleAgreeAll,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: semantic.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _radioIcon(_agreeAll, semantic),
                            const SizedBox(width: 8),
                            Text(
                              '전체 동의',
                              style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: semantic.borderSubtle),
                    const SizedBox(height: 16),
                    _termsRow(
                      semantic: semantic,
                      checked: _termsAgreed,
                      onToggle: () => setState(() => _termsAgreed = !_termsAgreed),
                      tag: _requiredTag(),
                      label: '이용약관',
                      onView: () => context.push('/menu/terms'),
                    ),
                    const SizedBox(height: 16),
                    _termsRow(
                      semantic: semantic,
                      checked: _privacyAgreed,
                      onToggle: () => setState(() => _privacyAgreed = !_privacyAgreed),
                      tag: _requiredTag(),
                      label: '개인정보처리방침',
                      onView: () => context.push('/menu/privacy'),
                    ),
                    const SizedBox(height: 16),
                    _termsRow(
                      semantic: semantic,
                      checked: _marketingAgreed,
                      onToggle: () => setState(() => _marketingAgreed = !_marketingAgreed),
                      tag: _optionalTag(semantic),
                      label: '마케팅 이메일 수신',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TsButton(
                label: '가입하기',
                variant: TsButtonVariant.primary,
                onPressed: _canSubmit ? () => context.push('/signup/complete') : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
