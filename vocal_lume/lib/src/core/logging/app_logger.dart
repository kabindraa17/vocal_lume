import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Centralized app logger with consistent formatting and severity levels.
abstract final class AppLogger {
  static void debug(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, tag: tag, level: 500, error: error, stackTrace: stackTrace);
  }

  static void info(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, tag: tag, level: 800, error: error, stackTrace: stackTrace);
  }

  static void warning(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, tag: tag, level: 900, error: error, stackTrace: stackTrace);
  }

  static void error(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(message, tag: tag, level: 1000, error: error, stackTrace: stackTrace);
  }

  static String toPrettyJson(Object? value) {
    if (value == null) return 'null';
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static void _log(
    String message, {
    required String tag,
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final text = '[$tag] $message';
    developer.log(
      text,
      name: 'vocal_lume',
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
    if (kDebugMode) {
      debugPrint(text);
      if (error != null) debugPrint('[$tag] error: $error');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}
