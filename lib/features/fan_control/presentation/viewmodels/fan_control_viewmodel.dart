import 'package:dragon_center_linux/core/utils/ec_helper.dart';
import 'package:dragon_center_linux/shared/services/config_manager.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dragon_center_linux/models/fan_config.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';
import 'package:flutter/foundation.dart';

class DragonControlProvider extends ChangeNotifier {
  List<int> temps = [0, 0]; // CPU and GPU temperatures

  List<int> rpms = [0, 0]; // CPU and GPU fan RPMs

  List<int> minMaxTemps = [100, 0, 100, 0]; // Min and max temps for CPU and GPU

  List<int> minMaxRPMs = [0, 0, 0, 0]; // Min and max RPMs for CPU and GPU

  bool _isProcessing = false; // Flag to prevent concurrent operations

  Timer? _updateTimer;

  final ConfigManager _configManager = ConfigManager();

  bool get isProcessing => _isProcessing;

  DragonControlProvider() {
    startMonitoring();
  }

  void startMonitoring() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      updateTemps();
      updateRPMs();
    });
  }

  void stopMonitoring() {
    _updateTimer?.cancel();
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }

  Future<void> updateTemps() async {
    try {
      final cpuTemp = await ECHelper.read(FanConfig.tempAddresses[0]);
      final gpuTemp = await ECHelper.read(FanConfig.tempAddresses[1]);

      temps = [cpuTemp, gpuTemp];
      minMaxTemps = [
        cpuTemp < minMaxTemps[0] ? cpuTemp : minMaxTemps[0],
        cpuTemp > minMaxTemps[1] ? cpuTemp : minMaxTemps[1],
        gpuTemp < minMaxTemps[2] ? gpuTemp : minMaxTemps[2],
        gpuTemp > minMaxTemps[3] ? gpuTemp : minMaxTemps[3],
      ];
      notifyListeners();
    } catch (e) {
      logger.severe('Temperature read error: $e');
    }
  }

  Future<void> updateRPMs() async {
    try {
      if (FanConfig.rpmAddresses.isEmpty) {
        logger.warning('RPM addresses not initialized');
        return;
      }

      final cpuRaw = await ECHelper.readRPM(FanConfig.rpmAddresses[0]);
      final gpuRaw = await ECHelper.readRPM(FanConfig.rpmAddresses[1]);

      final cpuRpm = (cpuRaw * _configManager.currentConfig.rpmDivisor) ~/ 1000;
      final gpuRpm = (gpuRaw * _configManager.currentConfig.rpmDivisor) ~/ 1000;

      logger.fine('CPU RPM calculation: raw=$cpuRaw, rpm=$cpuRpm');
      logger.fine('GPU RPM calculation: raw=$gpuRaw, rpm=$gpuRpm');

      rpms = [cpuRpm, gpuRpm];
      minMaxRPMs = [
        cpuRpm < minMaxRPMs[0] ? cpuRpm : minMaxRPMs[0],
        cpuRpm > minMaxRPMs[1] ? cpuRpm : minMaxRPMs[1],
        gpuRpm < minMaxRPMs[2] ? gpuRpm : minMaxRPMs[2],
        gpuRpm > minMaxRPMs[3] ? gpuRpm : minMaxRPMs[3],
      ];
      notifyListeners();
    } catch (e) {
      logger.severe('RPM read error: $e');
    }
  }

  List<List<int>> _checkFanSpeeds(List<List<int>> speeds, int offset) {
    final config = _configManager.currentConfig;
    return [
      speeds[0].map((s) => (s + offset).clamp(0, config.maxFanSpeed)).toList(),
      speeds[1].map((s) => (s + offset).clamp(0, config.maxFanSpeed)).toList(),
    ];
  }

  Future<void> applyAutoProfile() async {
    try {
      await ECHelper.write(
          FanConfig.autoAdvancedValues[0], FanConfig.autoAdvancedValues[1]);
      await ECHelper.write(
          FanConfig.coolerBoosterValues[0], FanConfig.coolerBoosterValues[1]);

      for (int i = 0; i < 7; i++) {
        await ECHelper.write(
            FanConfig.fanAddresses[0][i], FanConfig.autoSpeed[0][i]);
        await ECHelper.write(
            FanConfig.fanAddresses[1][i], FanConfig.autoSpeed[1][i]);
      }
    } catch (e) {
      logger.severe('Failed to apply Auto profile: $e');
      rethrow;
    }
  }

  Future<void> applyBasicProfile() async {
    try {
      await ECHelper.write(
          FanConfig.autoAdvancedValues[0], FanConfig.autoAdvancedValues[2]);
      await ECHelper.write(
          FanConfig.coolerBoosterValues[0], FanConfig.coolerBoosterValues[1]);

      final config = _configManager.currentConfig;
      final offset = FanConfig.basicOffset
          .clamp(config.minBasicOffset, config.maxBasicOffset);
      final speeds = _checkFanSpeeds(FanConfig.autoSpeed, offset);

      for (int i = 0; i < 7; i++) {
        await ECHelper.write(FanConfig.fanAddresses[0][i], speeds[0][i]);
        await ECHelper.write(FanConfig.fanAddresses[1][i], speeds[1][i]);
      }
    } catch (e) {
      logger.severe('Failed to apply Basic profile: $e');
      rethrow;
    }
  }

  Future<void> applyAdvancedProfile() async {
    try {
      final config = _configManager.currentConfig;
      final cpuGen = config.defaultCpuGen;
      final fanModeValues = config.cpuGenAutoAdvancedValues[cpuGen]!;
      final coolerBoostValues = config.cpuGenCoolerBoosterValues[cpuGen]!;

      await ECHelper.write(fanModeValues[0],
          fanModeValues[2]); // Write fan mode address with advanced value (140)
      await ECHelper.write(coolerBoostValues[0],
          coolerBoostValues[1]); // Write cooler boost address with off value

      for (int i = 0; i < 6; i++) {
        await ECHelper.write(0x6a + i, FanConfig.cpuFanCurve.temperatures[i]);
      }

      for (int i = 0; i < 6; i++) {
        await ECHelper.write(0x82 + i, FanConfig.gpuFanCurve.temperatures[i]);
      }

      for (int i = 0; i < 7; i++) {
        await ECHelper.write(0x72 + i, FanConfig.cpuFanCurve.fanSpeeds[i]);
      }

      for (int i = 0; i < 7; i++) {
        await ECHelper.write(0x8a + i, FanConfig.gpuFanCurve.fanSpeeds[i]);
      }

      await FanConfig.saveConfig();
      logger.info('Applied Advanced fan profile with custom fan curves');
    } catch (e) {
      logger.severe('Failed to apply Advanced profile: $e');
      rethrow;
    }
  }

  Future<void> applyCoolerBoost() async {
    try {
      await ECHelper.write(
          FanConfig.coolerBoosterValues[0], FanConfig.coolerBoosterValues[2]);
    } catch (e) {
      logger.severe('Failed to activate Cooler Boost: $e');
      rethrow;
    }
  }

  Future<void> setFanProfile(int profile) async {
    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();
    try {
      switch (profile) {
        case 1:
          await applyAutoProfile();
          break;
        case 2:
          await applyBasicProfile();
          break;
        case 3:
          await applyAdvancedProfile();
          break;
        case 4:
          await applyCoolerBoost();
          break;
      }
      FanConfig.profile = profile;
      await FanConfig.saveConfig();
    } catch (e) {
      logger.severe('Profile change failed: $e');
      rethrow; // Let UI handle the error
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> setBatteryThreshold(int threshold) async {
    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();
    try {
      final config = _configManager.currentConfig;
      final value = threshold + 128;
      await ECHelper.write(config.batteryThresholdAddress, value);
      FanConfig.batteryThreshold = threshold;
      await FanConfig.saveConfig();
      logger.info('Set battery threshold to $threshold%');
    } catch (e) {
      logger.severe('Failed to set battery threshold: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> setUsbBacklight(String level) async {
    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();
    try {
      final config = _configManager.currentConfig;
      int value;
      switch (level.toLowerCase()) {
        case 'off':
          value = config.usbBacklightOff;
          break;
        case 'half':
          value = config.usbBacklightHalf;
          break;
        case 'full':
          value = config.usbBacklightFull;
          break;
        default:
          throw ArgumentError('Invalid USB backlight level: $level');
      }
      await ECHelper.write(config.usbBacklightAddress, value);
    } catch (e) {
      logger.severe('Failed to set USB backlight: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
