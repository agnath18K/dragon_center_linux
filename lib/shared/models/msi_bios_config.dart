import 'package:dragon_center_linux/shared/models/base_config.dart';

class MSIBiosConfig implements LaptopConfig {
  @override
  List<List<int>> get defaultAutoSpeed => [
        [0, 40, 48, 56, 66, 76, 86],
        [0, 45, 54, 62, 70, 78, 78]
      ];

  @override
  List<List<int>> get defaultAdvancedSpeed => [
        [0, 40, 48, 56, 66, 76, 86],
        [0, 45, 54, 62, 70, 78, 78]
      ];

  @override
  List<List<int>> get fanAddresses => [
        [0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78],
        [0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0x90]
      ];

  @override
  List<int> get tempAddresses => [0x68, 0x80];

  @override
  List<int> get rpmAddresses => [0xc8, 0xca];

  @override
  int get batteryThresholdAddress => 0xef;

  @override
  int get batteryThresholdOffset => 0xef;

  @override
  Map<int, List<int>> get cpuGenAutoAdvancedValues => {
        0: [0xf4, 12, 140],
        1: [0xf4, 12, 140],
        2: [0xf4, 12, 140]
      };

  @override
  Map<int, List<int>> get cpuGenCoolerBoosterValues => {
        0: [0x98, 0, 128],
        1: [0x98, 0, 128],
        2: [0x98, 0, 128]
      };

  @override
  String get usbBacklightProfile => 'USB_BACKLIGHT';

  @override
  int get usbBacklightAddress => 0xf7;

  @override
  int get usbBacklightOff => 128;

  @override
  int get usbBacklightHalf => 193;

  @override
  int get usbBacklightFull => 129;

  @override
  int get defaultProfile => 1;

  @override
  int get defaultBatteryThreshold => 100;

  @override
  int get defaultBasicOffset => 0;

  @override
  int get defaultCpuGen => 1;

  @override
  int get maxFanSpeed => 100;

  @override
  int get maxRpm => 5000;

  @override
  int get rpmDivisor => 478000;

  @override
  int get tempWarningThreshold => 60;

  @override
  int get tempCriticalThreshold => 80;

  @override
  int get minBatteryThreshold => 20;

  @override
  int get maxBatteryThreshold => 100;

  @override
  int get batteryThresholdDivisions => 80;

  @override
  int get minBasicOffset => -30;

  @override
  int get maxBasicOffset => 30;

  @override
  int get basicOffsetDivisions => 60;

  @override
  Map<int, String> get profileNames =>
      {1: 'Auto', 2: 'Basic', 3: 'Advanced', 4: 'Cooler Boost'};

  @override
  Map<int, String> get profileDescriptions => {
        1: 'Automatic fan control based on temperature',
        2: 'Basic fan control with offset adjustment',
        3: 'Advanced fan control with custom curves',
        4: 'Maximum cooling performance'
      };

  @override
  String get modelName => 'MSI 16U5EMS1';

  @override
  String get modelCode => '16U5EMS1';

  @override
  List<String> get supportedCpuGenerations => ['10th Gen Intel'];
}
