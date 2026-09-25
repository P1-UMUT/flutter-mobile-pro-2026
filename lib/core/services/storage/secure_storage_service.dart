// lib/core/services/storage/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage storage;

  SecureStorageService({required this.storage});

  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  Future<void> write(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }

  Future<void> saveAuthToken(String token) async {
    await write(authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return read(authTokenKey);
  }

  Future<void> deleteAuthToken() async {
    await delete(authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await write(refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return read(refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await delete(refreshTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await write(userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return read(userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await write(userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    return read(userEmailKey);
  }

  Future<void> clearSession() async {
    await Future.wait([
      deleteAuthToken(),
      deleteRefreshToken(),
      delete(userIdKey),
      delete(userEmailKey),
    ]);
  }
}
