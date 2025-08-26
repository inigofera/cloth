import 'package:flutter/foundation.dart';

/// Centralized logging service for the app
class LoggerService {
  static const String _tag = '[Cloth]';
  
  /// Log debug information (only in debug mode)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_tag DEBUG: $message');
    }
  }
  
  /// Log info messages
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_tag INFO: $message');
    }
  }
  
  /// Log warning messages
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('$_tag WARNING: $message');
    }
  }
  
  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_tag ERROR: $message');
      if (error != null) {
        debugPrint('$_tag Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('$_tag Stack trace: $stackTrace');
      }
    }
  }
}
