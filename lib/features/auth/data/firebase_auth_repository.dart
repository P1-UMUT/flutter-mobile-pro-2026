// lib/features/auth/data/firebase_auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/storage/secure_storage_service.dart';
import '../domain/models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({required String name, required String email, required String password});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<String?> refreshToken();
}

class FirebaseAuthDataSource implements AuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SecureStorageService _storage;

  FirebaseAuthDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required SecureStorageService storage,
  })  : _auth = auth,
        _firestore = firestore,
        _storage = storage;

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) throw AuthException('Giriş başarısız.');

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        throw DatabaseException('Kullanıcı profili bulunamadı.');
      }

      final data = doc.data() ?? {};
      final userModel = UserModel.fromMap(data);

      final token = await user.getIdToken();
      if (token != null) {
        await _storage.saveAuthToken(token);
        await _storage.saveUserId(user.uid);
        await _storage.saveUserEmail(user.email ?? '');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Giriş sırasında hata oluştu.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Giriş sırasında beklenmeyen bir hata oluştu.');
    }
  }

  @override
  Future<UserModel> signUp({required String name, required String email, required String password}) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) throw AuthException('Kayıt işlemi başarısız.');

      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      final token = await user.getIdToken();
      if (token != null) {
        await _storage.saveAuthToken(token);
        await _storage.saveUserId(user.uid);
        await _storage.saveUserEmail(email);
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Kayıt sırasında hata oluştu.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Kayıt sırasında beklenmeyen bir hata oluştu.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _storage.clearSession();
    } catch (e) {
      throw AuthException('Çıkış sırasında hata oluştu.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data() ?? {});
  }

  @override
  Future<String?> refreshToken() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final token = await currentUser.getIdToken(true);
      if (token != null) {
        await _storage.saveAuthToken(token);
      }
      return token;
    } catch (e) {
      throw AuthException('Refresh token alınamadı.');
    }
  }
}
