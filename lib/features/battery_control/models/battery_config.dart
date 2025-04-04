class BatteryConfig {
  final int threshold;

  final int minThreshold;

  final int maxThreshold;

  final int divisions;

  BatteryConfig({
    required this.threshold,
    required this.minThreshold,
    required this.maxThreshold,
    required this.divisions,
  });

  BatteryConfig copyWith({
    int? threshold,
    int? minThreshold,
    int? maxThreshold,
    int? divisions,
  }) {
    return BatteryConfig(
      threshold: threshold ?? this.threshold,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      divisions: divisions ?? this.divisions,
    );
  }

  factory BatteryConfig.initial() {
    return BatteryConfig(
      threshold: 100,
      minThreshold: 20,
      maxThreshold: 100,
      divisions: 80, // 100 - 20 = 80 divisions
    );
  }
}
