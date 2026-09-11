import 'package:trendsoccer/core/services/iap_service.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

String _formatPlanDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}.$month.$day';
}

String? planReceiptValue(AppLocalizations l10n, String? basePlanId) {
  if (basePlanId == null) return null;
  final period = switch (basePlanId) {
    IAPService.monthlyPlan => l10n.subscribePlanMonthly,
    IAPService.quarterlyPlan => l10n.subscribePlanQuarterly,
    _ => null,
  };
  if (period == null) return null;
  return '${l10n.subscribePlanPremium} · $period';
}

List<(String label, String value)> successReceiptRows(
  AppLocalizations l10n, {
  required String? basePlanId,
  required String? storePrice,
  required DateTime? nextBillingDate,
}) {
  final rows = <(String, String)>[];
  final plan = planReceiptValue(l10n, basePlanId);
  if (plan != null) {
    rows.add((l10n.subscribeReceiptPlan, plan));
  }
  if (storePrice != null && storePrice.isNotEmpty) {
    rows.add((l10n.subscribeReceiptAmount, storePrice));
  }
  if (nextBillingDate != null) {
    rows.add((
      l10n.subscriptionNextBilling,
      _formatPlanDate(nextBillingDate),
    ));
  }
  return rows;
}

List<(String label, String value)> failedReceiptRows(
  AppLocalizations l10n, {
  required String? purchaseId,
}) {
  final rows = <(String, String)>[
    (l10n.paymentReceiptReason, l10n.paymentFailedReasonGeneral),
  ];
  if (purchaseId != null && purchaseId.isNotEmpty) {
    rows.add((l10n.paymentReceiptOrder, purchaseId));
  }
  return rows;
}
