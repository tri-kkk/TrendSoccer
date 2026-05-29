import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

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
    if (_isProcessing) return;

    if (!ref.read(authProvider).isLoggedIn) {
      context.push('/login');
      return;
    }

    final email = ref.read(authProvider).userEmail;
    if (email.isEmpty) {
      TsToast.error(context, '결제 초기화에 실패했습니다. 다시 시도해주세요.');
      return;
    }

    _isProcessing = true;
    print('[PAYMENT] Starting payment: plan=$_selectedPlan');

    setState(() {
      _isLoading = true;
      _loadingMessage = null;
    });

    try {
      final initResponse = await ref
          .read(paymentServiceProvider)
          .initPayment(plan: _selectedPlan);

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

      final pollOk = await ref
          .read(paymentServiceProvider)
          .pollSubscription(email: email);

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
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제 초기화에 실패했습니다. 다시 시도해주세요.')),
      );
    } finally {
      _isProcessing = false;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
        });
      }
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
