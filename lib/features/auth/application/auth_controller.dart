import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_repository.dart';
import '../domain/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => DemoAuthRepository(const FlutterSecureStorage()));

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  AuthController(this._repository) : super(const AsyncValue.data(null));
  final AuthRepository _repository;

  Future<bool> login({required String email, required String password}) => _run(() => _repository.login(email: email, password: password));
  Future<bool> register({required String name, required String email, required String password}) => _run(() => _repository.register(name: name, email: email, password: password));

  Future<bool> _run(Future<UserModel> Function() operation) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await operation());
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) => AuthController(ref.watch(authRepositoryProvider)));
