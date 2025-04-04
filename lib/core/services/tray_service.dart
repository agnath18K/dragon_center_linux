import 'package:system_tray/system_tray.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';
import 'package:dragon_center_linux/features/fan_control/presentation/viewmodels/fan_control_viewmodel.dart';
import 'package:path/path.dart' as path;

class TrayService {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  final _systemTray = SystemTray();
  final _menu = Menu();
  bool _isInitialized = false;
  final _dragonControlProvider = DragonControlProvider();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _systemTray.initSystemTray(
        title: "Dragon Center",
        iconPath: path.join('assets', 'images', 'dragon.png'),
      );

      await _createMenu();

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          _systemTray.popUpContextMenu();
        } else if (eventName == kSystemTrayEventRightClick) {
          _systemTray.popUpContextMenu();
        }
      });

      _isInitialized = true;
      logger.info('System tray initialized successfully');
    } catch (e) {
      logger.severe('Failed to initialize system tray: $e');
      _isInitialized = true;
    }
  }

  Future<void> _createMenu() async {
    try {
      final showItem = MenuItemLabel(
        label: 'Show Dragon Center',
        onClicked: (menuItem) => _handleShow(),
      );

      final fanProfileSubMenu = SubMenu(
        label: 'Fan Profile',
        children: [
          MenuItemLabel(
            label: 'Auto',
            onClicked: (menuItem) => _handleFanProfile(1),
          ),
          MenuItemLabel(
            label: 'Basic',
            onClicked: (menuItem) => _handleFanProfile(2),
          ),
          MenuItemLabel(
            label: 'Advanced',
            onClicked: (menuItem) => _handleFanProfile(3),
          ),
          MenuItemLabel(
            label: 'Cooler Boost',
            onClicked: (menuItem) => _handleFanProfile(4),
          ),
        ],
      );

      final batterySubMenu = SubMenu(
        label: 'Battery Threshold',
        children: [
          MenuItemLabel(
            label: '100% (Full Charge)',
            onClicked: (menuItem) => _handleBatteryThreshold(100),
          ),
          MenuItemLabel(
            label: '90%',
            onClicked: (menuItem) => _handleBatteryThreshold(90),
          ),
          MenuItemLabel(
            label: '80%',
            onClicked: (menuItem) => _handleBatteryThreshold(80),
          ),
          MenuItemLabel(
            label: '70%',
            onClicked: (menuItem) => _handleBatteryThreshold(70),
          ),
          MenuItemLabel(
            label: '60%',
            onClicked: (menuItem) => _handleBatteryThreshold(60),
          ),
        ],
      );

      final exitItem = MenuItemLabel(
        label: 'Exit',
        onClicked: (menuItem) => _handleExit(),
      );

      await _menu.buildFrom([
        showItem,
        MenuSeparator(),
        fanProfileSubMenu,
        MenuSeparator(),
        batterySubMenu,
        MenuSeparator(),
        exitItem,
      ]);

      await _systemTray.setContextMenu(_menu);
    } catch (e) {
      logger.severe('Failed to create tray menu: $e');
    }
  }

  void _handleShow() {
    try {
      logger.info('Show Dragon Center clicked');
    } catch (e) {
      logger.severe('Failed to handle show window: $e');
    }
  }

  Future<void> _handleFanProfile(int profile) async {
    try {
      await _dragonControlProvider.setFanProfile(profile);
      logger.info('Fan profile set to: $profile');
    } catch (e) {
      logger.severe('Failed to set fan profile: $e');
    }
  }

  Future<void> _handleBatteryThreshold(int threshold) async {
    try {
      await _dragonControlProvider.setBatteryThreshold(threshold);
      logger.info('Battery threshold set to: $threshold%');
    } catch (e) {
      logger.severe('Failed to set battery threshold: $e');
    }
  }

  Future<void> _handleExit() async {
    try {
      await dispose();
    } catch (e) {
      logger.severe('Failed to handle exit: $e');
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        _dragonControlProvider.dispose();
        await _systemTray.destroy();
      } catch (e) {
        logger.warning('Failed to dispose system tray: $e');
      }
      _isInitialized = false;
    }
  }
}
