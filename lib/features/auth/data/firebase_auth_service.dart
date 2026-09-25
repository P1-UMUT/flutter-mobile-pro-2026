import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exceptions/app_exceptions.dart';
import '../services/logger/app_logger.dart';
import '../services/storage/secure_storage.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final SecureStorageService _storage;
  final AppLogger _logger;

  FirebaseAuthService({
    required FirebaseAuth auth,
    required SecureStorageService storage,
    required AppLogger logger,
  })
      : _auth = auth,
        _storage = storage,
        _logger = logger;

  Future<FirebaseAuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _logger.info('Starting sign up for email: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException(
          message: 'User creation failed',
          code: 'USER_CREATION_FAILED',
        );
      }

      // Update display name
      await user.updateDisplayName(displayName);
      await user.reload();

      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get ID token
      final idToken = await user.getIdToken();

      // Save to secure storage
      if (idToken != null) {
        await _storage.saveAuthToken(idToken);
        await _storage.saveUserId(user.uid);
        await _storage.saveUserEmail(email);
        await _storage.saveLastLoginTime();
      }

      _logger.info('Sign up successful for user: ${user.uid}');

      return FirebaseAuthResponse(
        success: true,
        user: FirebaseUser(
          uid: user.uid,
          email: user.email!,
          displayName: displayName,
          photoUrl: null,
        ),
        token: idToken,
      );
    } on FirebaseAuthException catch (e) {
      _logger.error('Firebase auth error during sign up', e);
      throw _handleFirebaseException(e);
    } catch (e) {
      _logger.error('Unexpected error during sign up', e);
      throw AuthException(
        message: 'Sign up failed',
        code: 'SIGNUP_ERROR',
        originalException: e,
      );
    }
  }

  Future<FirebaseAuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Starting sign in for email: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException(
          message: 'Sign in failed',
          code: 'SIGNIN_FAILED',
        );
      }

      // Get ID token
      final idToken = await user.getIdToken();

      // Refresh user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException(
          message: 'User profile not found',
          code: 'PROFILE_NOT_FOUND',
        );
      }

      final userData = userDoc.data() ?? {};

      // Save to secure storage
      if (idToken != null) {
        await _storage.saveAuthToken(idToken);
        await _storage.saveUserId(user.uid);
        await _storage.saveUserEmail(user.email!);
        await _storage.saveLastLoginTime();
      }

      _logger.info('Sign in successful for user: ${user.uid}');

      return FirebaseAuthResponse(
        success: true,
        user: FirebaseUser(
          uid: user.uid,
          email: user.email!,
          displayName: userData['displayName'] ?? user.displayName,
          photoUrl: userData['photoUrl'],
        ),
        token: idToken,
      );
    } on FirebaseAuthException catch (e) {
      _logger.error('Firebase auth error during sign in', e);
      throw _handleFirebaseException(e);
    } catch (e) {
      _logger.error('Unexpected error during sign in', e);
      throw AuthException(
        message: 'Sign in failed',
        code: 'SIGNIN_ERROR',
        originalException: e,
      );
    }
  }

  Future<void> signOut() async {
    try {
      _logger.info('Signing out current user');
      await _auth.signOut();
      await _storage.clearAuthData();
      _logger.info('Sign out successful');
    } catch (e) {
      _logger.error('Error during sign out', e);
      throw AuthException(
        message: 'Sign out failed',
        code: 'SIGNOUT_ERROR',
        originalException: e,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _logger.info('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      _logger.info('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _logger.error('Firebase auth error during password reset', e);
      throw _handleFirebaseException(e);
    }
  }

  Future<String?> getCurrentToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return await user.getIdToken(true);
    } catch (e) {
      _logger.error('Error getting current token', e);
      return null;
    }
  }

  Future<bool> isTokenExpired() async {
    try {
      final lastLogin = await _storage.getLastLoginTime();
      if (lastLogin == null) return true;

      // Token expires after 1 hour
      return DateTime.now().difference(lastLogin).inHours >= 1;
    } catch (e) {
      return true;
    }
  }

  User? getCurrentUser() => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AppException _handleFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
          message: 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı',
          code: 'USER_NOT_FOUND',
        );
      case 'wrong-password':
        return AuthException(
          message: 'Şifre yanlış',
          code: 'WRONG_PASSWORD',
        );
      case 'email-already-in-use':
        return AuthException(
          message: 'Bu e-posta adresi zaten kullanımda',
          code: 'EMAIL_ALREADY_IN_USE',
        );
      case 'invalid-email':
        return ValidationException(
          message: 'Geçersiz e-posta adresi',
          code: 'INVALID_EMAIL',
          fieldErrors: {'email': 'Geçersiz e-posta'},
        );
      case 'weak-password':
        return ValidationException(
          message: 'Şifre çok zayıf',
          code: 'WEAK_PASSWORD',
          fieldErrors: {'password': 'En az 6 karakter olmalı'},
        );
      case 'network-request-failed':
        return NetworkException(
          message: 'İnternet bağlantısı başarısız',
          code: 'NETWORK_ERROR',
        );
      case 'too-many-requests':
        return AuthException(
          message: 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin',
          code: 'TOO_MANY_REQUESTS',
        );
      default:
        return AuthException(
          message: e.message ?? 'Kimlik doğrulama hatası',
          code: e.code,
          originalException: e,
        );
    }
  }
}

class FirebaseUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  FirebaseUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };
}

class FirebaseAuthResponse {
  final bool success;
  final FirebaseUser? user;
  final String? token;
  final String? errorMessage;

  FirebaseAuthResponse({
    required this.success,
    this.user,
    this.token,
    this.errorMessage,
  });
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  final logger = ref.watch(appLoggerProvider);
  return FirebaseAuthService(
    auth: FirebaseAuth.instance,
    storage: SecureStorageService(),
    logger: logger,
  );
});
