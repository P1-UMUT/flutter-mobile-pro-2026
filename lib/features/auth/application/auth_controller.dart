// lib/features/auth/application/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../data/auth_repository.dart';
import '../domain/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class AuthState extends StateNotifier<AsyncValue<UserModel?>> {
  AuthState(this._repo) : super(const AsyncValue.data(null));

  final AuthRepository _repo;

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signIn(email: email, password: password);
      state = AsyncValue.data(user);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> signUp({required String name, required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signUp(name: name, email: email, password: password);
      state = AsyncValue.data(user);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repo.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthState, AsyncValue<UserModel?>>((ref) {
  return AuthState(ref.watch(authRepositoryProvider));
});
