import 'package:dragon_center_linux/features/fan_control/presentation/viewmodels/fan_control_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dragon_center_linux/models/fan_config.dart';
import 'package:dragon_center_linux/shared/services/config_manager.dart';
import 'package:dragon_center_linux/features/fan_control/presentation/widgets/fan_curve_editor.dart';
import 'package:dragon_center_linux/core/presentation/widgets/model_selection_dialog.dart';
import 'package:dragon_center_linux/shared/services/battery_service.dart';

class DragonControlPage extends StatefulWidget {
  const DragonControlPage({super.key});

  @override
  State<DragonControlPage> createState() => _DragonControlPageState();
}

class _DragonControlPageState extends State<DragonControlPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DragonControlProvider _provider;
  final List<String> _tabs = ['Dashboard', 'Fan Control', 'Battery'];
  final ConfigManager _configManager = ConfigManager();
  final BatteryService _batteryService = BatteryService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _provider = DragonControlProvider();
    _batteryService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _provider.dispose();
    _batteryService.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DragonControlProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: const Text('MSI Dragon Centre',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  pinned: true,
                  floating: true,
                  centerTitle: true,
                  backgroundColor: const Color(0xFF1A1A1A),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () => _showAdvancedSettings(),
                      tooltip: 'Advanced Settings',
                    ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                    labelColor: const Color(0xFFD32F2F),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFFD32F2F),
                    indicatorWeight: 3,
                    dividerHeight: 0,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildFanControlTab(),
                _buildBatteryTab(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSystemOverview(),
          const SizedBox(height: 24),
          _buildTemperatureMonitors(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Consumer<DragonControlProvider>(
      builder: (context, provider, child) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.computer, color: Color(0xFFD32F2F)),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SYSTEM OVERVIEW',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Current Fan Profile',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F).withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFD32F2F), width: 1),
                      ),
                      child: Text(
                        _getProfileName(FanConfig.profile),
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildInfoItem(Icons.thermostat, 'Max CPU',
                        '${provider.minMaxTemps[1]}°C'),
                    _buildInfoItem(
                        Icons.speed, 'CPU Fan', '${provider.rpms[0]} RPM'),
                    _buildInfoItem(Icons.battery_charging_full, 'Battery',
                        '${FanConfig.batteryThreshold}%'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getProfileName(int profile) {
    return _configManager.currentConfig.profileNames[profile] ?? 'Unknown';
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTemperatureMonitors() {
    return Consumer<DragonControlProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Text('TEMPERATURE MONITORS',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey)),
            ),
            Row(
              children: [
                Expanded(child: _buildSensorCard('CPU', 0, provider)),
                const SizedBox(width: 16),
                Expanded(child: _buildSensorCard('GPU', 1, provider)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSensorCard(
      String label, int index, DragonControlProvider provider) {
    final tempColor = _getTempColor(provider.temps[index]);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tempColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${provider.temps[index]}°C',
                    style: TextStyle(
                      color: tempColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: provider.temps[index] / 100,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(tempColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTempMetric('Min', '${provider.minMaxTemps[index * 2]}°C'),
                _buildTempMetric('Current', '${provider.temps[index]}°C'),
                _buildTempMetric(
                    'Max', '${provider.minMaxTemps[index * 2 + 1]}°C'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.speed, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${provider.rpms[index]} RPM',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempMetric(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Consumer<DragonControlProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Text('QUICK ACTIONS',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey)),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildQuickActionTile(
                      icon: Icons.rocket_launch,
                      title: 'Cooler Boost',
                      subtitle: 'Maximum cooling performance',
                      value: FanConfig.profile == 4,
                      onChanged: (value) async {
                        try {
                          await provider.setFanProfile(value ? 4 : 1);
                        } catch (e) {
                          _showError('Profile change failed: $e');
                        }
                      },
                    ),
                    const Divider(height: 32),
                    _buildQuickActionTile(
                      icon: Icons.battery_charging_full,
                      title: 'Battery Conservation',
                      subtitle:
                          'Limit charging to ${FanConfig.batteryThreshold}%',
                      value: FanConfig.batteryThreshold < 100,
                      onChanged: (value) => _showBatteryThresholdDialog(),
                    ),
                    const Divider(height: 32),
                    _buildQuickActionTile(
                      icon: Icons.lightbulb,
                      title: 'USB Backlight',
                      subtitle: 'Control USB port backlight',
                      value: false,
                      onChanged: (value) => _showUsbBacklightDialog(provider),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Consumer<DragonControlProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFFD32F2F).withAlpha(51)
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: value ? const Color(0xFFD32F2F) : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: provider.isProcessing ? null : onChanged,
            ),
          ],
        );
      },
    );
  }

  void _showBatteryThresholdDialog() {
    final provider = Provider.of<DragonControlProvider>(context, listen: false);
    final config = _configManager.currentConfig;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Battery Threshold'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Limit battery charging to extend battery lifespan'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: FanConfig.batteryThreshold.toDouble(),
                        min: config.minBatteryThreshold.toDouble(),
                        max: config.maxBatteryThreshold.toDouble(),
                        divisions: config.batteryThresholdDivisions,
                        onChanged: (value) {
                          setState(() {
                            FanConfig.batteryThreshold = value.round();
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${FanConfig.batteryThreshold}%',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: provider.isProcessing
                    ? null
                    : () async {
                        try {
                          final context = dialogContext;
                          await provider
                              .setBatteryThreshold(FanConfig.batteryThreshold);
                          if (mounted && context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          _showError('Failed to set battery threshold: $e');
                        }
                      },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUsbBacklightDialog(DragonControlProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text('USB Backlight'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: const Text('Off'),
              onTap: () async {
                try {
                  await provider.setUsbBacklight('off');
                  if (mounted && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  _showError('Failed to set USB backlight: $e');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Half'),
              onTap: () async {
                try {
                  await provider.setUsbBacklight('half');
                  if (mounted && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  _showError('Failed to set USB backlight: $e');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Full'),
              onTap: () async {
                try {
                  await provider.setUsbBacklight('full');
                  if (mounted && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  _showError('Failed to set USB backlight: $e');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildFanControlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSelector(),
          const SizedBox(height: 24),
          if (FanConfig.profile == 3) ...[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.show_chart, color: Color(0xFFD32F2F)),
                        SizedBox(width: 8),
                        Text('FAN CURVES',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FanCurveEditor(
                      title: 'CPU Fan Curve',
                      fanCurve: FanConfig.cpuFanCurve,
                      isGpu: false,
                    ),
                    const SizedBox(height: 16),
                    FanCurveEditor(
                      title: 'GPU Fan Curve',
                      fanCurve: FanConfig.gpuFanCurve,
                      isGpu: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          _buildFanCurves(),
          const SizedBox(height: 24),
          _buildCoolerBoostCard(),
        ],
      ),
    );
  }

  Widget _buildProfileSelector() {
    return Consumer<DragonControlProvider>(
      builder: (context, provider, child) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune, color: Color(0xFFD32F2F)),
                    SizedBox(width: 8),
                    Text('FAN PROFILE',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildProfileButton(
                        1, 'Auto', Icons.auto_awesome, provider),
                    _buildProfileButton(2, 'Basic', Icons.tune, provider),
                    _buildProfileButton(3, 'Advanced', Icons.code, provider),
                    _buildProfileButton(
                        4, 'Boost', Icons.rocket_launch, provider),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _getProfileDescription(FanConfig.profile),
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileButton(int profileId, String name, IconData icon,
      DragonControlProvider provider) {
    final isSelected = FanConfig.profile == profileId;

    return Expanded(
      child: GestureDetector(
        onTap: provider.isProcessing
            ? null
            : () async {
                try {
                  await provider.setFanProfile(profileId);
                } catch (e) {
                  _showError('Profile change failed: $e');
                }
              },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFD32F2F) : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProfileDescription(int profile) {
    final description =
        _configManager.currentConfig.profileDescriptions[profile] ?? '';
    if (profile == 2) {
      return '$description (${FanConfig.basicOffset > 0 ? '+' : ''}${FanConfig.basicOffset})';
    }
    return description;
  }

  Widget _buildFanCurves() {
    return Consumer<DragonControlProvider>(
      builder: (context, provider, child) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.show_chart, color: Color(0xFFD32F2F)),
                    SizedBox(width: 8),
                    Text('FAN PERFORMANCE',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFanSpeedIndicator(
                        'CPU Fan', provider.rpms[0], 0, provider),
                    _buildFanSpeedIndicator(
                        'GPU Fan', provider.rpms[1], 1, provider),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFanSpeedIndicator(
      String title, int rpm, int index, DragonControlProvider provider) {
    final config = _configManager.currentConfig;
    final percentage = (rpm / config.maxRpm).clamp(0.0, 1.0);

    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(percentage < 0.5
                      ? Colors.green
                      : percentage < 0.8
                          ? Colors.orange
                          : Colors.red),
                  strokeWidth: 10,
                ),
              ),
              Column(
                children: [
                  Text(
                    '$rpm',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('RPM', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${provider.temps[index]}°C',
            style: TextStyle(
              color: _getTempColor(provider.temps[index]),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoolerBoostCard() {
    return Consumer<DragonControlProvider>(
      builder: (context, provider, child) {
        final isActive = FanConfig.profile == 4;

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.rocket_launch, color: Color(0xFFD32F2F)),
                        SizedBox(width: 8),
                        Text('COOLER BOOST',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Switch(
                      value: isActive,
                      onChanged: provider.isProcessing
                          ? null
                          : (value) async {
                              try {
                                await provider.setFanProfile(value ? 4 : 1);
                              } catch (e) {
                                _showError('Profile change failed: $e');
                              }
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Activates maximum fan speed for intensive cooling during heavy workloads or gaming sessions. This will increase noise levels but provide optimal cooling performance.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFD32F2F)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isActive
                              ? 'Cooler Boost is active. Fan noise will be increased.'
                              : 'Enable for maximum cooling during intense operations.',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatteryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBatteryCard(),
          const SizedBox(height: 24),
          _buildBatteryTipsCard(),
        ],
      ),
    );
  }

  Widget _buildBatteryCard() {
    return Consumer<DragonControlProvider>(
      builder: (context, provider, child) {
        final config = _configManager.currentConfig;

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.battery_charging_full, color: Color(0xFFD32F2F)),
                    SizedBox(width: 8),
                    Text('BATTERY CARE',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Battery Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                '${_batteryService.batteryLevel}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _batteryService.isCharging
                                  ? const Color(0xFFD32F2F).withAlpha(51)
                                  : Colors.grey.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _batteryService.isCharging
                                    ? const Color(0xFFD32F2F)
                                    : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _batteryService.isCharging
                                      ? Icons.battery_charging_full
                                      : Icons.battery_std,
                                  size: 16,
                                  color: _batteryService.isCharging
                                      ? const Color(0xFFD32F2F)
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _batteryService.isCharging
                                      ? 'Charging'
                                      : 'Discharging',
                                  style: TextStyle(
                                    color: _batteryService.isCharging
                                        ? const Color(0xFFD32F2F)
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_batteryService.isCharging &&
                          _batteryService.timeToFull > 0)
                        _buildTimeEstimate(
                          'Time until full:',
                          _formatTime(_batteryService.timeToFull),
                        )
                      else if (!_batteryService.isCharging &&
                          _batteryService.timeToEmpty > 0)
                        _buildTimeEstimate(
                          'Time remaining:',
                          _formatTime(_batteryService.timeToEmpty),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Charging Threshold',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Extends Battery Lifespan',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Stack(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 40,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 20),
                              valueIndicatorShape:
                                  const PaddleSliderValueIndicatorShape(),
                              showValueIndicator: ShowValueIndicator.always,
                            ),
                            child: Slider(
                              value: FanConfig.batteryThreshold.toDouble(),
                              min: config.minBatteryThreshold.toDouble(),
                              max: config.maxBatteryThreshold.toDouble(),
                              divisions: config.batteryThresholdDivisions,
                              label: '${FanConfig.batteryThreshold}%',
                              onChanged: provider.isProcessing
                                  ? null
                                  : (value) async {
                                      try {
                                        await provider
                                            .setBatteryThreshold(value.round());
                                      } catch (e) {
                                        _showError(
                                            'Failed to set battery threshold: $e');
                                      }
                                    },
                            ),
                          ),
                          Positioned(
                            left: 16,
                            child: Text('50%',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12)),
                          ),
                          Positioned(
                            right: 16,
                            child: Text('100%',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F).withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFD32F2F), width: 1),
                          ),
                          child: Text(
                            'Current Threshold: ${FanConfig.batteryThreshold}%',
                            style: const TextStyle(
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Setting a charging threshold below 100% can extend your battery\'s lifespan by reducing stress on the cells.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeEstimate(String label, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400])),
        Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD32F2F),
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours h $minutes m';
    } else {
      return '$minutes minutes';
    }
  }

  Widget _buildBatteryTipsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFFD32F2F)),
                SizedBox(width: 8),
                Text('BATTERY TIPS',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              'Keep your battery between 20% and 80% for optimal lifespan',
              Icons.battery_4_bar,
            ),
            _buildTipItem(
              'Use AC power when possible during extended gaming sessions',
              Icons.power,
            ),
            _buildTipItem(
              'Lower screen brightness to reduce battery consumption',
              Icons.brightness_medium,
            ),
            _buildTipItem(
              'Use economy mode when battery life is a priority',
              Icons.eco,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(tip, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showAdvancedSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text('Advanced Settings'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Fan Curves',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              FanCurveEditor(
                title: 'CPU Fan Curve',
                fanCurve: FanConfig.cpuFanCurve,
                isGpu: false,
              ),
              const SizedBox(height: 16),
              FanCurveEditor(
                title: 'GPU Fan Curve',
                fanCurve: FanConfig.gpuFanCurve,
                isGpu: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CPU Information',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Generation:'),
                        Text(
                          FanConfig.cpuGen == 1
                              ? '10th Gen or newer'
                              : 'Older than 10th Gen',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Laptop Model',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Current Model:'),
                        Text(
                          _configManager.currentConfig.modelCode,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const ModelSelectionDialog(),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Change Model'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getTempColor(int temp) {
    final config = _configManager.currentConfig;
    if (temp < config.tempWarningThreshold) return Colors.green;
    if (temp < config.tempCriticalThreshold) return Colors.orange;
    return Colors.red;
  }
}
