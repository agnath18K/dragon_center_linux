import 'package:dbus/dbus.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';
import 'dart:io';
import 'dart:async';

class BatteryService {
  static final BatteryService _instance = BatteryService._internal();
  factory BatteryService() => _instance;
  BatteryService._internal();

  DBusClient? _client;
  DBusRemoteObject? _batteryObject;
  bool _isInitialized = false;
  bool _usingFallback = false;
  Timer? _updateTimer;

  int _batteryLevel = 0;
  bool _isCharging = false;
  int _timeToFull = 0;
  int _timeToEmpty = 0;

  int get batteryLevel => _batteryLevel;
  bool get isCharging => _isCharging;
  int get timeToFull => _timeToFull;
  int get timeToEmpty => _timeToEmpty;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeDBus();

      if (!_isInitialized) {
        await _initializeFallback();
      }
    } catch (e, stackTrace) {
      logger.severe('Failed to initialize battery service: $e\n$stackTrace');
      if (!_isInitialized) {
        await _initializeFallback();
      }
    }
  }

  Future<void> _initializeDBus() async {
    try {
      _client = DBusClient.system();

      _batteryObject = DBusRemoteObject(
        _client!,
        name: 'org.freedesktop.UPower',
        path: DBusObjectPath('/org/freedesktop/UPower/devices/battery_BAT1'),
      );

      await _updateBatteryStatus();

      _batteryObject!.propertiesChanged.listen((event) {
        logger.info('Battery properties changed: $event');
        _updateBatteryStatus();
      });

      _isInitialized = true;
      _usingFallback = false;
      logger.info('Battery service initialized successfully using D-Bus');
    } catch (e, stackTrace) {
      logger.severe(
          'Failed to initialize D-Bus battery service: $e\n$stackTrace');
    }
  }

  Future<void> _initializeFallback() async {
    try {
      final capacityFile = File('/sys/class/power_supply/BAT1/capacity');
      final statusFile = File('/sys/class/power_supply/BAT1/status');

      if (!await capacityFile.exists() || !await statusFile.exists()) {
        throw Exception('Battery files not found');
      }

      await _updateBatteryStatusFallback();

      _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _updateBatteryStatusFallback();
      });

      _isInitialized = true;
      _usingFallback = true;
      logger.info(
          'Battery service initialized successfully using fallback method');
    } catch (e, stackTrace) {
      logger.severe(
          'Failed to initialize fallback battery service: $e\n$stackTrace');
      _isInitialized = true;
    }
  }

  Future<void> _updateBatteryStatus() async {
    try {
      if (_batteryObject == null) return;

      final properties = await _batteryObject!.getAllProperties(
        'org.freedesktop.UPower.Device',
      );

      logger.info('Raw battery properties: $properties');

      if (properties.containsKey('Percentage')) {
        final percentage = properties['Percentage'];
        logger.info(
            'Percentage type: ${percentage.runtimeType}, value: $percentage');
        _batteryLevel = (percentage as DBusDouble).value.round();
      } else {
        logger.warning('Percentage property not found in battery properties');
      }

      if (properties.containsKey('State')) {
        final state = properties['State'];
        logger.info('State type: ${state.runtimeType}, value: $state');
        _isCharging = (state as DBusUint32).value == 1;
      } else {
        logger.warning('State property not found in battery properties');
      }

      if (properties.containsKey('TimeToFull')) {
        final timeToFull = properties['TimeToFull'];
        logger.info(
            'TimeToFull type: ${timeToFull.runtimeType}, value: $timeToFull');
        _timeToFull = (timeToFull as DBusInt64).value;
      } else {
        logger.warning('TimeToFull property not found in battery properties');
      }

      if (properties.containsKey('TimeToEmpty')) {
        final timeToEmpty = properties['TimeToEmpty'];
        logger.info(
            'TimeToEmpty type: ${timeToEmpty.runtimeType}, value: $timeToEmpty');
        _timeToEmpty = (timeToEmpty as DBusInt64).value;
      } else {
        logger.warning('TimeToEmpty property not found in battery properties');
      }

      logger.info(
          'Battery status updated: $_batteryLevel%, charging: $_isCharging, timeToFull: $_timeToFull, timeToEmpty: $_timeToEmpty');
    } catch (e, stackTrace) {
      logger.severe('Failed to update battery status: $e\n$stackTrace');
    }
  }

  Future<void> _updateBatteryStatusFallback() async {
    try {
      final capacityFile = File('/sys/class/power_supply/BAT1/capacity');
      if (await capacityFile.exists()) {
        final capacity = await capacityFile.readAsString();
        _batteryLevel = int.tryParse(capacity.trim()) ?? 0;
      }

      final statusFile = File('/sys/class/power_supply/BAT1/status');
      if (await statusFile.exists()) {
        final status = await statusFile.readAsString();
        _isCharging = status.trim().toLowerCase() == 'charging';
      }

      final powerNowFile = File('/sys/class/power_supply/BAT1/power_now');
      final energyNowFile = File('/sys/class/power_supply/BAT1/energy_now');
      final energyFullFile = File('/sys/class/power_supply/BAT1/energy_full');

      if (await powerNowFile.exists() &&
          await energyNowFile.exists() &&
          await energyFullFile.exists()) {
        final powerNow = int.tryParse(await powerNowFile.readAsString()) ?? 0;
        final energyNow = int.tryParse(await energyNowFile.readAsString()) ?? 0;
        final energyFull =
            int.tryParse(await energyFullFile.readAsString()) ?? 0;

        if (powerNow > 0) {
          if (_isCharging) {
            _timeToFull = ((energyFull - energyNow) / powerNow).round();
          } else {
            _timeToEmpty = (energyNow / powerNow).round();
          }
        }
      }

      logger.info(
          'Battery status updated (fallback): $_batteryLevel%, charging: $_isCharging');
    } catch (e, stackTrace) {
      logger.severe(
          'Failed to update battery status (fallback): $e\n$stackTrace');
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        if (!_usingFallback) {
          await _client?.close();
          _client = null;
          _batteryObject = null;
        } else {
          _updateTimer?.cancel();
          _updateTimer = null;
        }
      } catch (e) {
        logger.warning('Failed to dispose battery service: $e');
      }
      _isInitialized = false;
    }
  }
}
