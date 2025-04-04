import 'package:flutter/foundation.dart';
import 'package:dragon_center_linux/core/utils/ec_helper.dart';
import 'package:dragon_center_linux/features/battery_control/models/battery_config.dart';
import 'package:dragon_center_linux/shared/services/config_manager.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';

class BatteryViewModel extends ChangeNotifier {
  BatteryConfig _config = BatteryConfig.initial();

  bool _isProcessing = false;

  final ConfigManager _configManager = ConfigManager();

  BatteryConfig get config => _config;
  bool get isProcessing => _isProcessing;

  Future<void> setBatteryThreshold(int threshold) async {
    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();

    try {
      final config = _configManager.currentConfig;
      final value = threshold + 128;
      await ECHelper.write(config.batteryThresholdAddress, value);

      _config = _config.copyWith(threshold: threshold);
      notifyListeners();
    } catch (e) {
      logger.severe('Failed to set battery threshold: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void initializeConfig() {
    final config = _configManager.currentConfig;
    _config = BatteryConfig(
      threshold: config.defaultBatteryThreshold,
      minThreshold: config.minBatteryThreshold,
      maxThreshold: config.maxBatteryThreshold,
      divisions: config.batteryThresholdDivisions,
    );
    notifyListeners();
  }
}
