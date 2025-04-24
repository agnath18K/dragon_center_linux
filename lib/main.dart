import 'package:dragon_center_linux/app.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';
import 'package:dragon_center_linux/models/fan_config.dart';

import 'package:dragon_center_linux/core/services/tray_service.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager
  await windowManager.ensureInitialized();

  // Configure window manager with desired settings
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    center: true,
    backgroundColor: Colors.black,
    skipTaskbar: true, // Don't show in taskbar
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // Hide the window when the app starts
    await windowManager.hide();
  });

  await initializeLogger();
  logger.info('Starting Dragon Center application');

  await FanConfig.loadConfig();

  await TrayService().initialize();

  runApp(const DragonCentreApp());
}
