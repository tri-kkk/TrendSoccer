import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/analytics_service.dart';
import 'package:trendsoccer/core/services/token_service.dart';

enum IapPurchaseEventType {
  pending,
  purchased,
  restored,
  itemAlreadyOwned,
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
  final service = IAPService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class IAPService {
  IAPService([this._ref]);

  static const premium = 'premium';
  static const monthlyPlan = 'monthly-plan';
  static const quarterlyPlan = 'quarterly-plan';

  static const _productIds = <String>{premium};

  static const _authJwtKey = 'auth_jwt';
  static const _verifyUrl =
      'https://www.trendsoccer.com/api/v1/mobile/purchase/verify';

  final Ref? _ref;
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
            return;
    }

    _isAvailable = await _iap.isAvailable();
    
    if (!_isAvailable) {
      _initialized = true;
      return;
    }

    _purchaseSubscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error, StackTrace stackTrace) {
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
          }
    if (response.notFoundIDs.isNotEmpty) {
          }

    _products = response.productDetails;

    _initialized = true;

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

  bool hasProduct(String productId) {
    return _products.any((product) => product.id == productId);
  }

  ProductDetails? findProductForBasePlan(String basePlanId) {
    for (final product in _products) {
      if (product.id != premium) continue;
      if (_basePlanIdForProduct(product) == basePlanId) {
                return product;
      }
    }
        return null;
  }

  String? _basePlanIdForProduct(ProductDetails product) {
    if (product is! GooglePlayProductDetails) return null;
    final subscriptionIndex = product.subscriptionIndex;
    final offers = product.productDetails.subscriptionOfferDetails;
    if (subscriptionIndex == null || offers == null) return null;
    if (subscriptionIndex < 0 || subscriptionIndex >= offers.length) {
      return null;
    }
    return offers[subscriptionIndex].basePlanId;
  }

  String _basePlanIdForPurchase(
    PurchaseDetails purchase, {
    Map<String, dynamic>? verifyData,
  }) {
    final planFromApi = verifyData?['plan'];
    if (planFromApi is String && planFromApi.isNotEmpty) {
      return planFromApi;
    }

    final matchingProducts = _products
        .where((product) => product.id == purchase.productID)
        .toList();
    if (matchingProducts.length == 1) {
      final basePlanId = _basePlanIdForProduct(matchingProducts.first);
      if (basePlanId != null && basePlanId.isNotEmpty) {
        return basePlanId;
      }
    }

    return monthlyPlan;
  }

  Future<void> _logPurchaseAnalytics(
    PurchaseDetails purchase, {
    Map<String, dynamic>? verifyData,
  }) async {
    final basePlanId = _basePlanIdForPurchase(
      purchase,
      verifyData: verifyData,
    );
    await AnalyticsService.logPurchase(basePlanId: basePlanId);
  }

  Future<bool> buySubscription([String? basePlanId]) async {
    
    if (!_isAvailable) {
            return false;
    }

    ProductDetails? product;
    if (basePlanId != null) {
      product = findProductForBasePlan(basePlanId);
    }
    product ??= findProduct(premium);
    if (product == null) {
      return false;
    }

    final PurchaseParam purchaseParam;
    if (product is GooglePlayProductDetails) {
      purchaseParam = GooglePlayPurchaseParam(
        productDetails: product,
        offerToken: product.offerToken,
      );
          } else {
      purchaseParam = PurchaseParam(productDetails: product);
    }

    try {
      final initiated = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
            return initiated;
    } catch (e) {
            return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
            return;
    }
        await _iap.restorePurchases();
  }

  Future<void> restoreAndVerify() async {
        await restorePurchases();
  }

  bool _isItemAlreadyOwnedError(String message) {
    return message.contains('itemAlreadyOwned') ||
        message.contains('AlreadyOwned') ||
        message.contains('BillingResponse.itemAlreadyOwned');
  }

  Future<String?> _getAuthJwt() async {
    final ref = _ref;
    if (ref != null) {
      try {
        final jwt = ref.read(sharedPreferencesProvider).getString(_authJwtKey);
        if (jwt != null && jwt.isNotEmpty) {
                    return jwt;
        }
              } catch (e) {
              }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString(_authJwtKey);
      if (jwt != null && jwt.isNotEmpty) {
                return jwt;
      }
          } catch (e) {
          }

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.accessToken.isNotEmpty) {
                return session.accessToken;
      }
          } catch (e) {
          }

    try {
      if (ref != null) {
        final token = await ref.read(tokenServiceProvider).getToken();
        if (token != null && token.isNotEmpty) {
                    return token;
        }
      } else {
        final tokenService = TokenService();
        final token = await tokenService.getToken();
        if (token != null && token.isNotEmpty) {
                    return token;
        }
      }
          } catch (e) {
          }

        return null;
  }

  Map<String, dynamic>? _unwrapResponseData(Object? raw) {
    if (raw is! Map) return null;
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw);
    final nested = map['data'];
    if (nested is Map<String, dynamic>) return nested;
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return map;
  }

  String? _readErrorCode(Object? raw) {
    if (raw is! Map) return null;
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw);
    final error = map['error'];
    if (error is Map) {
      final errorMap = Map<String, dynamic>.from(error);
      final code = errorMap['code'];
      if (code is String && code.isNotEmpty) return code;
    }
    final code = map['code'];
    if (code is String && code.isNotEmpty) return code;
    return null;
  }

  Future<void> _loadProfileAfterVerify() async {
    final ref = _ref;
    if (ref == null) {
            return;
    }
    try {
      await ref.read(authProvider).loadProfile();
          } catch (e) {
          }
  }

  Future<void> _emitVerifiedPurchase({
    required PurchaseDetails purchase,
    required IapPurchaseEventType eventType,
  }) async {
    await _loadProfileAfterVerify();
    _purchaseEventsController.add(
      IapPurchaseEvent(
        type: eventType,
        productId: purchase.productID,
      ),
    );
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      
      switch (purchase.status) {
        case PurchaseStatus.pending:
                    _purchaseEventsController.add(
            IapPurchaseEvent(
              type: IapPurchaseEventType.pending,
              productId: purchase.productID,
            ),
          );
        case PurchaseStatus.purchased:
                    final verified = await _verifyPurchase(purchase);
          if (verified) {
            await _emitVerifiedPurchase(
              purchase: purchase,
              eventType: IapPurchaseEventType.purchased,
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
                    final verified = await _verifyPurchase(purchase);
          if (verified) {
                        await _emitVerifiedPurchase(
              purchase: purchase,
              eventType: IapPurchaseEventType.restored,
            );
          } else {
            _purchaseEventsController.add(
              const IapPurchaseEvent(
                type: IapPurchaseEventType.error,
                message: 'Purchase restore verification failed',
              ),
            );
          }
          await _completePurchaseIfNeeded(purchase);
        case PurchaseStatus.error:
          final errorMsg = purchase.error?.message ?? 'Unknown purchase error';
          
          if (_isItemAlreadyOwnedError(errorMsg)) {
                        _purchaseEventsController.add(
              IapPurchaseEvent(
                type: IapPurchaseEventType.itemAlreadyOwned,
                productId: purchase.productID,
                message: errorMsg,
              ),
            );
            await restorePurchases();
            await _completePurchaseIfNeeded(purchase);
            continue;
          }

          _purchaseEventsController.add(
            IapPurchaseEvent(
              type: IapPurchaseEventType.error,
              productId: purchase.productID,
              message: errorMsg,
            ),
          );
          await _completePurchaseIfNeeded(purchase);
        case PurchaseStatus.canceled:
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
    final purchaseToken = purchase.verificationData.serverVerificationData;
    
    try {
      final jwt = await _getAuthJwt();
      if (jwt == null) {
                return false;
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      };
      
      final dio = Dio();
      final response = await dio.post<dynamic>(
        _verifyUrl,
        data: <String, dynamic>{
          'productId': purchase.productID,
          'purchaseToken': purchaseToken,
          'platform': 'android',
        },
        options: Options(headers: headers),
      );

      final data = _unwrapResponseData(response.data);
                  await _logPurchaseAnalytics(purchase, verifyData: data);
      return true;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final body = e.response?.data;
      final errorCode = _readErrorCode(body);

      if (statusCode == 402 || errorCode == 'PAYMENT_PENDING') {
                return false;
      }

      if (statusCode == 409 || errorCode == 'TOKEN_ALREADY_USED') {
                final data = _unwrapResponseData(body);
                        await _logPurchaseAnalytics(purchase, verifyData: data);
        return true;
      }

      if (statusCode == 400 || statusCode == 401) {
                return false;
      }

            return false;
    } catch (e) {
            return false;
    }
  }

  Future<void> _completePurchaseIfNeeded(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) {
      return;
    }
    try {
      await _iap.completePurchase(purchase);
          } catch (e) {
          }
  }

  void dispose() {
        _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _purchaseEventsController.close();
  }
}
