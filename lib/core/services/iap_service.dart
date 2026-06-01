import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum IapPurchaseEventType {
  pending,
  purchased,
  restored,
  error,
  canceled,
}

class IapPurchaseEvent {
  const IapPurchaseEvent({
    required this.type,
    this.productId,
    this.message,
  });

  final IapPurchaseEventType type;
  final String? productId;
  final String? message;
}

final iapServiceProvider = Provider<IAPService>((ref) {
  final service = IAPService();
  ref.onDispose(service.dispose);
  return service;
});

class IAPService {
  static const premiumMonthly = 'premium_monthly';
  static const premiumQuarterly = 'premium_quarterly';

  static const _productIds = <String>{
    premiumMonthly,
    premiumQuarterly,
  };

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final StreamController<IapPurchaseEvent> _purchaseEventsController =
      StreamController<IapPurchaseEvent>.broadcast();

  bool _isAvailable = false;
  bool _initialized = false;
  List<ProductDetails> _products = const [];

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => List.unmodifiable(_products);
  Stream<IapPurchaseEvent> get purchaseEvents => _purchaseEventsController.stream;

  Future<void> init() async {
    if (_initialized) {
      debugPrint('[IAP] init: already initialized');
      return;
    }

    _isAvailable = await _iap.isAvailable();
    debugPrint('[IAP] available=$_isAvailable');

    if (!_isAvailable) {
      _initialized = true;
      return;
    }

    _purchaseSubscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[IAP] purchaseStream error: $error');
        _purchaseEventsController.add(
          IapPurchaseEvent(
            type: IapPurchaseEventType.error,
            message: error.toString(),
          ),
        );
      },
    );

    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint(
        '[IAP] queryProductDetails error: ${response.error!.message}',
      );
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[IAP] products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
    debugPrint('[IAP] available=$_isAvailable, products=${_products.length}');
    for (final product in _products) {
      debugPrint('[IAP] product: id=${product.id}, price=${product.price}');
    }

    _initialized = true;

    debugPrint('[IAP] restorePurchases on init');
    await restorePurchases();
  }

  ProductDetails? findProduct(String productId) {
    for (final product in _products) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }

  Future<bool> buySubscription(String productId) async {
    debugPrint('[IAP] buySubscription: productId=$productId');

    if (!_isAvailable) {
      debugPrint('[IAP] buySubscription: store not available');
      return false;
    }

    final product = findProduct(productId);
    if (product == null) {
      debugPrint('[IAP] buySubscription: product not found');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      final initiated = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint('[IAP] buySubscription: initiated=$initiated');
      return initiated;
    } catch (e) {
      debugPrint('[IAP] buySubscription error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('[IAP] restorePurchases: store not available');
      return;
    }
    debugPrint('[IAP] restorePurchases: calling restorePurchases');
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      debugPrint(
        '[IAP] purchase update: productId=${purchase.productID}, '
        'status=${purchase.status}, pendingComplete=${purchase.pendingCompletePurchase}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('[IAP] status=pending');
          _purchaseEventsController.add(
            IapPurchaseEvent(
              type: IapPurchaseEventType.pending,
              productId: purchase.productID,
            ),
          );
        case PurchaseStatus.purchased:
          debugPrint('[IAP] status=purchased');
          final verified = await _verifyPurchase(purchase);
          if (verified) {
            _purchaseEventsController.add(
              IapPurchaseEvent(
                type: IapPurchaseEventType.purchased,
                productId: purchase.productID,
              ),
            );
          } else {
            _purchaseEventsController.add(
              const IapPurchaseEvent(
                type: IapPurchaseEventType.error,
                message: 'Purchase verification failed',
              ),
            );
          }
          await _completePurchaseIfNeeded(purchase);
        case PurchaseStatus.restored:
          debugPrint('[IAP] status=restored');
          final verified = await _verifyPurchase(purchase);
          if (verified) {
            _purchaseEventsController.add(
              IapPurchaseEvent(
                type: IapPurchaseEventType.restored,
                productId: purchase.productID,
              ),
            );
          }
          await _completePurchaseIfNeeded(purchase);
        case PurchaseStatus.error:
          final message = purchase.error?.message ?? 'Unknown purchase error';
          debugPrint('[IAP] status=error: $message');
          _purchaseEventsController.add(
            IapPurchaseEvent(
              type: IapPurchaseEventType.error,
              productId: purchase.productID,
              message: message,
            ),
          );
          await _completePurchaseIfNeeded(purchase);
        case PurchaseStatus.canceled:
          debugPrint('[IAP] status=canceled');
          _purchaseEventsController.add(
            IapPurchaseEvent(
              type: IapPurchaseEventType.canceled,
              productId: purchase.productID,
            ),
          );
          await _completePurchaseIfNeeded(purchase);
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    debugPrint(
      '[IAP] verify: productId=${purchase.productID}, '
      'token=${purchase.verificationData.serverVerificationData}',
    );
    // TODO: POST to backend verification endpoint when available.
    return true;
  }

  Future<void> _completePurchaseIfNeeded(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) {
      return;
    }
    try {
      await _iap.completePurchase(purchase);
      debugPrint('[IAP] completePurchase: productId=${purchase.productID}');
    } catch (e) {
      debugPrint('[IAP] completePurchase error: $e');
    }
  }

  void dispose() {
    debugPrint('[IAP] dispose');
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _purchaseEventsController.close();
  }
}
