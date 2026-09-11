import 'dart:async';



import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';



import 'package:trendsoccer/core/models/auth_state.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';

import 'package:trendsoccer/core/services/iap_service.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';

import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';

import 'package:trendsoccer/design_system/tokens/ts_type.dart';

import 'package:trendsoccer/features_v2/menu/payment_route_args.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';

import 'package:trendsoccer/design_system/widgets/ts_button.dart';

import 'package:trendsoccer/design_system/widgets/ts_plan_card.dart';

import 'package:trendsoccer/design_system/widgets/ts_plan_option.dart';

import 'package:trendsoccer/design_system/widgets/ts_toast.dart';

import 'package:trendsoccer/l10n/app_localizations.dart';



class SubscribeScreen extends ConsumerStatefulWidget {

  const SubscribeScreen({super.key});



  @override

  ConsumerState<SubscribeScreen> createState() => _SubscribeScreenState();

}



class _SubscribeScreenState extends ConsumerState<SubscribeScreen> {

  static const _pricePlaceholder = '—';



  String? _selectedBasePlanId = IAPService.quarterlyPlan;

  bool _iapReady = false;

  bool _storeAvailable = false;

  bool _productsLoaded = false;

  bool _purchasing = false;

  StreamSubscription<IapPurchaseEvent>? _purchaseEventsSub;



  @override

  void initState() {

    super.initState();

    final iap = ref.read(iapServiceProvider);

    _purchaseEventsSub = iap.purchaseEvents.listen(_onPurchaseEvent);

    unawaited(_waitForStore());

  }



  @override

  void dispose() {

    unawaited(_purchaseEventsSub?.cancel());

    super.dispose();

  }



  Future<void> _waitForStore() async {

    final iap = ref.read(iapServiceProvider);

    await iap.ready;

    if (!mounted) return;

    setState(() {

      _iapReady = true;

      _storeAvailable = iap.isAvailable && iap.initSucceeded;

      _productsLoaded = iap.initSucceeded;

    });

  }



  static bool _isVerificationFailure(IapPurchaseEvent event) {
    final message = event.message;
    return message == 'Purchase verification failed' ||
        message == 'Purchase restore verification failed';
  }

  void _onPurchaseEvent(IapPurchaseEvent event) {

    if (!mounted) return;

    final l10n = context.l10n;



    switch (event.type) {

      case IapPurchaseEventType.pending:

        setState(() => _purchasing = true);

      case IapPurchaseEventType.purchased:

      case IapPurchaseEventType.restored:

        setState(() => _purchasing = false);

        context.pushReplacement(
          '/menu/payment/success',
          extra: PaymentSuccessArgs(
            basePlanId: event.basePlanId,
            storePrice: event.storePrice,
          ),
        );

      case IapPurchaseEventType.itemAlreadyOwned:

        setState(() => _purchasing = false);

        showTsToast(context, l10n.subscribeAlreadyOwned, TsToastType.info);

      case IapPurchaseEventType.canceled:

        setState(() => _purchasing = false);

      case IapPurchaseEventType.error:

        setState(() => _purchasing = false);

        if (_isVerificationFailure(event)) {
          showTsToast(
            context,
            l10n.subscribeIapVerifyPending,
            TsToastType.info,
          );
        } else {
          context.pushReplacement(
            '/menu/payment/failed',
            extra: PaymentFailedArgs(purchaseId: event.purchaseId),
          );
        }

    }

  }



  String? _priceForBasePlan(IAPService iap, String basePlanId) {

    return iap.findProductForBasePlan(basePlanId)?.price;

  }



  bool _canStartPurchase(PlanType planType) {

    if (!_iapReady || !_storeAvailable || !_productsLoaded) return false;

    if (_purchasing) return false;

    if (planType == PlanType.premium) return false;

    if (planType == PlanType.trial) return false;

    if (_selectedBasePlanId == null) return false;

    final iap = ref.read(iapServiceProvider);

    return iap.findProductForBasePlan(_selectedBasePlanId!) != null;

  }



  Future<void> _onCtaPressed() async {

    final basePlanId = _selectedBasePlanId;

    if (basePlanId == null) return;



    final iap = ref.read(iapServiceProvider);

    setState(() => _purchasing = true);

    final started = await iap.buySubscription(basePlanId);

    if (!mounted) return;

    if (!started) {

      setState(() => _purchasing = false);

      showTsToast(

        context,

        context.l10n.subscribeIapCannotStart,

        TsToastType.error,

      );

    }

  }



  String _ctaLabel(AppLocalizations l10n, PlanType planType) {

    if (!_iapReady) {

      return l10n.subscribeIapPreparing;

    }

    if (!_storeAvailable || !_productsLoaded) {

      return l10n.subscribeIapUnavailable;

    }

    if (planType == PlanType.premium) {

      return l10n.subscribePremiumActive;

    }

    if (planType == PlanType.trial) {

      return l10n.subscribeTrialMessage;

    }

    if (_purchasing) {

      return l10n.subscribeIapProcessing;

    }

    if (_selectedBasePlanId == null) {

      return l10n.subscribeSelectProduct;

    }

    return l10n.subscribeStartPremium;

  }



  @override

  Widget build(BuildContext context) {

    final c = Theme.of(context).extension<TsThemeColors>()!;

    final l10n = context.l10n;

    final auth = ref.watch(authProvider);

    final planType = auth.planType;

    final iap = ref.watch(iapServiceProvider);



    final quarterlyPrice =

        _productsLoaded ? _priceForBasePlan(iap, IAPService.quarterlyPlan) : null;

    final monthlyPrice =

        _productsLoaded ? _priceForBasePlan(iap, IAPService.monthlyPlan) : null;



    final ctaEnabled = _canStartPurchase(planType);



    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const topPad = TsSpacing.lg;
    final bottomPad = TsSpacing.lg + bottomInset;

    return Scaffold(

      backgroundColor: c.canvas,

      appBar: TsAppBar(

        type: TsAppBarType.back,

        title: l10n.menuSubscribeInfoSection,

        onBack: _onBack,

      ),

      body: SingleChildScrollView(

        padding: EdgeInsets.fromLTRB(

          topPad,

          topPad,

          topPad,

          bottomPad,

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

                  Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        l10n.subscribeUnlockTitle,

                        style: TsType.h2.copyWith(color: c.textPrimary),

                      ),

                      const SizedBox(height: TsSpacing.sm),

                      Text(

                        l10n.subscribeUnlockSubtitle,

                        style: TsType.bodyLRegular.copyWith(color: c.textSecondary),

                      ),

                    ],

                  ),

                  const SizedBox(height: TsSpacing.lg),

                  TsPlanCard(

                    tier: TsPlanTier.free,

                    titleLabel: l10n.subscribePlanFree,

                    benefits: [

                      l10n.subscribeFreeBenefit1,

                      l10n.subscribeFreeBenefit2,

                      l10n.subscribeFreeBenefit3,

                      l10n.subscribeFreeBenefit4,

                    ],

                  ),

                  const SizedBox(height: TsSpacing.md),

                  TsPlanCard(

                    tier: TsPlanTier.premium,

                    titleLabel: l10n.subscribePlanPremium,

                    benefits: [

                      l10n.subscribePremiumBenefit1,

                      l10n.subscribePremiumBenefit2,

                      l10n.subscribePremiumBenefit3,

                      l10n.subscribePremiumBenefit4,

                      l10n.subscribePremiumBenefit5,

                    ],

                  ),

                  const SizedBox(height: TsSpacing.lg),

                  TsPlanOption(

                    period: l10n.subscribePlanQuarterly,

                    price: quarterlyPrice ?? _pricePlaceholder,

                    priceNote: l10n.subscribeQuarterlyPriceNote,

                    selected: _selectedBasePlanId == IAPService.quarterlyPlan,

                    discountLabel: l10n.subscribeDiscount,

                    onTap: _storeAvailable && quarterlyPrice != null

                        ? () => setState(

                              () => _selectedBasePlanId = IAPService.quarterlyPlan,

                            )

                        : null,

                  ),

                  const SizedBox(height: TsSpacing.md),

                  TsPlanOption(

                    period: l10n.subscribePlanMonthly,

                    price: monthlyPrice ?? _pricePlaceholder,

                    selected: _selectedBasePlanId == IAPService.monthlyPlan,

                    onTap: _storeAvailable && monthlyPrice != null

                        ? () => setState(

                              () => _selectedBasePlanId = IAPService.monthlyPlan,

                            )

                        : null,

                  ),

                  const SizedBox(height: TsSpacing.lg),

                  TsButton(

                    label: _ctaLabel(l10n, planType),

                    expand: true,

                    onPressed: ctaEnabled ? _onCtaPressed : null,

                  ),

                  const SizedBox(height: TsSpacing.sm),

                  Text(

                    l10n.subscribeTermsAutoRenew,

                    style: TsType.labelSRegular.copyWith(color: c.textTertiary),

                    textAlign: TextAlign.center,

                  ),

          ],

        ),

      ),

    );

  }



  void _onBack() {

    if (context.canPop()) {

      context.pop();

      return;

    }

    context.go('/menu');

  }

}


