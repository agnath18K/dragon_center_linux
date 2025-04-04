import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';

class MSIConfig {
  static Map<String, dynamic> _config = {};
  static String _currentModel = '16U5EMS1';

  static Future<void> loadConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config/config.json');
      _config = json.decode(jsonString);
    } catch (e) {
      logger.severe('Error loading MSI config: $e');
    }
  }

  static void setCurrentModel(String model) {
    _currentModel = model;
  }

  static Map<String, dynamic> get currentModelConfig {
    return _config[_currentModel] ?? {};
  }

  static Map<String, dynamic> get addressProfile {
    final profileName = currentModelConfig['address_profile'] as String;
    return _config[profileName] ?? {};
  }

  static int get fanMode => currentModelConfig['fan_mode'] ?? 140;
  static int get batteryChargingThreshold =>
      currentModelConfig['battery_charging_threshold'] ?? 100;

  static List<int> get cpuTemperatures => [
        currentModelConfig['cpu_temp_0'] ?? 50,
        currentModelConfig['cpu_temp_1'] ?? 56,
        currentModelConfig['cpu_temp_2'] ?? 62,
        currentModelConfig['cpu_temp_3'] ?? 70,
        currentModelConfig['cpu_temp_4'] ?? 75,
        currentModelConfig['cpu_temp_5'] ?? 80,
      ];

  static List<int> get cpuFanSpeeds => [
        currentModelConfig['cpu_fan_speed_0'] ?? 0,
        currentModelConfig['cpu_fan_speed_1'] ?? 40,
        currentModelConfig['cpu_fan_speed_2'] ?? 48,
        currentModelConfig['cpu_fan_speed_3'] ?? 56,
        currentModelConfig['cpu_fan_speed_4'] ?? 66,
        currentModelConfig['cpu_fan_speed_5'] ?? 76,
        currentModelConfig['cpu_fan_speed_6'] ?? 86,
      ];

  static List<int> get gpuTemperatures => [
        currentModelConfig['gpu_temp_0'] ?? 55,
        currentModelConfig['gpu_temp_1'] ?? 60,
        currentModelConfig['gpu_temp_2'] ?? 65,
        currentModelConfig['gpu_temp_3'] ?? 70,
        currentModelConfig['gpu_temp_4'] ?? 75,
        currentModelConfig['gpu_temp_5'] ?? 80,
      ];

  static List<int> get gpuFanSpeeds => [
        currentModelConfig['gpu_fan_speed_0'] ?? 0,
        currentModelConfig['gpu_fan_speed_1'] ?? 45,
        currentModelConfig['gpu_fan_speed_2'] ?? 54,
        currentModelConfig['gpu_fan_speed_3'] ?? 62,
        currentModelConfig['gpu_fan_speed_4'] ?? 70,
        currentModelConfig['gpu_fan_speed_5'] ?? 78,
        currentModelConfig['gpu_fan_speed_6'] ?? 78,
      ];

  static int get fanModeAddress =>
      int.parse(addressProfile['fan_mode_address'] ?? '0xf4');
  static int get coolerBoostAddress =>
      int.parse(addressProfile['cooler_boost_address'] ?? '0x98');
  static int get usbBacklightAddress =>
      int.parse(addressProfile['usb_backlight_address'] ?? '0xf7');
  static int get batteryChargingThresholdAddress =>
      int.parse(addressProfile['battery_charging_threshold_address'] ?? '0xef');

  static List<int> get cpuTempAddresses => [
        int.parse(addressProfile['cpu_temp_address_0'] ?? '0x6a'),
        int.parse(addressProfile['cpu_temp_address_1'] ?? '0x6b'),
        int.parse(addressProfile['cpu_temp_address_2'] ?? '0x6c'),
        int.parse(addressProfile['cpu_temp_address_3'] ?? '0x6d'),
        int.parse(addressProfile['cpu_temp_address_4'] ?? '0x6e'),
        int.parse(addressProfile['cpu_temp_address_5'] ?? '0x6f'),
      ];

  static List<int> get cpuFanSpeedAddresses => [
        int.parse(addressProfile['cpu_fan_speed_address_0'] ?? '0x72'),
        int.parse(addressProfile['cpu_fan_speed_address_1'] ?? '0x73'),
        int.parse(addressProfile['cpu_fan_speed_address_2'] ?? '0x74'),
        int.parse(addressProfile['cpu_fan_speed_address_3'] ?? '0x75'),
        int.parse(addressProfile['cpu_fan_speed_address_4'] ?? '0x76'),
        int.parse(addressProfile['cpu_fan_speed_address_5'] ?? '0x77'),
        int.parse(addressProfile['cpu_fan_speed_address_6'] ?? '0x78'),
      ];

  static List<int> get gpuTempAddresses => [
        int.parse(addressProfile['gpu_temp_address_0'] ?? '0x82'),
        int.parse(addressProfile['gpu_temp_address_1'] ?? '0x83'),
        int.parse(addressProfile['gpu_temp_address_2'] ?? '0x84'),
        int.parse(addressProfile['gpu_temp_address_3'] ?? '0x85'),
        int.parse(addressProfile['gpu_temp_address_4'] ?? '0x86'),
        int.parse(addressProfile['gpu_temp_address_5'] ?? '0x87'),
      ];

  static List<int> get gpuFanSpeedAddresses => [
        int.parse(addressProfile['gpu_fan_speed_address_0'] ?? '0x8a'),
        int.parse(addressProfile['gpu_fan_speed_address_1'] ?? '0x8b'),
        int.parse(addressProfile['gpu_fan_speed_address_2'] ?? '0x8c'),
        int.parse(addressProfile['gpu_fan_speed_address_3'] ?? '0x8d'),
        int.parse(addressProfile['gpu_fan_speed_address_4'] ?? '0x8e'),
        int.parse(addressProfile['gpu_fan_speed_address_5'] ?? '0x8f'),
        int.parse(addressProfile['gpu_fan_speed_address_6'] ?? '0x90'),
      ];

  static int get realtimeCpuTempAddress =>
      int.parse(addressProfile['realtime_cpu_temp_address'] ?? '0x68');
  static int get realtimeCpuFanSpeedAddress =>
      int.parse(addressProfile['realtime_cpu_fan_speed_address'] ?? '0x71');
  static int get realtimeCpuFanRpmAddress =>
      int.parse(addressProfile['realtime_cpu_fan_rpm_address'] ?? '0xcc');
  static int get realtimeGpuTempAddress =>
      int.parse(addressProfile['realtime_gpu_temp_address'] ?? '0x80');
  static int get realtimeGpuFanSpeedAddress =>
      int.parse(addressProfile['realtime_gpu_fan_speed_address'] ?? '0x89');
  static int get realtimeGpuFanRpmAddress =>
      int.parse(addressProfile['realtime_gpu_fan_rpm_address'] ?? '0xca');

  static Map<String, dynamic> get coolerBoostConfig =>
      _config['COOLER_BOOST'] ?? {};
  static int get coolerBoostOff => coolerBoostConfig['cooler_boost_off'] ?? 0;
  static int get coolerBoostOn => coolerBoostConfig['cooler_boost_on'] ?? 128;

  static Map<String, dynamic> get usbBacklightConfig =>
      _config['USB_BACKLIGHT'] ?? {};
  static int get usbBacklightOff =>
      usbBacklightConfig['usb_backlight_off'] ?? 128;
  static int get usbBacklightHalf =>
      usbBacklightConfig['usb_backlight_half'] ?? 193;
  static int get usbBacklightFull =>
      usbBacklightConfig['usb_backlight_full'] ?? 129;
}
