// lib/core/services/api/dio_client.dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../exceptions/app_exceptions.dart';
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
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await const FlutterSecureStorage().read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          logger.error('Dio error', error, error.stackTrace);
          handler.next(error);
        },
      ),
    );
  }

  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<T> post<T>({
    required String path,
    dynamic data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await dio.post(path, data: data);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  T _handleResponse<T>(Response response, T Function(dynamic) parser) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      return parser(response.data);
    }

    final message = response.data is Map ? response.data['message'] ?? 'İstek başarısız' : 'İstek başarısız';
    if (statusCode == 400) throw ValidationException(message);
    if (statusCode == 401 || statusCode == 403) throw UnauthorizedException(message);
    if (statusCode == 404) throw NotFoundException(message);
    if (statusCode >= 500) throw NetworkException(message);

    throw AppException(message);
  }

  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('Bağlantı zaman aşımı.');
      case DioExceptionType.connectionError:
        return NetworkException('İnternet bağlantısı yok.');
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 400) {
          return ValidationException('İstek verisi geçersiz.');
        }
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          return UnauthorizedException('Yetkiniz yok veya oturumunuz sona erdi.');
        }
        return NetworkException('Sunucu hatası oluştu.');
      default:
        return NetworkException(e.message ?? 'Bilinmeyen ağ hatası.');
    }
  }
}
