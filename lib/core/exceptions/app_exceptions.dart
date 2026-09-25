abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => '$runtimeType: $message';
}

class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
        message: message,
        code: code,
        originalException: originalException,
      );
}

class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
        message: message,
        code: code,
        originalException: originalException,
      );
}

class DatabaseException extends AppException {
  DatabaseException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
        message: message,
        code: code,
        originalException: originalException,
      );
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException({
    required String message,
    String? code,
    this.fieldErrors,
    dynamic originalException,
  }) : super(
        message: message,
        code: code,
        originalException: originalException,
      );
}

class CacheException extends AppException {
  CacheException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
        message: message,
        code: code,
        originalException: originalException,
      );
}

class UnauthorizedException extends AuthException {
  UnauthorizedException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
        message: message,
        code: code,
        originalException: originalException,
      );
}

class NotFoundException extends AppException {
  NotFoundException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
        message: message,
        code: code,
        originalException: originalException,
      );
}
