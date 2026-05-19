import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/back_button.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class SubscribeFailPage extends StatelessWidget {
  const SubscribeFailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: AppBar(
        backgroundColor: semantic.surfaceBase,
        elevation: 0,
        leading: TsBackButton(onPressed: () => context.pop()),
        title: Text(
          '결제 실패',
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TsColors.systemWarning500,
                ),
                child: SvgPicture.asset(
                  TsAssets.iconWarning,
                  width: 40,
                  height: 40,
                  colorFilter: ColorFilter.mode(
                    semantic.surfaceBase,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                '결제에 실패했습니다.',
                style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '다시 시도하거나 다른 결제 수단을 이용해주세요.',
                style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: semantic.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 시도 금액',
                          style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                        ),
                        Text('₩ 4,900', style: TsType.headingH3.copyWith(color: semantic.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Opacity(
                      opacity: 0.3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '오류 코드',
                            style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                          ),
                          Text(
                            'ERR_PAYMENT_01',
                            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: TsButton(
                  label: '다시 시도하기',
                  variant: TsButtonVariant.primary,
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TsButton(
                  label: '홈으로 돌아가기',
                  variant: TsButtonVariant.secondary,
                  onPressed: () => context.go('/trend'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
