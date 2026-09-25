import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/api/dio_client.dart';
import '../services/storage/secure_storage.dart';
import '../services/logger/app_logger.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Logger
  getIt.registerSingleton<AppLogger>(AppLogger());

  // Secure Storage
  getIt.registerSingleton<SecureStorageService>(
    SecureStorageService(),
  );

  // Hive Database
  await Hive.initFlutter();
  
  // Dio/API Client
  final dioClient = DioClient(
    baseUrl: 'https://api.example.com',
    logger: getIt<AppLogger>(),
  );
  getIt.registerSingleton<DioClient>(dioClient);
  getIt.registerSingleton<Dio>(dioClient.dio);
}