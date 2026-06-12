import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

String resolveApiError(BuildContext context, dynamic error) {
  final l10n = context.l10n;

  if (error is ApiException) {
    return _messageForCode(
      l10n,
      error.code,
      extra: error.extra,
      fallbackMessage: error.message,
    );
  }

  if (error is DioException) {
    final parsed = _parseErrorPayload(error.response?.data);
    if (parsed?.code != null && parsed!.code!.isNotEmpty) {
      return _messageForCode(
        l10n,
        parsed.code!,
        extra: parsed.extra,
      );
    }
    return _messageForDio(l10n, error);
  }

  if (error is Map) {
    final map = error is Map<String, dynamic>
        ? error
        : Map<String, dynamic>.from(error);
    if (map['success'] == false) {
      final parsed = _parseErrorPayload(map);
      if (parsed?.code != null && parsed!.code!.isNotEmpty) {
        return _messageForCode(l10n, parsed.code!, extra: parsed.extra);
      }
      return l10n.errorContactFailed;
    }
    final parsed = _parseErrorPayload(map);
    if (parsed?.code != null && parsed!.code!.isNotEmpty) {
      return _messageForCode(l10n, parsed.code!, extra: parsed.extra);
    }
  }

  final message = _exceptionMessage(error);
  if (message != null) {
    final fromText = _messageFromExceptionText(l10n, message);
    if (fromText != null) return fromText;
  }

  return l10n.errorUnknown;
}

class _ParsedApiError {
  const _ParsedApiError({this.code, this.extra});

  final String? code;
  final Map<String, dynamic>? extra;
}

_ParsedApiError? _parseErrorPayload(dynamic data) {
  if (data is! Map) return null;
  final map =
      data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);

  final nested = map['error'];
  if (nested is Map) {
    final errorMap =
        nested is Map<String, dynamic> ? nested : Map<String, dynamic>.from(nested);
    final code = errorMap['code'];
    if (code is String && code.isNotEmpty) {
      return _ParsedApiError(code: code, extra: _extractExtraMap(errorMap));
    }
  }

  final topCode = map['code'];
  if (topCode is String && topCode.isNotEmpty) {
    return _ParsedApiError(code: topCode, extra: _extractExtraMap(map));
  }

  return null;
}

Map<String, dynamic>? _extractExtraMap(Map<String, dynamic> map) {
  final rawExtra = map['extra'];
  if (rawExtra is Map) {
    return Map<String, dynamic>.from(rawExtra);
  }
  if (map['daysLeft'] != null) {
    return <String, dynamic>{'daysLeft': map['daysLeft']};
  }
  return null;
}

String? _exceptionMessage(dynamic error) {
  if (error is Exception) {
    return error.toString().replaceFirst('Exception: ', '');
  }
  if (error is String) {
    return error.replaceFirst('Exception: ', '');
  }
  return null;
}

String? _messageFromExceptionText(AppLocalizations l10n, String message) {
  final fromCode = _messageFromErrorCode(l10n, message);
  if (fromCode != null) return fromCode;

  if (message.contains('Purchase verification failed')) {
    return l10n.errorPurchaseVerifyFailed;
  }
  if (message.contains('PAYMENT_PENDING') ||
      message.contains('payment pending')) {
    return l10n.errorPaymentPending;
  }
  if (message.contains('이메일')) {
    return l10n.errorEmailRequired;
  }
  if (message.contains('탈퇴 후') ||
      message.contains('재가입') ||
      message.contains('쿨다운')) {
    final daysLeft = _daysLeftFromText(message) ?? 7;
    return l10n.errorCooldownActive(daysLeft);
  }
  if (message.contains('회원 탈퇴') || message.contains('계정 삭제')) {
    return l10n.errorDeleteConfirmation;
  }
  if (message.contains('로그인에 실패') || message.contains('네이버 로그인')) {
    return l10n.errorLogin;
  }
  if (message.contains('인증이 만료')) {
    return l10n.errorUnauthorized;
  }
  return null;
}

String? _messageFromErrorCode(AppLocalizations l10n, String message) {
  final trimmed = message.trim();
  if (trimmed.isEmpty) return null;

  var code = trimmed;
  Map<String, dynamic>? extra;
  final colonIndex = trimmed.indexOf(':');
  if (colonIndex > 0) {
    code = trimmed.substring(0, colonIndex).trim();
    final daysLeft = int.tryParse(trimmed.substring(colonIndex + 1).trim());
    if (daysLeft != null) {
      extra = <String, dynamic>{'daysLeft': daysLeft};
    }
  }

  if (!RegExp(r'^[A-Z_]+$').hasMatch(code)) return null;
  return _messageForCode(l10n, code, extra: extra);
}

String _messageForCode(
  AppLocalizations l10n,
  String code, {
  Map<String, dynamic>? extra,
  String? fallbackMessage,
}) {
  final normalized = code.trim().toUpperCase();
  final daysLeft = _daysLeftFromExtra(extra) ??
      _daysLeftFromText(fallbackMessage ?? '') ??
      7;

  switch (normalized) {
    case 'UNAUTHORIZED':
    case 'AUTH_REQUIRED':
      return l10n.errorUnauthorized;
    case 'SUBSCRIPTION_REQUIRED':
    case 'PREMIUM_REQUIRED':
    case 'FORBIDDEN':
      return l10n.errorSubscriptionRequired;
    case 'EMAIL_REQUIRED':
      return l10n.errorEmailRequired;
    case 'COOLDOWN_ACTIVE':
      return l10n.errorCooldownActive(daysLeft);
    case 'PAYMENT_PENDING':
      return l10n.errorPaymentPending;
    case 'NOT_FOUND':
      return l10n.errorNotFound;
    case 'RATE_LIMITED':
    case 'TOO_MANY_REQUESTS':
      return l10n.errorRateLimited;
    case 'INTERNAL_SERVER_ERROR':
    case 'SERVER_ERROR':
      return l10n.errorServerError;
    case 'DELETE_ACCOUNT_FAILED':
    case 'ACCOUNT_DELETE_FAILED':
      return l10n.errorDeleteConfirmation;
    case 'LOGIN_FAILED':
      return l10n.errorLogin;
    case 'NAVER_LOGIN_FAILED':
      return l10n.errorNaverLoginFailed;
    case 'NAVER_AUTH_EXPIRED':
      return l10n.errorUnauthorized;
    case 'ACCOUNT_DELETED':
      return l10n.errorAccountDeleted;
    case 'USER_NOT_FOUND':
      return l10n.errorNotFound;
    case 'CONTACT_FAILED':
      return l10n.errorContactFailed;
    case 'PURCHASE_VERIFY_FAILED':
    case 'PAYMENT_VERIFY_FAILED':
    case 'VERIFY_FAILED':
      return l10n.errorPurchaseVerifyFailed;
    default:
      return l10n.errorUnknown;
  }
}

String _messageForDio(AppLocalizations l10n, DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return l10n.errorNetworkTimeout;
    default:
      break;
  }

  final status = e.response?.statusCode;
  switch (status) {
    case 401:
      return l10n.errorUnauthorized;
    case 403:
      return l10n.errorSubscriptionRequired;
    case 404:
      return l10n.errorNotFound;
    case 429:
      return l10n.errorRateLimited;
    default:
      if (status != null && status >= 500) {
        return l10n.errorServerError;
      }
      return l10n.errorUnknown;
  }
}

int? _daysLeftFromExtra(Map<String, dynamic>? extra) {
  if (extra == null) return null;
  final value = extra['daysLeft'];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

int? _daysLeftFromText(String text) {
  final match = RegExp(r'(\d+)').firstMatch(text);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}
