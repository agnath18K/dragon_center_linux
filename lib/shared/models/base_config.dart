abstract class LaptopConfig {
  List<List<int>> get defaultAutoSpeed;

  List<List<int>> get defaultAdvancedSpeed;

  List<List<int>> get fanAddresses;

  List<int> get tempAddresses;

  List<int> get rpmAddresses;

  int get batteryThresholdAddress;

  int get batteryThresholdOffset;

  Map<int, List<int>> get cpuGenAutoAdvancedValues;

  Map<int, List<int>> get cpuGenCoolerBoosterValues;

  String get usbBacklightProfile;

  int get usbBacklightAddress;

  int get usbBacklightOff;

  int get usbBacklightHalf;

  int get usbBacklightFull;

  int get defaultProfile;

  int get defaultBatteryThreshold;

  int get defaultBasicOffset;

  int get defaultCpuGen;

  int get maxFanSpeed;

  int get maxRpm;

  int get rpmDivisor;

  int get tempWarningThreshold;

  int get tempCriticalThreshold;

  int get minBatteryThreshold;

  int get maxBatteryThreshold;

  int get batteryThresholdDivisions;

  int get minBasicOffset;

  int get maxBasicOffset;

  int get basicOffsetDivisions;

  Map<int, String> get profileNames;

  Map<int, String> get profileDescriptions;

  String get modelName;

  String get modelCode;

  List<String> get supportedCpuGenerations;
}
