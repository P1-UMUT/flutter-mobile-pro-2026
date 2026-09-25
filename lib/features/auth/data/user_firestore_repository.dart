// lib/features/auth/data/user_firestore_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../domain/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> getUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
}

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  @override
  Future<UserModel> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) throw NotFoundException('Kullanıcı bulunamadı.');
      return UserModel.fromMap(doc.data() ?? {});
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Veri çekme işlemi başarısız.');
    }
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Profil güncellenemedi.');
    }
  }
}
