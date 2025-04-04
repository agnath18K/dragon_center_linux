import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dragon_center_linux/models/msi_config.dart';

class ModelSelectionDialog extends StatefulWidget {
  const ModelSelectionDialog({super.key});

  @override
  State<ModelSelectionDialog> createState() => _ModelSelectionDialogState();
}

class _ModelSelectionDialogState extends State<ModelSelectionDialog> {
  String? _selectedModel;
  final List<String> _availableModels = [
    '16U5EMS1',
    '16U4EMS1',
    '16U3EMS1',
    '16Q2EMS2',
    '16Q2EWS1',
    '16W1EMS1',
    '17A6EMS1',
    '17B1EMS1',
    '17B5EMS1',
    '17G1EMS1',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedModel();
  }

  Future<void> _loadSavedModel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedModel = prefs.getString('selected_model');
    });
  }

  Future<void> _saveModelSelection() async {
    if (_selectedModel != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_model', _selectedModel!);
      MSIConfig.setCurrentModel(_selectedModel!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Your Laptop Model'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please select your MSI laptop model to ensure proper fan control and system monitoring.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedModel,
              decoration: const InputDecoration(
                labelText: 'Laptop Model',
                border: OutlineInputBorder(),
              ),
              items: _availableModels.map((String model) {
                return DropdownMenuItem<String>(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedModel = newValue;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedModel == null
              ? null
              : () async {
                  await _saveModelSelection();
                  if (mounted && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
