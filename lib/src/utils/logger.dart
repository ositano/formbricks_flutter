import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Singleton logging utility that wraps the [Logger] package for consistent logging across the app.
///
/// Logs are only printed in debug mode using `kDebugMode`.
/// Provides methods for logging debug, warning, and error messages.
class Log {
  /// Internal Logger instance from the `logger` package
  static Logger? _logger;

  /// Singleton instance of the Log class
  static Log? _instance = Log._internal();

  /// Factory constructor that returns the singleton instance of [Log].
  factory Log() {
    _instance ??= Log._internal();
    return _instance!;
  }

  /// Static getter to retrieve the existing [Log] instance.
  ///
  /// Throws an exception if the instance hasn't been initialized.
  static Log get instance {
    if (_instance == null) {
      throw Exception("Log has not been initialized.");
    }
    return _instance!;
  }

  /// Private constructor for initializing the singleton.
  /// Sets up the [Logger] with default settings if not already configured.
  Log._internal(){
    if (!(_logger != null)) {
      _logger = Logger(
        filter: null, // Default filter: logs only in debug mode
        printer: PrettyPrinter(), // Pretty output formatting
        output: null, // Default output: prints to console
      );
    }
  }

  /// Logs a debug message.
  ///
  /// Only outputs if the app is in debug mode.
  void d(dynamic message) {
    if (kDebugMode) {
      _logger?.d(message);
    }
  }

  /// Logs an error message.
  ///
  /// Only outputs if the app is in debug mode.
  void e(dynamic message) {
    if (kDebugMode) {
      _logger?.e(message);
    }
  }

  /// Logs a warning message.
  ///
  /// Only outputs if the app is in debug mode.
  void w(dynamic message) {
    if (kDebugMode) {
      _logger?.w(message);
    }
  }
}
