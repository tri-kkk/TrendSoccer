import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/services/iap_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/loading/ts_loading_overlay.dart';
import 'package:trendsoccer/shared/widgets/navigation/ts_bottom_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscribePage extends ConsumerStatefulWidget {
  const SubscribePage({super.key});

  @override
  ConsumerState<SubscribePage> createState() => _SubscribePageState();
}

enum _IapAttemptResult { success, unavailable, failed, canceled, verifyPending }

enum _IapPurchaseOutcome { success, fail, canceled, verifyPending }

class _SubscribePageState extends ConsumerState<SubscribePage> {
  static const _tabPaths = [
    '/trend',
    '/analysis',
    '/fixture',
    '/premium',
    '/menu',
  ];

  /// 0 = quarterly (3개월), 1 = monthly (1개월)
  int _selectedPlanIndex = 0;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _loadingMessage;

  String get _selectedBasePlanId => _selectedPlanIndex == 0
      ? IAPService.quarterlyPlan
      : IAPService.monthlyPlan;

  int get _successMonths => _selectedPlanIndex == 0 ? 3 : 1;

  void _handleBack(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/trend');
    }
  }

  String _formatTrialRemaining(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return '남은 시간: 0시간 0분';
    }
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    return '남은 시간: $hours시간 $minutes분';
  }

  String _formatPremiumExpires(DateTime expiresAt) {
    final month = expiresAt.month.toString().padLeft(2, '0');
    final day = expiresAt.day.toString().padLeft(2, '0');
    return '만료일: ${expiresAt.year}.$month.$day';
  }

  Future<void> _openGooglePlaySubscriptions() async {
    final uri = Uri.parse('https://play.google.com/store/account/subscriptions');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool _isVerifyPendingError(String message) {
    return message.contains('GOOGLE_VERIFY_FAILED') ||
        message.contains('Purchase verification failed') ||
        message.contains('Purchase restore verification failed');
  }

  Future<void> _navigateIapSuccess() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = '구독 정보 업데이트 중...';
    });
    await ref.read(authProvider).loadProfile();
    if (!mounted) return;
    context.go('/menu/subscribe/success', extra: _successMonths);
  }

  void _navigateIapFail() {
    context.go('/menu/subscribe/fail');
  }

  void _showVerifyPendingSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '결제는 완료되었으나 검증 대기 중입니다. 잠시 후 앱을 재시작해주세요.',
        ),
      ),
    );
  }

  Future<_IapPurchaseOutcome> _waitForIapPurchaseResult(IAPService iap) async {
    final completer = Completer<_IapPurchaseOutcome>();
    late StreamSubscription<IapPurchaseEvent> subscription;

    subscription = iap.purchaseEvents.listen((event) {
      switch (event.type) {
        case IapPurchaseEventType.pending:
          if (mounted) {
            setState(() {
              _isLoading = true;
              _loadingMessage = 'Google Play 결제 처리 중...';
            });
          }
        case IapPurchaseEventType.purchased:
        case IapPurchaseEventType.restored:
          if (!completer.isCompleted) {
            completer.complete(_IapPurchaseOutcome.success);
          }
        case IapPurchaseEventType.itemAlreadyOwned:
          if (mounted) {
            setState(() {
              _isLoading = true;
              _loadingMessage = '기존 구독 확인 중...';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('이미 구독 중입니다. 기존 구독을 확인합니다.'),
              ),
            );
          }
          unawaited(iap.restoreAndVerify());
        case IapPurchaseEventType.error:
          final message = event.message ?? '';
          if (message.contains('itemAlreadyOwned') ||
              message.contains('AlreadyOwned')) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _loadingMessage = '기존 구독 확인 중...';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('이미 구독 중입니다. 기존 구독을 확인합니다.'),
                ),
              );
            }
            unawaited(iap.restoreAndVerify());
            return;
          }
          if (_isVerifyPendingError(message)) {
            if (!completer.isCompleted) {
              completer.complete(_IapPurchaseOutcome.verifyPending);
            }
            return;
          }
          if (!completer.isCompleted) {
            completer.complete(_IapPurchaseOutcome.fail);
          }
        case IapPurchaseEventType.canceled:
          if (!completer.isCompleted) {
            completer.complete(_IapPurchaseOutcome.canceled);
          }
      }
    });

    try {
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          debugPrint('[IAP] purchase wait timed out');
          return _IapPurchaseOutcome.fail;
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  Future<_IapAttemptResult> _startGooglePlayPurchase() async {
    final iap = ref.read(iapServiceProvider);
    final basePlanId = _selectedBasePlanId;

    debugPrint(
      '[IAP] subscribe page: productId=${IAPService.premium}, '
      'basePlanId=$basePlanId',
    );

    if (!iap.isAvailable) {
      debugPrint('[IAP] subscribe page: store not available');
      return _IapAttemptResult.unavailable;
    }

    if (!iap.hasProduct(IAPService.premium)) {
      debugPrint('[IAP] subscribe page: product not loaded');
      return _IapAttemptResult.unavailable;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadingMessage = 'Google Play 결제 준비 중...';
      });
    }

    final purchaseFuture = _waitForIapPurchaseResult(iap);
    final initiated = await iap.buySubscription(basePlanId);
    if (!initiated) {
      debugPrint('[IAP] subscribe page: buySubscription failed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Play 결제를 시작할 수 없습니다.'),
          ),
        );
      }
      return _IapAttemptResult.canceled;
    }

    final outcome = await purchaseFuture;
    if (!mounted) return _IapAttemptResult.failed;

    switch (outcome) {
      case _IapPurchaseOutcome.success:
        await _navigateIapSuccess();
        return _IapAttemptResult.success;
      case _IapPurchaseOutcome.fail:
        _navigateIapFail();
        return _IapAttemptResult.failed;
      case _IapPurchaseOutcome.canceled:
        return _IapAttemptResult.canceled;
      case _IapPurchaseOutcome.verifyPending:
        if (mounted) {
          _showVerifyPendingSnackBar();
        }
        return _IapAttemptResult.verifyPending;
    }
  }

  Future<void> _startPremium() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      if (!ref.read(authProvider).isLoggedIn) {
        context.push('/login');
        return;
      }

      final iapResult = await _startGooglePlayPurchase();
      switch (iapResult) {
        case _IapAttemptResult.success:
        case _IapAttemptResult.canceled:
        case _IapAttemptResult.verifyPending:
        case _IapAttemptResult.failed:
          return;
        case _IapAttemptResult.unavailable:
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Play 결제를 사용할 수 없습니다.'),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isLoading = false;
          _loadingMessage = null;
        });
      } else {
        _isProcessing = false;
        _isLoading = false;
        _loadingMessage = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final auth = ref.watch(authProvider);
    final planType = auth.planType;
    final appBarTitle = planType == PlanType.premium ? '구독 관리' : '구독';

    return TsLoadingOverlay(
      isLoading: _isLoading,
      message: _loadingMessage,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleBack(context);
        },
        child: Scaffold(
          backgroundColor: semantic.surfaceBase,
          appBar: AppBar(
            backgroundColor: semantic.surfaceBase,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
              onPressed: () => _handleBack(context),
            ),
            iconTheme: IconThemeData(color: semantic.textPrimary),
            title: Text(
              appBarTitle,
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
              top: 24,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: switch (planType) {
              PlanType.trial => _buildTrialStatusContent(context, semantic, auth),
              PlanType.premium =>
                _buildPremiumStatusContent(context, semantic, auth),
              PlanType.free || PlanType.none =>
                _buildPurchaseContent(semantic),
            },
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: TsBottomNavigation(
              currentIndex: 4,
              onTap: (index) => context.go(_tabPaths[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrialStatusContent(
    BuildContext context,
    TsSemanticColors semantic,
    SupabaseAuthProvider auth,
  ) {
    final trialExpiresAt = auth.trialExpiresAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            TsAssets.iconPremium,
            width: 64,
            height: 64,
            colorFilter: ColorFilter.mode(
              semantic.interactivePrimary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '48시간 프리미엄 체험 중',
            style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '체험 기간 종료 후 구독할 수 있습니다.',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (trialExpiresAt != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatTrialRemaining(trialExpiresAt),
              style: TsType.bodyMBold.copyWith(
                color: semantic.interactivePrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TsButton(
              label: '돌아가기',
              variant: TsButtonVariant.secondary,
              onPressed: () => _handleBack(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatusContent(
    BuildContext context,
    TsSemanticColors semantic,
    SupabaseAuthProvider auth,
  ) {
    final premiumExpiresAt = auth.premiumExpiresAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            TsAssets.iconPremium,
            width: 64,
            height: 64,
            colorFilter: ColorFilter.mode(
              semantic.interactivePrimary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '프리미엄 구독 중',
            style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '현재 프리미엄 구독을 이용 중입니다.',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (premiumExpiresAt != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatPremiumExpires(premiumExpiresAt),
              style: TsType.bodyMBold.copyWith(color: semantic.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TsButton(
              label: 'Google Play에서 구독 관리',
              variant: TsButtonVariant.primary,
              onPressed: _openGooglePlaySubscriptions,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TsButton(
              label: '돌아가기',
              variant: TsButtonVariant.secondary,
              onPressed: () => _handleBack(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseContent(TsSemanticColors semantic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get Full Access To',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'The AI Assistant !',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          semantic: semantic,
          title: '무료',
          titleColor: semantic.textPrimary,
          bgColor: semantic.surfaceRaised,
          borderColor: null,
          dividerColor: semantic.borderSubtle,
          benefits: [
            '분석 카드 킥오프 2시간 전 공개',
            '기본 경기 분석 및 통계',
            '실시간 스코어 및 경기 일정',
            '광고 포함',
          ],
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          semantic: semantic,
          title: '프리미엄',
          titleColor: semantic.interactivePrimary,
          bgColor: semantic.interactivePrimary.withValues(alpha: 0.1),
          borderColor: semantic.interactivePrimary,
          dividerColor: semantic.interactivePrimary.withValues(alpha: 0.2),
          benefits: [
            '모든 분석 24시간 우선 접근',
            '축구 프리미엄픽 무제한',
            'AI 야구 분석 전체 공개',
            '야구 조합 픽',
            '광고 없는 경험',
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '구독 상품 선택',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: 12),
        _buildPlanOption(
          semantic: semantic,
          price: '₩ 9,900',
          period: '3개월',
          isSelected: _selectedPlanIndex == 0,
          discountLabel: '33% OFF',
          onTap: () => setState(() => _selectedPlanIndex = 0),
        ),
        const SizedBox(height: 12),
        _buildPlanOption(
          semantic: semantic,
          price: '₩ 4,900',
          period: '1개월',
          isSelected: _selectedPlanIndex == 1,
          discountLabel: null,
          onTap: () => setState(() => _selectedPlanIndex = 1),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TsButton(
            label: '프리미엄 구독 시작하기 →',
            variant: TsButtonVariant.primary,
            onPressed: _startPremium,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPlanCard({
    required TsSemanticColors semantic,
    required String title,
    required Color titleColor,
    required Color bgColor,
    required Color? borderColor,
    required Color dividerColor,
    required List<String> benefits,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TsType.headingH3.copyWith(color: titleColor)),
          const SizedBox(height: 16),
          Container(height: 1, color: dividerColor),
          const SizedBox(height: 16),
          ...benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    TsAssets.iconCheckboxChecked,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      semantic.interactivePrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      b,
                      style: TsType.bodyLRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption({
    required TsSemanticColors semantic,
    required String price,
    required String period,
    required bool isSelected,
    required String? discountLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? semantic.interactivePrimary.withValues(alpha: 0.2)
              : semantic.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(color: semantic.interactivePrimary, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? semantic.interactivePrimary
                      : semantic.borderDefault,
                  width: 2,
                ),
              ),
              child: isSelected
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
            const SizedBox(width: 16),
            Text(
              price,
              style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(width: 8),
            Text(
              period,
              style: TsType.labelSRegular.copyWith(
                color: semantic.textTertiary,
              ),
            ),
            const Spacer(),
            if (discountLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: semantic.interactivePrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  discountLabel,
                  style: TsType.bodyMBold.copyWith(
                    color: semantic.interactivePrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
