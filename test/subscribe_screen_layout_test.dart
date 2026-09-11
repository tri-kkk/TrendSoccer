import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/services/iap_service.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_plan_option.dart';
import 'package:trendsoccer/features_v2/menu/subscribe_screen.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

/// Typical Android gesture inset on a tall phone (412 logical width class).
const _deviceLikePadding = EdgeInsets.fromLTRB(0, 47, 0, 34);

class _TestIap extends IAPService {
  _TestIap() : super(null);

  @override
  Future<void> get ready async {}

  @override
  bool get isAvailable => true;

  @override
  bool get initSucceeded => true;
}

class _TestAuth extends SupabaseAuthProvider {
  _TestAuth(super.ref);

  @override
  PlanType get planType => PlanType.free;
}

Future<void> pumpSubscribe(
  WidgetTester tester,
  Size size, {
  EdgeInsets padding = EdgeInsets.zero,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        iapServiceProvider.overrideWithValue(_TestIap()),
        authProvider.overrideWith((ref) => _TestAuth(ref)),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTsTheme(Brightness.dark),
        home: MediaQuery(
          data: MediaQueryData(size: size, padding: padding),
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: const SubscribeScreen(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Finder get _headlineTitle => find.text('Unlock every analysis report');

Finder get _terms => find.textContaining('Auto-renews');

Finder get _quarterlyOption => find.byType(TsPlanOption).first;

Finder get _monthlyOption => find.byType(TsPlanOption).last;

double _optionHeight(WidgetTester tester, Finder option) {
  final box = tester.renderObject<RenderBox>(option);
  return box.size.height;
}

Finder get _cta => find.descendant(
      of: find.byType(SubscribeScreen),
      matching: find.byType(TsButton),
    );

double _gapMonthlyToCta(WidgetTester tester) {
  final monthlyBottom = tester.getBottomLeft(_monthlyOption).dy;
  final ctaTop = tester.getTopLeft(_cta).dy;
  return ctaTop - monthlyBottom;
}

/// Centring slack inside the min-height column (above headline vs below terms).
({double aboveHeadline, double belowTerms}) _verticalBalance(
  WidgetTester tester,
) {
  final constrained = tester.renderObject<RenderBox>(
    find.byKey(const Key('subscribe_body_min_height')),
  );
  final columnTop = constrained.localToGlobal(Offset.zero).dy;
  final columnBottom = columnTop + constrained.size.height;
  final headlineTop = tester.getTopLeft(_headlineTitle).dy;
  final termsBottom = tester.getBottomLeft(_terms).dy;
  return (
    aboveHeadline: headlineTop - columnTop,
    belowTerms: columnBottom - termsBottom,
  );
}

Future<void> pumpPlanOptionPair(
  WidgetTester tester, {
  required bool quarterlyBadge,
}) async {
  tester.view.physicalSize = const Size(412, 400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildTsTheme(Brightness.dark),
      home: MediaQuery(
        data: const MediaQueryData(size: Size(412, 400)),
        child: SizedBox(
          width: 412,
          child: Column(
            children: [
              TsPlanOption(
                period: '3 Months',
                price: '₩9,900',
                priceNote: '(1 month free)',
                selected: true,
                discountLabel: quarterlyBadge ? '33% OFF' : null,
              ),
              TsPlanOption(
                period: '1 Month',
                price: '₩4,900',
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('plan option heights at 412px width', (tester) async {
    await pumpPlanOptionPair(tester, quarterlyBadge: true);
    final withBadgeQ = _optionHeight(tester, _quarterlyOption);
    final withBadgeM = _optionHeight(tester, _monthlyOption);
    debugPrint(
      'plan_option_412 with_badge quarterly=$withBadgeQ monthly=$withBadgeM',
    );
    expect(withBadgeQ, closeTo(withBadgeM, 1));

    await pumpPlanOptionPair(tester, quarterlyBadge: false);
    final noBadgeQ = _optionHeight(tester, _quarterlyOption);
    final noBadgeM = _optionHeight(tester, _monthlyOption);
    debugPrint(
      'plan_option_412 no_badge quarterly=$noBadgeQ monthly=$noBadgeM',
    );
    expect(noBadgeQ, closeTo(noBadgeM, 1));
  });

  testWidgets('subscribe screen plan options equal height', (tester) async {
    const size = Size(412, 917);
    await pumpSubscribe(tester, size);

    final quarterly = _optionHeight(tester, _quarterlyOption);
    final monthly = _optionHeight(tester, _monthlyOption);
    debugPrint(
      'subscribe_plan_option_heights quarterly=$quarterly monthly=$monthly',
    );
    expect(quarterly, closeTo(monthly, 1));
  });

  testWidgets('412x917 device-like inset: CTA spacing and vertical balance', (
    tester,
  ) async {
    const size = Size(412, 917);
    await pumpSubscribe(tester, size, padding: _deviceLikePadding);

    final gap = _gapMonthlyToCta(tester);
    final balance = _verticalBalance(tester);

    debugPrint(
      'subscribe_412x917_inset gap=$gap '
      'aboveHeadline=${balance.aboveHeadline} belowTerms=${balance.belowTerms}',
    );

    expect(gap, closeTo(TsSpacing.lg, 2));
    expect(balance.aboveHeadline, closeTo(balance.belowTerms, 2));
  });

  testWidgets('412x917 zero inset: CTA spacing and vertical balance', (
    tester,
  ) async {
    const size = Size(412, 917);
    await pumpSubscribe(tester, size);

    final gap = _gapMonthlyToCta(tester);
    final balance = _verticalBalance(tester);

    debugPrint(
      'subscribe_412x917_zero gap=$gap '
      'aboveHeadline=${balance.aboveHeadline} belowTerms=${balance.belowTerms}',
    );

    expect(gap, closeTo(TsSpacing.lg, 2));
    expect(balance.aboveHeadline, closeTo(balance.belowTerms, 2));
  });

  testWidgets('tall viewport centres when content is shorter', (tester) async {
    const size = Size(412, 1100);
    await pumpSubscribe(tester, size, padding: _deviceLikePadding);

    final balance = _verticalBalance(tester);
    debugPrint(
      'subscribe_412x1100_inset aboveHeadline=${balance.aboveHeadline} '
      'belowTerms=${balance.belowTerms}',
    );

    expect(balance.aboveHeadline, greaterThan(8));
    expect(balance.aboveHeadline, closeTo(balance.belowTerms, 2));
  });

  testWidgets('412x640 scrolls and terms reachable', (tester) async {
    const size = Size(412, 640);
    await pumpSubscribe(tester, size, padding: _deviceLikePadding);

    final scrollable = find.byType(Scrollable);
    expect(scrollable, findsOneWidget);

    expect(_gapMonthlyToCta(tester), closeTo(TsSpacing.lg, 2));

    await tester.scrollUntilVisible(
      _terms,
      50,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    final termsBottom = tester.getBottomLeft(_terms).dy;
    final screenBottom = size.height - _deviceLikePadding.bottom;
    expect(termsBottom, lessThanOrEqualTo(screenBottom + 1));

    await tester.scrollUntilVisible(
      _headlineTitle,
      50,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(_headlineTitle, findsOneWidget);

    final ctaTopBefore = tester.getTopLeft(_cta).dy;
    await tester.drag(scrollable, const Offset(0, -400));
    await tester.pumpAndSettle();
    final ctaTopAfter = tester.getTopLeft(_cta).dy;
    expect(ctaTopAfter, isNot(closeTo(ctaTopBefore, 1)));

    debugPrint(
      'subscribe_412x640 scroll ok termsBottom=$termsBottom screenBottom=$screenBottom',
    );
  });
}
