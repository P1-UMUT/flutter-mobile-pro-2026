import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../logger/app_logger.dart';
import '../../core/exceptions/app_exceptions.dart';

class DioClient {
  final String baseUrl;
  final AppLogger logger;
  late final Dio dio;
  String? _authToken;

  DioClient({
    required this.baseUrl,
    required this.logger,
    String? initialToken,
  }) : _authToken = initialToken {
    _setupDio();
  }

  void _setupDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
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

    // Add custom interceptors
    dio.interceptors.add(_TokenInterceptor(this));
    dio.interceptors.add(_ErrorInterceptor(logger));
  }

  void setAuthToken(String token) {
    _authToken = token;
    logger.info('Auth token updated');
  }

  void clearAuthToken() {
    _authToken = null;
    logger.info('Auth token cleared');
  }

  String? getAuthToken() => _authToken;

  Future<T> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await dio.get<dynamic>(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<T> post<T>({
    required String endpoint,
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await dio.post<dynamic>(endpoint, data: data);
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<T> put<T>({
    required String endpoint,
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await dio.put<dynamic>(endpoint, data: data);
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<T> delete<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await dio.delete<dynamic>(endpoint);
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  T _handleResponse<T>(Response<dynamic> response, T Function(dynamic) fromJson) {
    if (response.statusCode == null) {
      throw NetworkException(
        message: 'Network error occurred',
        code: 'NETWORK_ERROR',
      );
    }

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      try {
        return fromJson(response.data);
      } catch (e) {
        throw NetworkException(
          message: 'Failed to parse response',
          code: 'PARSE_ERROR',
          originalException: e,
        );
      }
    }

    // Handle error responses
    final errorData = response.data as Map<String, dynamic>? ?? {};
    final errorMessage = errorData['message'] as String? ?? 'Unknown error';
    final errorCode = errorData['code'] as String?;

    switch (response.statusCode) {
      case 400:
        throw ValidationException(
          message: errorMessage,
          code: errorCode,
          fieldErrors: errorData['errors'] is Map
              ? Map<String, String>.from(errorData['errors'] as Map)
              : null,
        );
      case 401:
      case 403:
        throw UnauthorizedException(
          message: errorMessage,
          code: errorCode,
        );
      case 404:
        throw NotFoundException(
          message: errorMessage,
          code: errorCode,
        );
      case 500:
      case 502:
      case 503:
        throw NetworkException(
          message: 'Server error',
          code: 'SERVER_ERROR',
        );
      default:
        throw NetworkException(
          message: errorMessage,
          code: errorCode,
        );
    }
  }

  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: 'Connection timeout',
          code: 'TIMEOUT',
          originalException: e,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
          originalException: e,
        );
      case DioExceptionType.unknown:
        return NetworkException(
          message: e.message ?? 'Unknown error',
          code: 'UNKNOWN',
          originalException: e,
        );
      default:
        return NetworkException(
          message: e.message ?? 'Request failed',
          code: 'REQUEST_FAILED',
          originalException: e,
        );
    }
  }
}

class _TokenInterceptor extends Interceptor {
  final DioClient client;

  _TokenInterceptor(this.client);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = client.getAuthToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  final AppLogger logger;

  _ErrorInterceptor(this.logger);

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
