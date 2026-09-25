// lib/core/di/injection.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api/dio_client.dart';
import '../services/logger/app_logger.dart';
import '../services/storage/secure_storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Logger
  getIt.registerSingleton<AppLogger>(AppLogger());

  // Secure storage
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  getIt.registerSingleton<SecureStorageService>(
    SecureStorageService(storage: getIt<FlutterSecureStorage>()),
  );

  // Firebase
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // API client
  getIt.registerSingleton<DioClient>(
    DioClient(
      baseUrl: 'https://api.example.com',
      logger: getIt<AppLogger>(),
    ),
  );
}
