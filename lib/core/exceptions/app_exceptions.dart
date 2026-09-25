// lib/core/exceptions/app_exceptions.dart
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message';
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, code: 'UNAUTHORIZED');
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, code: 'NOT_FOUND');
}

class AuthException extends AppException {
  AuthException(String message) : super(message, code: 'AUTH_ERROR');
}

class DatabaseException extends AppException {
  DatabaseException(String message) : super(message, code: 'DATABASE_ERROR');
}

class CacheException extends AppException {
  CacheException(String message) : super(message, code: 'CACHE_ERROR');
}

class ParseException extends AppException {
  ParseException(String message) : super(message, code: 'PARSE_ERROR');
}

class TimeoutException extends AppException {
  TimeoutException(String message) : super(message, code: 'TIMEOUT');
}
