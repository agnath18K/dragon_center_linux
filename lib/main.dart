
import 'package:dragon_center_linux/app.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';
import 'package:dragon_center_linux/models/fan_config.dart';

import 'package:dragon_center_linux/core/services/tray_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeLogger();
  logger.info('Starting Dragon Center application');

  await FanConfig.loadConfig();

  await TrayService().initialize();

  runApp(const DragonCentreApp());
}
