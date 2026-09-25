// lib/features/auth/application/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/logger/app_logger.dart';
import '../../../core/services/storage/secure_storage_service.dart';
import '../data/firebase_auth_repository.dart';
import '../domain/models/user_model.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(storage: const FlutterSecureStorage());
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final loggerProvider = Provider<AppLogger>((ref) => AppLogger());

final firebaseAuthDataSourceProvider = Provider<AuthDataSource>((ref) {
  return FirebaseAuthDataSource(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  AuthController(this._dataSource, this._logger) : super(const AsyncValue.data(null));

  final AuthDataSource _dataSource;
  final AppLogger _logger;

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _dataSource.signIn(email: email, password: password);
      state = AsyncValue.data(user);
      _logger.info('User signed in: ${user.email}');
      return true;
    } catch (error, stackTrace) {
      _logger.error('Sign in failed', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> signUp({required String name, required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _dataSource.signUp(name: name, email: email, password: password);
      state = AsyncValue.data(user);
      _logger.info('User signed up: ${user.email}');
      return true;
    } catch (error, stackTrace) {
      _logger.error('Sign up failed', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      _logger.error('Sign out failed', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _dataSource.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      _logger.error('Load current user failed', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  return AuthController(
    ref.watch(firebaseAuthDataSourceProvider),
    ref.watch(loggerProvider),
  );
});
