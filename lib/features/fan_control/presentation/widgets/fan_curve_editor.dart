import 'package:flutter/material.dart';
import 'package:dragon_center_linux/features/fan_control/models/fan_curve.dart';
import 'package:dragon_center_linux/models/fan_config.dart';
import 'package:dragon_center_linux/features/fan_control/presentation/viewmodels/fan_control_viewmodel.dart';
import 'package:dragon_center_linux/shared/services/config_manager.dart';

class FanCurveEditor extends StatefulWidget {
  final String title;
  final FanCurve fanCurve;
  final bool isGpu;

  const FanCurveEditor({
    super.key,
    required this.title,
    required this.fanCurve,
    required this.isGpu,
  });

  @override
  State<FanCurveEditor> createState() => _FanCurveEditorState();
}

class _FanCurveEditorState extends State<FanCurveEditor> {
  late List<TextEditingController> _tempControllers;
  late List<TextEditingController> _speedControllers;

  @override
  void initState() {
    super.initState();
    _tempControllers = widget.fanCurve.temperatures
        .map((temp) => TextEditingController(text: temp.toString()))
        .toList();
    _speedControllers = widget.fanCurve.fanSpeeds
        .map((speed) => TextEditingController(text: speed.toString()))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _tempControllers) {
      controller.dispose();
    }
    for (var controller in _speedControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveFanCurve() async {
    try {
      final temperatures =
          _tempControllers.map((c) => int.tryParse(c.text) ?? 0).toList();
      final speeds =
          _speedControllers.map((c) => int.tryParse(c.text) ?? 0).toList();

      for (int i = 1; i < temperatures.length; i++) {
        if (temperatures[i] <= temperatures[i - 1]) {
          throw Exception('Temperatures must be in ascending order');
        }
      }

      final config = ConfigManager().currentConfig;
      for (var speed in speeds) {
        if (speed < 0 || speed > config.maxFanSpeed) {
          throw Exception(
              'Fan speeds must be between 0 and ${config.maxFanSpeed}');
        }
      }

      final newCurve = FanCurve(
        temperatures: temperatures,
        fanSpeeds: speeds,
      );

      if (widget.isGpu) {
        FanConfig.gpuFanCurve = newCurve;
      } else {
        FanConfig.cpuFanCurve = newCurve;
      }

      await FanConfig.saveConfig();

      final viewModel = DragonControlProvider();
      await viewModel.applyAdvancedProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fan curve saved and applied successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving fan curve: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Temperature Thresholds (°C)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                6,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _tempControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'T${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Fan Speeds (%)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                7,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _speedControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'S$index',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveFanCurve,
                child: const Text('Save Fan Curve'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
