import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

void main() {
  testWidgets('resolveApiError maps offline DioException to errorNetworkTimeout', (
    tester,
  ) async {
  late String message;

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          message = resolveApiError(
            context,
            DioException(
              requestOptions: RequestOptions(path: '/api/team-stats'),
              type: DioExceptionType.connectionError,
            ),
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );

  expect(message, 'Please check your network connection');
  });

  testWidgets('resolveApiError maps 401 DioException to errorUnauthorized', (
    tester,
  ) async {
    late String message;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            message = resolveApiError(
              context,
              DioException(
                requestOptions: RequestOptions(path: '/api/team-stats'),
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: RequestOptions(path: '/api/team-stats'),
                  statusCode: 401,
                ),
              ),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(message, 'Login required');
  });
}
