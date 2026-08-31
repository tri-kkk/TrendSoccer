import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';

void main() {
  test('isTransportFailure is true for connection errors', () {
    expect(
      isTransportFailure(
        DioException(
          requestOptions: RequestOptions(path: '/api/predict-v2'),
          type: DioExceptionType.connectionError,
        ),
      ),
      isTrue,
    );
  });

  test('isTransportFailure is false for HTTP 500', () {
    expect(
      isTransportFailure(
        DioException(
          requestOptions: RequestOptions(path: '/api/predict-v2'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/predict-v2'),
            statusCode: 500,
          ),
        ),
      ),
      isFalse,
    );
  });

  test('soccerReportHasTotalTransportFailure requires all transport errors', () {
    final transportError = DioException(
      requestOptions: RequestOptions(path: '/api'),
      type: DioExceptionType.connectionError,
    );
    final serverError = DioException(
      requestOptions: RequestOptions(path: '/api'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/api'),
        statusCode: 500,
      ),
    );

    expect(
      soccerReportHasTotalTransportFailure([
        AsyncValue.error(transportError, StackTrace.empty),
        AsyncValue.error(transportError, StackTrace.empty),
        AsyncValue.error(transportError, StackTrace.empty),
        AsyncValue.error(transportError, StackTrace.empty),
      ]),
      isTrue,
    );

    expect(
      soccerReportHasTotalTransportFailure([
        AsyncValue.error(transportError, StackTrace.empty),
        const AsyncValue.data(<String, dynamic>{}),
        AsyncValue.error(transportError, StackTrace.empty),
        AsyncValue.error(transportError, StackTrace.empty),
      ]),
      isFalse,
    );

    expect(
      soccerReportHasTotalTransportFailure([
        AsyncValue.error(serverError, StackTrace.empty),
        AsyncValue.error(transportError, StackTrace.empty),
        AsyncValue.error(transportError, StackTrace.empty),
        AsyncValue.error(transportError, StackTrace.empty),
      ]),
      isFalse,
    );
  });
}
