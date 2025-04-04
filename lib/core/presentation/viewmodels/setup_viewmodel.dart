import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dragon_center_linux/core/services/setup_service.dart';
import 'package:dragon_center_linux/core/utils/logger.dart';
import 'package:dragon_center_linux/models/fan_config.dart';

enum SetupState { initial, loading, ready, error }

class SetupViewModel extends ChangeNotifier {
  final SetupService _setupService = SetupService();
  SetupState _state = SetupState.initial;
  String? _errorMessage;

  SetupState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _state == SetupState.ready;

  Future<void> initialize() async {
    try {
      _state = SetupState.loading;
      notifyListeners();

      await FanConfig.loadConfig();

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('firstRun') ?? true) {
        await _setupService.runSetupWizard(prefs);
      }

      _state = SetupState.ready;
      _errorMessage = null;
      logger.info('Setup initialization completed successfully');
    } catch (e) {
      _state = SetupState.error;
      _errorMessage = e.toString();
      logger.severe('Setup initialization failed: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> handleProfileSelection(bool universal) async {
    try {
      _state = SetupState.loading;
      notifyListeners();

      await _setupService.handleProfileSelection(universal);

      _state = SetupState.ready;
      _errorMessage = null;
      logger.info('Profile selection completed successfully');
    } catch (e) {
      _state = SetupState.error;
      _errorMessage = e.toString();
      logger.severe('Profile selection failed: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> handleCpuGeneration(bool isNewGen) async {
    try {
      _state = SetupState.loading;
      notifyListeners();

      await _setupService.handleCpuGeneration(isNewGen);

      _state = SetupState.ready;
      _errorMessage = null;
      logger.info('CPU generation selection completed successfully');
    } catch (e) {
      _state = SetupState.error;
      _errorMessage = e.toString();
      logger.severe('CPU generation selection failed: $e');
    } finally {
      notifyListeners();
    }
  }

  void resetError() {
    _errorMessage = null;
    logger.info('Error state reset');
    notifyListeners();
  }
}
