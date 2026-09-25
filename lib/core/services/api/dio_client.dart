import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../logger/app_logger.dart';

class DioClient {
  final String baseUrl;
  final AppLogger logger;
  late final Dio dio;

  DioClient({
    required this.baseUrl,
    required this.logger,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    // Add token interceptor
    dio.interceptors.add(
      TokenInterceptor(),
    );

    // Add error interceptor
    dio.interceptors.add(
      ErrorInterceptor(logger),
    );
  }
}

class TokenInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Token will be added here from secure storage
    // This is a placeholder for now
    return handler.next(options);
  }
}

class ErrorInterceptor extends Interceptor {
  final AppLogger logger;

  ErrorInterceptor(this.logger);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    logger.error(
      'API Error: ${err.response?.statusCode} - ${err.message}',
      err,
      err.stackTrace,
    );
    return handler.next(err);
  }
}