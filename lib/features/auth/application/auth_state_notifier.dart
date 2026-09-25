import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/firebase_auth_service.dart';
import '../data/firestore_user_repository.dart';
import '../domain/models/user_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/logger/app_logger.dart';

class AuthStateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthStateNotifier(this._authService, this._userRepository, this._logger)
      : super(const AsyncValue.data(null));

  final FirebaseAuthService _authService;
  final FirestoreUserRepository _userRepository;
  final AppLogger _logger;

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      _logger.info('Starting sign up process');
      final response = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (response.success && response.user != null) {
        final user = UserModel(
          id: response.user!.uid,
          name: response.user!.displayName ?? '',
          email: response.user!.email,
          photoUrl: response.user!.photoUrl,
          createdAt: DateTime.now(),
        );
        state = AsyncValue.data(user);
        _logger.info('Sign up successful');
      } else {
        throw AuthException(
          message: response.errorMessage ?? 'Kayıt başarısız',
          code: 'SIGNUP_FAILED',
        );
      }
    } catch (error, stackTrace) {
      _logger.error('Sign up error', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      _logger.info('Starting sign in process');
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.success && response.user != null) {
        final user = UserModel(
          id: response.user!.uid,
          name: response.user!.displayName ?? '',
          email: response.user!.email,
          photoUrl: response.user!.photoUrl,
          createdAt: DateTime.now(),
        );
        state = AsyncValue.data(user);
        _logger.info('Sign in successful');
      } else {
        throw AuthException(
          message: response.errorMessage ?? 'Giriş başarısız',
          code: 'SIGNIN_FAILED',
        );
      }
    } catch (error, stackTrace) {
      _logger.error('Sign in error', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
      _logger.info('Sign out successful');
    } catch (error, stackTrace) {
      _logger.error('Sign out error', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      _logger.info('Password reset email sent');
    } catch (error, stackTrace) {
      _logger.error('Password reset error', error, stackTrace);
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final userModel = await _userRepository.getUserById(currentUser.uid);
      state = AsyncValue.data(userModel);
    } catch (error, stackTrace) {
      _logger.error('Refresh user error', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  final userRepository =
      FirestoreUserRepository(firestore: FirebaseFirestore.instance, logger: ref.watch(appLoggerProvider));
  return AuthStateNotifier(authService, userRepository, ref.watch(appLoggerProvider));
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(firebaseAuthServiceProvider);
  final currentFirebaseUser = authService.getCurrentUser();
  if (currentFirebaseUser == null) return null;

  return UserModel(
    id: currentFirebaseUser.uid,
    name: currentFirebaseUser.displayName ?? '',
    email: currentFirebaseUser.email ?? '',
    photoUrl: currentFirebaseUser.photoURL,
    createdAt: DateTime.now(),
  );
});
