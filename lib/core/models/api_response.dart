class ApiError {
  const ApiError({
    required this.code,
    required this.message,
    this.messageEn,
    this.extra,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? extra;
    final rawExtra = json['extra'];
    if (rawExtra is Map) {
      extra = Map<String, dynamic>.from(rawExtra);
    } else if (json['daysLeft'] != null) {
      extra = <String, dynamic>{'daysLeft': json['daysLeft']};
    }

    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'Unknown error',
      messageEn: json['messageEn'] as String?,
      extra: extra,
    );
  }

  final String code;
  final String message;
  final String? messageEn;
  final Map<String, dynamic>? extra;
}

class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.messageEn,
    this.extra,
  });

  factory ApiException.fromApiError(ApiError error) {
    return ApiException(
      code: error.code,
      message: error.message,
      messageEn: error.messageEn,
      extra: error.extra,
    );
  }

  final String code;
  final String message;
  final String? messageEn;
  final Map<String, dynamic>? extra;

  @override
  String toString() => 'ApiException($code): $message';
}

class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.meta,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    final rawData = json['data'];
    final rawMeta = json['meta'];
    final rawError = json['error'];

    return ApiResponse(
      success: success,
      data: success && rawData != null
          ? (fromJsonT != null ? fromJsonT(rawData) : rawData as T)
          : null,
      meta: rawMeta is Map<String, dynamic> ? rawMeta : null,
      error: rawError is Map<String, dynamic> ? ApiError.fromJson(rawError) : null,
    );
  }

  final bool success;
  final T? data;
  final Map<String, dynamic>? meta;
  final ApiError? error;
}
