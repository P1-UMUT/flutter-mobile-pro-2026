// lib/features/auth/data/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../domain/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({required String name, required String email, required String password});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        throw AuthException('Giriş başarısız.');
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      if (data == null) {
        throw DatabaseException('Kullanıcı profili bulunamadı.');
      }

      return UserModel.fromMap(data);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Kimlik doğrulama hatası.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Beklenmeyen hata oluştu.');
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
      if (user == null) {
        throw AuthException('Kayıt işlemi başarısız.');
      }

      final userData = {
        'uid': user.uid,
        'displayName': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      return UserModel(
        id: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Kayıt işlemi başarısız.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Kayıt işlemi sırasında hata oluştu.');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data() ?? {});
  }
}
