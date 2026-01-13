import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _dim = '\x1B[2m';

  static void info(String tag, String message) {
    _log(_blue, 'INFO', tag, message);
  }

  static void success(String tag, String message) {
    _log(_green, 'OK', tag, message);
  }

  static void warn(String tag, String message) {
    _log(_yellow, 'WARN', tag, message);
  }

  static void debug(String tag, String message) {
    _log(_cyan, 'DBG', tag, message);
  }

  static void batch(String tag, String message) {
    _log(_magenta, 'BATCH', tag, message);
  }

  static void _log(String color, String level, String tag, String message) {
    final String line = '$color[$level]$_reset$_dim [$tag]$_reset $message';
    debugPrint(line);
  }
}
