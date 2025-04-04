import 'package:flutter/foundation.dart';
import 'package:dragon_center_linux/core/utils/ec_helper.dart';
import '../../../models/msi_config.dart';

enum FanProfile {
  auto,
  basic,
  advanced,
  boost,
}

class FanControlViewModel extends ChangeNotifier {
  bool _isCoolerBoostEnabled = false;
  bool _isLoading = false;
  String _error = '';

  bool get isCoolerBoostEnabled => _isCoolerBoostEnabled;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> initialize() async {
    try {
      await MSIConfig.loadConfig();
      MSIConfig.setCurrentModel('16U5EMS1');

      await ECHelper.write(MSIConfig.fanModeAddress, MSIConfig.fanMode);

      final coolerBoostValue =
          await ECHelper.read(MSIConfig.coolerBoostAddress);
      _isCoolerBoostEnabled = coolerBoostValue == MSIConfig.coolerBoostOn;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize fan control: $e';
      notifyListeners();
    }
  }

  Future<void> toggleCoolerBoost() async {
    try {
      _isLoading = true;
      notifyListeners();

      final newValue = _isCoolerBoostEnabled
          ? MSIConfig.coolerBoostOff
          : MSIConfig.coolerBoostOn;
      await ECHelper.write(MSIConfig.coolerBoostAddress, newValue);

      _isCoolerBoostEnabled = !_isCoolerBoostEnabled;
      _error = '';
    } catch (e) {
      _error = 'Failed to toggle CoolerBoost: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyFanProfile(FanProfile profile) async {
    try {
      _isLoading = true;
      notifyListeners();

      switch (profile) {
        case FanProfile.auto:
          await _applyAutoProfile();
          break;
        case FanProfile.basic:
          await _applyBasicProfile();
          break;
        case FanProfile.advanced:
          await _applyAdvancedProfile();
          break;
        case FanProfile.boost:
          await _applyBoostProfile();
          break;
      }

      _error = '';
    } catch (e) {
      _error = 'Failed to apply fan profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applyAutoProfile() async {
    await ECHelper.write(MSIConfig.fanModeAddress, MSIConfig.fanMode);

    for (int i = 0; i < MSIConfig.cpuFanSpeedAddresses.length; i++) {
      await ECHelper.write(
          MSIConfig.cpuFanSpeedAddresses[i], MSIConfig.cpuFanSpeeds[i]);
    }

    for (int i = 0; i < MSIConfig.gpuFanSpeedAddresses.length; i++) {
      await ECHelper.write(
          MSIConfig.gpuFanSpeedAddresses[i], MSIConfig.gpuFanSpeeds[i]);
    }
  }

  Future<void> _applyBasicProfile() async {
    await ECHelper.write(MSIConfig.fanModeAddress, MSIConfig.fanMode + 1);

    for (int i = 0; i < MSIConfig.cpuFanSpeedAddresses.length; i++) {
      final speed = (MSIConfig.cpuFanSpeeds[i] * 1.1).round().clamp(0, 100);
      await ECHelper.write(MSIConfig.cpuFanSpeedAddresses[i], speed);
    }

    for (int i = 0; i < MSIConfig.gpuFanSpeedAddresses.length; i++) {
      final speed = (MSIConfig.gpuFanSpeeds[i] * 1.1).round().clamp(0, 100);
      await ECHelper.write(MSIConfig.gpuFanSpeedAddresses[i], speed);
    }
  }

  Future<void> _applyAdvancedProfile() async {
    await ECHelper.write(MSIConfig.fanModeAddress, MSIConfig.fanMode + 2);

    for (int i = 0; i < MSIConfig.cpuFanSpeedAddresses.length; i++) {
      final speed = (MSIConfig.cpuFanSpeeds[i] * 1.2).round().clamp(0, 100);
      await ECHelper.write(MSIConfig.cpuFanSpeedAddresses[i], speed);
    }

    for (int i = 0; i < MSIConfig.gpuFanSpeedAddresses.length; i++) {
      final speed = (MSIConfig.gpuFanSpeeds[i] * 1.2).round().clamp(0, 100);
      await ECHelper.write(MSIConfig.gpuFanSpeedAddresses[i], speed);
    }
  }

  Future<void> _applyBoostProfile() async {
    await ECHelper.write(MSIConfig.fanModeAddress, MSIConfig.fanMode + 3);

    for (int i = 0; i < MSIConfig.cpuFanSpeedAddresses.length; i++) {
      final speed = (MSIConfig.cpuFanSpeeds[i] * 1.3).round().clamp(0, 100);
      await ECHelper.write(MSIConfig.cpuFanSpeedAddresses[i], speed);
    }

    for (int i = 0; i < MSIConfig.gpuFanSpeedAddresses.length; i++) {
      final speed = (MSIConfig.gpuFanSpeeds[i] * 1.3).round().clamp(0, 100);
      await ECHelper.write(MSIConfig.gpuFanSpeedAddresses[i], speed);
    }
  }

  Future<Map<String, dynamic>> getFanStatus() async {
    try {
      final cpuTemp = await ECHelper.read(MSIConfig.realtimeCpuTempAddress);
      final cpuFanSpeed =
          await ECHelper.read(MSIConfig.realtimeCpuFanSpeedAddress);
      final cpuFanRpm =
          await ECHelper.readRPM(MSIConfig.realtimeCpuFanRpmAddress);

      final gpuTemp = await ECHelper.read(MSIConfig.realtimeGpuTempAddress);
      final gpuFanSpeed =
          await ECHelper.read(MSIConfig.realtimeGpuFanSpeedAddress);
      final gpuFanRpm =
          await ECHelper.readRPM(MSIConfig.realtimeGpuFanRpmAddress);

      return {
        'cpu': {
          'temperature': cpuTemp,
          'fanSpeed': cpuFanSpeed,
          'fanRpm': cpuFanRpm,
        },
        'gpu': {
          'temperature': gpuTemp,
          'fanSpeed': gpuFanSpeed,
          'fanRpm': gpuFanRpm,
        },
      };
    } catch (e) {
      _error = 'Failed to get fan status: $e';
      notifyListeners();
      return {};
    }
  }
}
