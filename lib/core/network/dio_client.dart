// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    final baseUrl = dotenv.env['NEWS_API_BASE_URL'] ?? '';
    final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.requestTimeout,
        receiveTimeout: AppConstants.requestTimeout,
        queryParameters: {'apiKey': apiKey},
        headers: {'Accept': 'application/json'},
      ),
    );

    // Only log in debug mode — never expose keys in production logs
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false, // omit headers to avoid logging API key
          requestBody: false,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }

    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio => _dio;
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NetworkException(message: 'Connection failed'),
          ),
        );
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: const UnauthorizedException(),
            ),
          );
        }
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ServerException(
              message: err.response?.data?['message'] ?? 'Server error',
              statusCode: statusCode,
            ),
          ),
        );
      default:
        handler.next(err);
    }
  }
}
