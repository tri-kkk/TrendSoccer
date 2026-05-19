import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class SignupCompletePage extends ConsumerStatefulWidget {
  const SignupCompletePage({super.key});

  @override
  ConsumerState<SignupCompletePage> createState() => _SignupCompletePageState();
}

class _SignupCompletePageState extends ConsumerState<SignupCompletePage> {
  Timer? _redirectTimer;
  int _countdown = 5;

  static const _checkSmallIcon = 'assets/images/icon/check_small.svg';
  static const _checkSmallPremiumIcon = 'assets/images/icon/check_small_premium.svg';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).completeSignup();
    });
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _cancelRedirect();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        _cancelRedirect();
        context.go('/trend');
      }
    });
  }

  void _cancelRedirect() {
    _redirectTimer?.cancel();
    _redirectTimer = null;
  }

  @override
  void dispose() {
    _cancelRedirect();
    super.dispose();
  }

  Widget _benefitRow({
    required String iconAsset,
    required String text,
    required Color textColor,
    required TsSemanticColors semantic,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: 24,
          height: 24,
          placeholderBuilder: (_) => Icon(
            Icons.check_circle,
            size: 24,
            color: textColor == semantic.textSecondary
                ? semantic.textSecondary
                : semantic.interactivePrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TsType.bodyLRegular.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _benefitsCard({
    required TsSemanticColors semantic,
    required String header,
    required Color headerColor,
    required String iconAsset,
    required Color textColor,
    required List<String> benefits,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TsType.bodyLRegular.copyWith(color: headerColor),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < benefits.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _benefitRow(
              iconAsset: iconAsset,
              text: benefits[i],
              textColor: textColor,
              semantic: semantic,
            ),
          ],
        ],
      ),
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
          onPressed: () {
            _cancelRedirect();
            context.pop();
          },
        ),
        title: Text(
          '가입완료',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: semantic.interactivePrimary,
              ),
              const SizedBox(height: 16),
              Text(
                '환영합니다 !',
                style: TsType.displayHero.copyWith(color: semantic.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '지금 트렌드사커를 시작해 보세요.',
                style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: semantic.interactivePrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: semantic.interactivePrimary, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  '48시간 프리미엄 체험이 시작되었습니다 !',
                  style: TsType.bodyLRegular.copyWith(color: semantic.interactivePrimary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              _benefitsCard(
                semantic: semantic,
                header: '무료 혜택',
                headerColor: semantic.textPrimary,
                iconAsset: _checkSmallIcon,
                textColor: semantic.textSecondary,
                benefits: const [
                  '경기 시작 2시간 전 분석 오픈',
                  '기본 분석 데이터 제공',
                  '실시간 스코어 및 경기 일정',
                ],
              ),
              const SizedBox(height: 16),
              _benefitsCard(
                semantic: semantic,
                header: '프리미엄 혜택',
                headerColor: semantic.interactivePrimary,
                iconAsset: _checkSmallPremiumIcon,
                textColor: semantic.textPrimary,
                benefits: const [
                  '24시간 우선 분석 접근',
                  'PREMIUM PICK 무제한',
                  '야구 AI Analysis',
                ],
              ),
              const SizedBox(height: 16),
              TsButton(
                label: '프리미엄 업그레이드',
                variant: TsButtonVariant.primary,
                onPressed: () {
                  _cancelRedirect();
                  context.push('/menu/subscribe');
                },
              ),
              const SizedBox(height: 16),
              Text(
                '$_countdown초 후 자동으로 홈으로 이동합니다.',
                style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
