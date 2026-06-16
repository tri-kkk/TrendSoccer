import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class SubscribeSuccessPage extends ConsumerStatefulWidget {
  const SubscribeSuccessPage({this.months = 3, super.key});

  final int months;

  @override
  ConsumerState<SubscribeSuccessPage> createState() =>
      _SubscribeSuccessPageState();
}

class _SubscribeSuccessPageState extends ConsumerState<SubscribeSuccessPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider).loadProfile());
  }

  String _priceLabel(BuildContext context) {
    final l10n = context.l10n;
    return widget.months == 3
        ? l10n.subscribePriceQuarterly
        : l10n.subscribePriceMonthly;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/trend');
      },
      child: Scaffold(
        backgroundColor: semantic.surfaceRaised,
        appBar: AppBar(
          backgroundColor: semantic.surfaceRaised,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: semantic.textPrimary),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: semantic.textPrimary),
            onPressed: () => context.go('/trend'),
          ),
          title: Text(
            l10n.subscribeSuccessTitle,
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(height: 2, color: semantic.textDisabled),
          ),
        ),
        body: LayoutBuilder(
        builder: (context, constraints) {
          final bottom = MediaQuery.paddingOf(context).bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottom + 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        TsAssets.iconRocketLaunch,
                        width: 80,
                        height: 80,
                        colorFilter: ColorFilter.mode(
                          semantic.interactivePrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        l10n.subscribeSuccessComplete,
                        style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.subscribeSuccessSubtitle,
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
                                  l10n.subscribeReceiptAmount,
                                  style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                                ),
                                Text(
                                  _priceLabel(context),
                                  style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Opacity(
                              opacity: 0.3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.subscribeReceiptPlan,
                                    style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                                  ),
                                  Text(
                                    l10n.subscribePeriodMonths(widget.months),
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
                          label: l10n.subscribeSuccessCTA,
                          variant: TsButtonVariant.primary,
                          onPressed: () => context.go('/premium'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TsButton(
                          label: l10n.subscribeGoHome,
                          variant: TsButtonVariant.secondary,
                          onPressed: () => context.go('/trend'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}
