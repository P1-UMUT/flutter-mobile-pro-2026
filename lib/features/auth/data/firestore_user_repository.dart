import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/logger/app_logger.dart';

class FirestoreUserRepository {
  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  FirestoreUserRepository({
    required FirebaseFirestore firestore,
    required AppLogger logger,
  })
      : _firestore = firestore,
        _logger = logger;

  Future<UserModel> getUserById(String userId) async {
    try {
      _logger.info('Fetching user: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw NotFoundException(
          message: 'Kullanıcı bulunamadı',
          code: 'USER_NOT_FOUND',
        );
      }

      final data = doc.data() ?? {};
      return UserModel.fromJson(data);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      _logger.error('Error fetching user', e);
      throw DatabaseException(
        message: 'Kullanıcı verisi alınamadı',
        code: 'FETCH_USER_ERROR',
        originalException: e,
      );
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      _logger.info('Updating user: $userId');
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(data);
      _logger.info('User updated successfully');
    } catch (e) {
      _logger.error('Error updating user', e);
      throw DatabaseException(
        message: 'Kullanıcı güncellenemedi',
        code: 'UPDATE_USER_ERROR',
        originalException: e,
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      _logger.info('Deleting user: $userId');
      await _firestore.collection('users').doc(userId).delete();
      _logger.info('User deleted successfully');
    } catch (e) {
      _logger.error('Error deleting user', e);
      throw DatabaseException(
        message: 'Kullanıcı silinemedi',
        code: 'DELETE_USER_ERROR',
        originalException: e,
      );
    }
  }

  Stream<UserModel?> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data() ?? {});
    }).handleError((e) {
      _logger.error('Error watching user', e);
    });
  }
}
