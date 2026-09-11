/// Receipt fields passed from [SubscribeScreen] via GoRouter [extra].
final class PaymentSuccessArgs {
  const PaymentSuccessArgs({this.basePlanId, this.storePrice});

  final String? basePlanId;
  final String? storePrice;
}

final class PaymentFailedArgs {
  const PaymentFailedArgs({this.purchaseId});

  final String? purchaseId;
}
