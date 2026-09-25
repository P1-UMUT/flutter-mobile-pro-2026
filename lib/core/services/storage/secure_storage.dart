import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';
  
  late final FlutterSecureStorage _storage;

  SecureStorageService() {
    _storage = const FlutterSecureStorage();
  }

  // Auth Token
  Future<void> saveAuthToken(String token) async {
    await _storage.write(
      key: _keyAuthToken,
      value: token,
    );
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _keyAuthToken);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: _keyRefreshToken,
      value: token,
    );
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _keyRefreshToken);
  }

  // User Data
  Future<void> saveUserData(String userData) async {
    await _storage.write(
      key: _keyUserData,
      value: userData,
    );
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: _keyUserData);
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: _keyUserData);
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}