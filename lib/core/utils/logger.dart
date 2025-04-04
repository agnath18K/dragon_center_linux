import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

final logger = Logger('DragonCenter');

Future<void> initializeLogger() async {
  if (kDebugMode) {
    print('Initializing logging system...');
  }
  if (kDebugMode) {
    print('Debug mode: $kDebugMode');
  }

  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  if (kDebugMode) {
    print('Logging level set to: ${Logger.root.level.name}');
  }

  final appDir = await getApplicationDocumentsDirectory();
  if (kDebugMode) {
    print('Application directory: ${appDir.path}');
  }

  final logsDir = Directory('${appDir.path}/logs');
  if (kDebugMode) {
    print('Logs directory: ${logsDir.path}');
  }

  if (!await logsDir.exists()) {
    if (kDebugMode) {
      print('Creating logs directory...');
    }
    await logsDir.create(recursive: true);
    if (kDebugMode) {
      print('Logs directory created successfully');
    }
  }

  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final logFile = File('${logsDir.path}/dragon_center_linux_$timestamp.log');
  if (kDebugMode) {
    print('Log file path: ${logFile.path}');
  }

  Logger.root.onRecord.listen((record) {
    final message =
        '${record.time.toIso8601String()} ${record.level.name}: ${record.message}';

    if (record.level.value >= (kDebugMode ? Level.ALL : Level.INFO).value) {
      if (kDebugMode) {
        print(message);
      }
    }

    logFile.writeAsStringSync('$message\n', mode: FileMode.append);
  });

  if (kDebugMode) {
    print('Logging system initialized successfully');
  }
}
