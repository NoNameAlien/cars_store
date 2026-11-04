import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

Dio createApiClient() => Dio(
  BaseOptions(
    baseUrl: 'https://fakestoreapi.com',
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 12),
    responseType: ResponseType.json,
  ),
);

AppFailure mapNetworkFailure(DioException error) {
  final status = error.response?.statusCode;
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const AppFailure(FailureKind.timeout),
    // Browsers also report blocked CORS requests as connection errors.
    DioExceptionType.connectionError => const AppFailure(
      FailureKind.noConnection,
    ),
    DioExceptionType.badResponse when status != null && status >= 500 =>
      AppFailure(FailureKind.serverError, statusCode: status),
    DioExceptionType.badResponse when status != null && status >= 400 =>
      AppFailure(FailureKind.clientError, statusCode: status),
    _ => const AppFailure(FailureKind.unexpected),
  };
}
