import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/models/user_model.dart';

abstract interface class AuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String name, required String email, required String password});
  Future<void> logout();
  Future<UserModel?> currentUser();
}

/// Replace this implementation with a real backend adapter when the API contract is known.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this._storage);
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  @override
  Future<UserModel> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (password.length < 6) throw const FormatException('Şifre en az 6 karakter olmalıdır.');
    final user = UserModel(id: 'demo-user', name: email.split('@').first, email: email, createdAt: DateTime.now());
    await _persist(user);
    return user;
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    if (name.trim().length < 2) throw const FormatException('Ad en az 2 karakter olmalıdır.');
    return login(email: email, password: password);
  }

  Future<void> _persist(UserModel user) async {
    await _storage.write(key: _tokenKey, value: 'demo-token');
    await _storage.write(key: _userKey, value: user.toJson().toString());
  }

  @override
  Future<UserModel?> currentUser() async => null;

  @override
  Future<void> logout() async => _storage.deleteAll();
}
