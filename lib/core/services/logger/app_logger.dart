import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class AppLogger {
  late final Logger _logger;

  AppLogger() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  void debug(String message, [dynamic error]) {
    _logger.d(message, error: error);
  }

  void info(String message) {
    _logger.i(message);
  }

  void warning(String message, [dynamic error]) {
    _logger.w(message, error: error);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

final appLoggerProvider = Provider<AppLogger>((ref) => AppLogger());
