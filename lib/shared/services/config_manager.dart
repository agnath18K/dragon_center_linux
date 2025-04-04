import 'dart:io';
import 'package:dragon_center_linux/shared/models/base_config.dart';
import 'package:dragon_center_linux/shared/models/msi_bios_config.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';

class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();
  factory ConfigManager() => _instance;
  ConfigManager._internal();

  LaptopConfig? _currentConfig;

  final Map<String, LaptopConfig> _configs = {
    'E16U8IMS': MSIBiosConfig(),
    '16U5EMS1': MSIBiosConfig(),
    '16U4EMS1': MSIBiosConfig(),
    '16U3EMS1': MSIBiosConfig(),
  };

  LaptopConfig get currentConfig {
    if (_currentConfig == null) {
      throw StateError('No configuration selected. Call detectModel() first.');
    }
    return _currentConfig!;
  }

  List<String> get supportedBiosVersions => _configs.keys.toList();

  List<String> get supportedModelNames =>
      _configs.values.map((config) => config.modelName).toList();

  Future<void> detectModel() async {
    try {
      final biosVersion = await _readBiosVersion();
      logger.info('Detected BIOS version: $biosVersion');

      if (biosVersion.isNotEmpty && _configs.containsKey(biosVersion)) {
        _currentConfig = _configs[biosVersion];
        logger.info('Found exact match for BIOS version: $biosVersion');
      } else {
        final modelCode = _extractModelCode(biosVersion);
        if (modelCode != null) {
          _currentConfig = MSIBiosConfig();
          logger.info(
              'Using default config for model: $modelCode (BIOS: $biosVersion)');
        } else {
          _currentConfig = MSIBiosConfig();
          logger.warning(
              'Model detection failed, defaulting to MSIBiosConfig. BIOS version: $biosVersion');
        }
      }
    } catch (e) {
      logger.severe('Model detection failed: $e');

      _currentConfig = MSIBiosConfig();
    }
  }

  void setBiosVersion(String biosVersion) {
    if (_configs.containsKey(biosVersion)) {
      _currentConfig = _configs[biosVersion];
      logger.info('Manually set BIOS version to: $biosVersion');
    } else {
      logger.severe('Attempted to set unsupported BIOS version: $biosVersion');
      throw ArgumentError('Unsupported BIOS version: $biosVersion');
    }
  }

  Future<String> _readBiosVersion() async {
    try {
      final file = File('/sys/class/dmi/id/bios_version');
      if (await file.exists()) {
        final info = await file.readAsString();
        logger.fine('Read BIOS version: $info');
        return info.trim();
      }
      logger.warning('BIOS version file not found');
      return '';
    } catch (e) {
      logger.severe('Failed to read BIOS version: $e');
      return '';
    }
  }

  String? _extractModelCode(String biosVersion) {
    final match = RegExp(r'([A-Z])(\d{2})([A-Z])(\d)').firstMatch(biosVersion);
    if (match != null) {
      final series = match.group(1);
      final model = match.group(2);
      final variant = match.group(3);


      if (series == 'E' && model == '16' && variant == 'U') {
        return 'GL65';
      }
    }
    logger.fine('Could not extract model code from BIOS version: $biosVersion');
    return null;
  }
}
