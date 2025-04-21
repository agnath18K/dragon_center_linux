import 'package:dragon_center_linux/app.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';
import 'package:dragon_center_linux/models/fan_config.dart';
import 'package:dragon_center_linux/features/fan_control/presentation/viewmodels/fan_control_viewmodel.dart';

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

  // Apply saved configuration at startup
  await applyConfigAtStartup();

  await TrayService().initialize();

  runApp(const DragonCentreApp());
}

// Function to apply the saved fan profile configuration at startup
Future<void> applyConfigAtStartup() async {
  try {
    logger.info(
        'Applying saved fan profile (profile: ${FanConfig.profile}) at startup');

    final controlProvider = DragonControlProvider();
    // Apply the saved profile without changing the stored profile value
    switch (FanConfig.profile) {
      case 1:
        await controlProvider.applyAutoProfile();
        break;
      case 2:
        await controlProvider.applyBasicProfile();
        break;
      case 3:
        await controlProvider.applyAdvancedProfile();
        break;
      case 4:
        await controlProvider.applyCoolerBoost();
        break;
      default:
        logger.warning(
            'Unknown profile (${FanConfig.profile}), applying Auto profile as fallback');
        await controlProvider.applyAutoProfile();
        break;
    }

    // Clean up the temporary provider instance
    controlProvider.dispose();

    logger.info(
        'Successfully applied saved fan profile configuration at startup');
  } catch (e) {
    logger.severe('Failed to apply saved configuration at startup: $e');
  }
}
