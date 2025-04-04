import 'package:logging/logging.dart';

class AppConfig {
  static const int temperatureUpdateInterval = 5000;
  static const int fanSpeedUpdateInterval = 5000;
  static const int rpmUpdateInterval = 5000;

  static const int ecTimeout = 5000;
  static const int ecPollInterval = 1;

  static const Map<String, Level> loggingLevels = {
    'EC': Level.ALL,
    'Fan': Level.INFO,
    'Temp': Level.INFO,
    'Config': Level.INFO,
    'UI': Level.WARNING,
  };

  static const String ecPath = '/dev/ec0';
  static const int ecSize = 256;
  static const int ecBase = 0x62;
  static const int ecData = 0x66;
  static const int ecCommand = 0x66;
  static const int ecStatus = 0x66;

  static const Map<String, int> fanRegisters = {
    'CPU': 0x00,
    'GPU': 0x01,
    'SYS': 0x02,
  };

  static const Map<String, int> temperatureRegisters = {
    'CPU': 0x10,
    'GPU': 0x11,
    'SYS': 0x12,
  };

  static const int minFanSpeed = 0;
  static const int maxFanSpeed = 100;
  static const int defaultFanSpeed = 50;

  static const int criticalTemperature = 90;
  static const int warningTemperature = 80;
  static const int normalTemperature = 70;
}
