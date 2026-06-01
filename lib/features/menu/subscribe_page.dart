import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/services/iap_service.dart';
import 'package:trendsoccer/core/services/payment_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/menu/payment_webview_page.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/loading/ts_loading_overlay.dart';
import 'package:trendsoccer/shared/widgets/navigation/ts_bottom_navigation.dart';

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

  String get _selectedPlan => _selectedPlanIndex == 0 ? 'quarterly' : 'monthly';

  String get _selectedProductId => _selectedPlanIndex == 0
      ? IAPService.premiumQuarterly
      : IAPService.premiumMonthly;

  int get _successMonths => _selectedPlanIndex == 0 ? 3 : 1;

  void _handleBack(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/trend');
    }
  }

  Map<String, dynamic>? _extractFormData(Map<String, dynamic> initResponse) {
    final root = initResponse['formData'];
    if (root is Map<String, dynamic>) {
      return root;
    }
    if (root is Map) {
      return Map<String, dynamic>.from(root);
    }

    final data = initResponse['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['formData'];
      if (nested is Map<String, dynamic>) return nested;
      if (nested is Map) return Map<String, dynamic>.from(nested);
    } else if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      final nested = dataMap['formData'];
      if (nested is Map<String, dynamic>) return nested;
      if (nested is Map) return Map<String, dynamic>.from(nested);
    }

    return null;
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
    final productId = _selectedProductId;

    debugPrint('[IAP] subscribe page: productId=$productId');

    if (!iap.isAvailable) {
      debugPrint('[IAP] subscribe page: store not available — fallback SeedPay');
      return _IapAttemptResult.unavailable;
    }

    if (iap.findProduct(productId) == null) {
      debugPrint('[IAP] subscribe page: product not loaded — fallback SeedPay');
      return _IapAttemptResult.unavailable;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadingMessage = 'Google Play 결제 준비 중...';
      });
    }

    final purchaseFuture = _waitForIapPurchaseResult(iap);
    final initiated = await iap.buySubscription(productId);
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

  Future<void> _startSeedPayPayment() async {
    final plan = _selectedPlan;
    final auth = ref.read(authProvider);
    var userEmail = auth.userEmail;

    if (userEmail.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('user_email') ?? '';
    }

    if (userEmail.isEmpty) {
      await auth.loadProfile();
      userEmail = auth.userEmail;
    }

    if (userEmail.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제 초기화에 실패했습니다. 다시 시도해주세요.')),
      );
      return;
    }

    final paymentService = ref.read(paymentServiceProvider);

    setState(() {
      _isLoading = true;
      _loadingMessage = null;
    });

    final initResponse = await paymentService.initPayment(plan: plan);

    if (initResponse['success'] != true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제 초기화에 실패했습니다. 다시 시도해주세요.')),
      );
      return;
    }

    final formData = _extractFormData(initResponse);
    if (formData == null || formData.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제 정보를 불러오지 못했습니다.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });

    final paymentComplete = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentWebViewPage(formData: formData),
      ),
    );

    if (!mounted) return;

    if (paymentComplete != true) {
      context.push('/menu/subscribe/fail');
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = '결제 확인 중...';
    });

    var pollEmail = userEmail;
    if (pollEmail.isEmpty) {
      pollEmail = auth.userEmail;
    }
    if (pollEmail.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      pollEmail = prefs.getString('user_email') ?? '';
    }

    if (pollEmail.isEmpty) {
      if (!mounted) return;
      context.push('/menu/subscribe/fail');
      return;
    }

    final pollOk = await paymentService.pollSubscription(email: pollEmail);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });

    if (pollOk) {
      await ref.read(authProvider).loadProfile();
    }

    if (!mounted) return;
    if (pollOk) {
      context.push('/menu/subscribe/success', extra: _successMonths);
    } else {
      context.push('/menu/subscribe/fail');
    }
  }

  Future<void> _startPremium() async {
    print('[PAYMENT] === Button pressed ===');
    print('[PAYMENT] isProcessing=$_isProcessing');

    if (_isProcessing) {
      print('[PAYMENT] Step 0: early return — already processing');
      return;
    }
    print('[PAYMENT] Step 0: setting isProcessing=true');
    setState(() => _isProcessing = true);

    try {
      print('[PAYMENT] Step 1: checking login');
      if (!ref.read(authProvider).isLoggedIn) {
        print('[PAYMENT] Step 1a: not logged in — pushing /login');
        context.push('/login');
        return;
      }

      print('[PAYMENT] Step 2: trying Google Play IAP (primary)');
      final iapResult = await _startGooglePlayPurchase();
      if (iapResult == _IapAttemptResult.success) {
        print('[PAYMENT] Step 2: IAP purchase completed');
        return;
      }
      if (iapResult == _IapAttemptResult.canceled ||
          iapResult == _IapAttemptResult.verifyPending) {
        print('[PAYMENT] Step 2: IAP canceled or verify pending — staying on page');
        return;
      }
      if (iapResult == _IapAttemptResult.failed) {
        print('[PAYMENT] Step 2: IAP failed — navigated to fail page');
        return;
      }

      print('[PAYMENT] Step 3: falling back to SeedPay');
      await _startSeedPayPayment();
    } on ApiException catch (e, stackTrace) {
      print('[PAYMENT] CATCH ERROR (ApiException): $e');
      final stackStr = stackTrace.toString();
      print(
        '[PAYMENT] CATCH STACK: ${stackStr.substring(0, min(500, stackStr.length))}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e, stackTrace) {
      print('[PAYMENT] CATCH ERROR: $e');
      final stackStr = stackTrace.toString();
      print(
        '[PAYMENT] CATCH STACK: ${stackStr.substring(0, min(500, stackStr.length))}',
      );
      if (mounted) {
        final message = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '결제 초기화에 실패했습니다: ${message.substring(0, min(100, message.length))}',
            ),
          ),
        );
      }
    } finally {
      print('[PAYMENT] FINALLY: resetting isProcessing');
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
      print('[PAYMENT] FINALLY: done');
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

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
              '구독',
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
        child: Column(
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
        ),
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
