import 'package:shared_preferences/shared_preferences.dart';
import 'package:dragon_center_linux/core/utils/ec_helper.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';
import 'package:dragon_center_linux/models/fan_config.dart';
import 'package:dragon_center_linux/shared/services/config_manager.dart';

class SetupException implements Exception {
  final String message;
  final dynamic originalError;
  SetupException(this.message, [this.originalError]);
  @override
  String toString() =>
      'SetupException: $message${originalError != null ? ' ($originalError)' : ''}';
}

class SetupService {
  final ConfigManager _configManager = ConfigManager();

  Future<void> runSetupWizard(SharedPreferences prefs) async {
    try {
      await prefs.setBool('firstRun', false);
      logger.info('Setup wizard completed successfully');
    } catch (e) {
      logger.severe('Failed to save first run status: $e');
      throw SetupException('Failed to save first run status', e);
    }
  }

  Future<void> handleProfileSelection(bool universal) async {
    try {
      FanConfig.autoSpeed = universal
          ? List.from(_configManager.currentConfig.defaultAutoSpeed)
          : await _readCurrentFanSpeeds();

      FanConfig.advancedSpeed =
          List.from(_configManager.currentConfig.defaultAdvancedSpeed);
      logger.info('Profile selection completed - Universal: $universal');
    } catch (e) {
      logger.severe('Failed to read EC values: $e');
      FanConfig.autoSpeed =
          List.from(_configManager.currentConfig.defaultAutoSpeed);
      FanConfig.advancedSpeed =
          List.from(_configManager.currentConfig.defaultAdvancedSpeed);
      throw SetupException('Failed to handle profile selection', e);
    }
  }

  Future<List<List<int>>> _readCurrentFanSpeeds() async {
    try {
      final speeds = [
        await Future.wait(FanConfig.fanAddresses[0].map((addr) =>
            ECHelper.read(addr).then(
                (v) => v.clamp(0, _configManager.currentConfig.maxFanSpeed)))),
        await Future.wait(FanConfig.fanAddresses[1].map((addr) =>
            ECHelper.read(addr).then(
                (v) => v.clamp(0, _configManager.currentConfig.maxFanSpeed)))),
      ];
      logger.fine('Read current fan speeds: $speeds');
      return speeds;
    } catch (e) {
      logger.severe('Failed to read current fan speeds: $e');
      rethrow;
    }
  }

  Future<void> handleCpuGeneration(bool isNewGen) async {
    try {
      FanConfig.cpuGen = isNewGen ? 1 : 0;
      FanConfig.autoAdvancedValues = List.from(_configManager
          .currentConfig.cpuGenAutoAdvancedValues[FanConfig.cpuGen]!);
      FanConfig.coolerBoosterValues = List.from(_configManager
          .currentConfig.cpuGenCoolerBoosterValues[FanConfig.cpuGen]!);
      await FanConfig.saveConfig();
      logger.info('CPU generation set to: ${isNewGen ? "New" : "Old"}');
    } catch (e) {
      logger.severe('Failed to handle CPU generation: $e');
      throw SetupException('Failed to handle CPU generation', e);
    }
  }

}
