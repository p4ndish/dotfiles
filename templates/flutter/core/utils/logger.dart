import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

enum LogLevel { success, info, warning, error }

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static String _getCallerInfo() {
    try {
      final frames = StackTrace.current.toString().split('\n');
      // Skip first frames which are from the logger itself
      final callerFrame = frames.firstWhere(
        (frame) => !frame.contains('AppLogger') && frame.contains('dart:'),
        orElse: () => frames[0],
      );

      // Extract file name and line number
      final fileInfo = callerFrame.split('(')[1].split(')')[0];
      final fileName = path.basename(fileInfo.split(':')[0]);
      final lineNumber = fileInfo.split(':')[1];

      return '[$fileName:$lineNumber]';
    } catch (e) {
      return '[unknown]';
    }
  }

  static void log(LogLevel level, String message) {
    final callerInfo = _getCallerInfo();
    final formattedMessage = '$callerInfo $message';

    switch (level) {
      case LogLevel.success:
        _logger.i('✅ SUCCESS: $formattedMessage');
        break;
      case LogLevel.info:
        _logger.i('ℹ️ INFO: $formattedMessage');
        break;
      case LogLevel.warning:
        _logger.w('⚠️ WARNING: $formattedMessage');
        break;
      case LogLevel.error:
        _logger.e('❌ ERROR: $formattedMessage');
        break;
    }
  }

  // Convenience methods
  static void success(String message) => log(LogLevel.success, message);
  static void info(String message) => log(LogLevel.info, message);
  static void warning(String message) => log(LogLevel.warning, message);
  static void error(String message) => log(LogLevel.error, message);
}
