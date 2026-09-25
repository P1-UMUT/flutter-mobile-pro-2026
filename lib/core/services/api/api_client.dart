// lib/core/services/api/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../exceptions/app_exceptions.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.example.com',
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // refresh token logic here
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<T> get<T>({
    required String path,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await _dio.get(path);
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return parser(response.data);
      }
      throw _handleStatus(response.statusCode, response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleStatus(int? statusCode, dynamic data) {
    final message = data is Map ? data['message'] ?? 'Hata oluştu' : 'Hata oluştu';
    switch (statusCode) {
      case 400:
        return ValidationException(message);
      case 401:
        return UnauthorizedException(message);
      case 404:
        return NotFoundException(message);
      case 500:
        return NetworkException(message);
      default:
        return AppException(message);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return TimeoutException('Bağlantı zaman aşımı.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException('İnternet bağlantısı yok.');
    }
    return NetworkException(e.message ?? 'API hatası');
  }
}
