import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class SubscribeSuccessPage extends StatelessWidget {
  const SubscribeSuccessPage({super.key});

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
          '구독 완료',
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
                  color: semantic.interactivePrimary,
                ),
                child: Icon(Icons.rocket_launch, size: 40, color: semantic.surfaceBase),
              ),
              const SizedBox(height: 48),
              Text(
                '구독이 완료되었습니다.',
                style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '지금 바로 프리미엄 혜택을 이용해보세요.',
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
                          '결제 금액',
                          style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                        ),
                        Text('₩ 9,900', style: TsType.headingH3.copyWith(color: semantic.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Opacity(
                      opacity: 0.3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '구독 플랜',
                            style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                          ),
                          Text('3개월', style: TsType.headingH3.copyWith(color: semantic.textPrimary)),
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
                  label: '프리미엄 확인하기',
                  variant: TsButtonVariant.primary,
                  onPressed: () => context.go('/premium'),
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
