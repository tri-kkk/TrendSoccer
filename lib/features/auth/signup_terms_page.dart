import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/auth/terms_card.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class SignupTermsPage extends StatefulWidget {
  const SignupTermsPage({super.key});

  @override
  State<SignupTermsPage> createState() => _SignupTermsPageState();
}

class _SignupTermsPageState extends State<SignupTermsPage> {
  bool _termsChecked = false;
  bool _privacyChecked = false;
  bool _marketingChecked = false;

  void _toggleAgreeAll() {
    final allChecked = _termsChecked && _privacyChecked && _marketingChecked;
    setState(() {
      _termsChecked = !allChecked;
      _privacyChecked = !allChecked;
      _marketingChecked = !allChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final requiredOk = _termsChecked && _privacyChecked;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: const TsAppBar(
        location: TsAppBarLocation.backTitle,
        title: '회원가입',
      ),
      body: Padding(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '서비스 이용을 위해\n약관에 동의해주세요',
              style: TsType.headingH1.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: TsSpacing.xl),
            TermsCard(
              termsChecked: _termsChecked,
              privacyChecked: _privacyChecked,
              marketingChecked: _marketingChecked,
              onTermsChanged: () => setState(() => _termsChecked = !_termsChecked),
              onPrivacyChanged: () => setState(() => _privacyChecked = !_privacyChecked),
              onMarketingChanged: () =>
                  setState(() => _marketingChecked = !_marketingChecked),
              onAgreeAllChanged: _toggleAgreeAll,
              onTermsView: () => context.push('/menu/terms'),
              onPrivacyView: () => context.push('/menu/privacy'),
            ),
            const Spacer(),
            TsButton(
              label: '가입하기',
              variant: TsButtonVariant.primary,
              onPressed: requiredOk ? () => context.push('/signup/complete') : null,
            ),
            const SizedBox(height: TsSpacing.lg),
          ],
        ),
      ),
    );
  }
}
