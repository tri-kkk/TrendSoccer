import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
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
      print('[PAYMENT] Step 1: getting selected plan');
      final plan = _selectedPlan;
      print('[PAYMENT] Step 2: plan=$plan');

      print('[PAYMENT] Step 3: checking login');
      if (!ref.read(authProvider).isLoggedIn) {
        print('[PAYMENT] Step 3a: not logged in — pushing /login');
        context.push('/login');
        return;
      }
      print('[PAYMENT] Step 4: user is logged in');

      print('[PAYMENT] Step 5: resolving user email');
      final auth = ref.read(authProvider);
      var userEmail = auth.userEmail;
      print('[PAYMENT] Step 5a: auth.userEmail length=${userEmail.length}');

      if (userEmail.isEmpty) {
        print('[PAYMENT] Step 5b: trying SharedPreferences');
        final prefs = await SharedPreferences.getInstance();
        userEmail = prefs.getString('user_email') ?? '';
        print('[PAYMENT] Step 5c: prefs email length=${userEmail.length}');
      }

      if (userEmail.isEmpty) {
        print('[PAYMENT] Step 5d: calling loadProfile');
        await auth.loadProfile();
        userEmail = auth.userEmail;
        print('[PAYMENT] Step 5e: after loadProfile email length=${userEmail.length}');
      }

      print('[PAYMENT] Step 6: email=$userEmail');

      print('[PAYMENT] Step 7: reading paymentServiceProvider');
      final paymentService = ref.read(paymentServiceProvider);
      print(
        '[PAYMENT] Step 8: paymentService obtained, type=${paymentService.runtimeType}',
      );

      print('[PAYMENT] Step 9: setState loading overlay on');
      setState(() {
        _isLoading = true;
        _loadingMessage = null;
      });
      print('[PAYMENT] Step 10: loading overlay set');

      print('[PAYMENT] Step 11: calling initPayment');
      final initResponse = await paymentService.initPayment(plan: plan);
      print(
        '[PAYMENT] Step 12: initPayment returned, success=${initResponse['success']}',
      );

      print('[PAYMENT] Step 13: checking init success flag');
      if (initResponse['success'] != true) {
        print('[PAYMENT] Step 13a: init failed — showing snackbar');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('결제 초기화에 실패했습니다. 다시 시도해주세요.')),
        );
        return;
      }
      print('[PAYMENT] Step 14: init success confirmed');

      print('[PAYMENT] Step 15: extracting formData');
      final formData = _extractFormData(initResponse);
      print('[PAYMENT] Step 16: formData keys=${formData?.keys.toList()}');
      if (formData == null || formData.isEmpty) {
        print('[PAYMENT] Step 16a: formData missing — showing snackbar');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('결제 정보를 불러오지 못했습니다.')),
        );
        return;
      }

      print('[PAYMENT] Step 17: checking mounted before webview');
      if (!mounted) return;
      print('[PAYMENT] Step 18: setState loading overlay off before webview');
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      print('[PAYMENT] Step 19: pushing PaymentWebViewPage');

      final paymentComplete = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PaymentWebViewPage(formData: formData),
        ),
      );
      print('[PAYMENT] Step 20: webview returned, paymentComplete=$paymentComplete');

      print('[PAYMENT] Step 21: checking mounted after webview');
      if (!mounted) return;

      if (paymentComplete != true) {
        print('[PAYMENT] Step 22a: payment not complete — pushing fail');
        context.push('/menu/subscribe/fail');
        return;
      }
      print('[PAYMENT] Step 22: payment complete — starting poll');

      print('[PAYMENT] Step 23: setState poll loading');
      setState(() {
        _isLoading = true;
        _loadingMessage = '결제 확인 중...';
      });
      print('[PAYMENT] Step 24: resolving email for pollSubscription');
      var pollEmail = userEmail;
      if (pollEmail.isEmpty) {
        pollEmail = auth.userEmail;
      }
      if (pollEmail.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        pollEmail = prefs.getString('user_email') ?? '';
      }
      print('[PAYMENT] Step 24a: pollEmail=$pollEmail');

      if (pollEmail.isEmpty) {
        print('[PAYMENT] Step 24b: no email for poll — cannot verify subscription');
        if (!mounted) return;
        context.push('/menu/subscribe/fail');
        return;
      }

      print('[PAYMENT] Step 24c: calling pollSubscription');
      final pollOk = await paymentService.pollSubscription(email: pollEmail);
      print('[PAYMENT] Step 25: pollSubscription returned, pollOk=$pollOk');

      print('[PAYMENT] Step 26: checking mounted after poll');
      if (!mounted) return;
      print('[PAYMENT] Step 27: setState loading overlay off after poll');
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });

      if (pollOk) {
        print('[PAYMENT] Step 28: poll ok — loading profile');
        await ref.read(authProvider).loadProfile();
        print('[PAYMENT] Step 29: profile loaded');
      } else {
        print('[PAYMENT] Step 28: poll failed — skipping profile load');
      }

      print('[PAYMENT] Step 30: checking mounted before navigation');
      if (!mounted) return;
      if (pollOk) {
        print('[PAYMENT] Step 31: pushing success page');
        context.push('/menu/subscribe/success', extra: _successMonths);
      } else {
        print('[PAYMENT] Step 31: pushing fail page');
        context.push('/menu/subscribe/fail');
      }
      print('[PAYMENT] Step 32: payment flow complete');
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
