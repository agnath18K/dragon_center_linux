import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dragon_center_linux/core/utils/ec_helper.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';
import 'package:dragon_center_linux/features/temperature_monitoring/models/temperature_data.dart';
import 'package:dragon_center_linux/shared/services/config_manager.dart';

class TemperatureViewModel extends ChangeNotifier {
  TemperatureData _data = TemperatureData(
    currentTemps: [0, 0],
    minMaxTemps: [100, 0, 100, 0],
    rpms: [0, 0],
  );

  final bool _isProcessing = false;

  Timer? _updateTimer;

  final ConfigManager _configManager = ConfigManager();

  TemperatureData get data => _data;
  bool get isProcessing => _isProcessing;
  List<int> get currentTemps => _data.currentTemps;
  List<int> get minMaxTemps => _data.minMaxTemps;
  List<int> get rpms => _data.rpms;

  TemperatureViewModel() {
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
      final cpuTemp =
          await ECHelper.read(_configManager.currentConfig.tempAddresses[0]);
      final gpuTemp =
          await ECHelper.read(_configManager.currentConfig.tempAddresses[1]);

      final newMinMaxTemps = [
        cpuTemp < _data.minMaxTemps[0] ? cpuTemp : _data.minMaxTemps[0],
        cpuTemp > _data.minMaxTemps[1] ? cpuTemp : _data.minMaxTemps[1],
        gpuTemp < _data.minMaxTemps[2] ? gpuTemp : _data.minMaxTemps[2],
        gpuTemp > _data.minMaxTemps[3] ? gpuTemp : _data.minMaxTemps[3],
      ];

      _data = _data.copyWith(
        currentTemps: [cpuTemp, gpuTemp],
        minMaxTemps: newMinMaxTemps,
      );
      logger.fine('Updated temperatures - CPU: $cpuTemp°C, GPU: $gpuTemp°C');
      notifyListeners();
    } catch (e) {
      logger.severe('Temperature read error: $e');
    }
  }

  Future<void> updateRPMs() async {
    try {
      final cpuRaw =
          await ECHelper.readRPM(_configManager.currentConfig.rpmAddresses[0]);
      final gpuRaw =
          await ECHelper.readRPM(_configManager.currentConfig.rpmAddresses[1]);

      final config = _configManager.currentConfig;
      final cpuRpm = cpuRaw > 0 ? config.rpmDivisor ~/ cpuRaw : 0;
      final gpuRpm = gpuRaw > 0 ? config.rpmDivisor ~/ gpuRaw : 0;

      _data = _data.copyWith(rpms: [cpuRpm, gpuRpm]);
      logger.fine('Updated RPMs - CPU: $cpuRpm, GPU: $gpuRpm');
      notifyListeners();
    } catch (e) {
      logger.severe('RPM read error: $e');
    }
  }
}
