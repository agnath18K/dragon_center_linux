class FanCurve {
  final List<int> temperatures;

  final List<int> fanSpeeds;

  FanCurve({
    required this.temperatures,
    required this.fanSpeeds,
  }) {
    if (temperatures.length != 6 || fanSpeeds.length != 7) {
      throw ArgumentError(
          'Invalid fan curve data: temperatures must be 6 and fan speeds must be 7');
    }
  }

  FanCurve copyWith({
    List<int>? temperatures,
    List<int>? fanSpeeds,
  }) {
    return FanCurve(
      temperatures: temperatures ?? this.temperatures,
      fanSpeeds: fanSpeeds ?? this.fanSpeeds,
    );
  }

  factory FanCurve.defaults() {
    return FanCurve(
      temperatures: [50, 56, 62, 70, 75, 80], // Default temperature thresholds
      fanSpeeds: [0, 40, 48, 56, 66, 76, 86], // Default fan speeds
    );
  }

  factory FanCurve.gpuDefaults() {
    return FanCurve(
      temperatures: [
        55,
        60,
        65,
        70,
        75,
        80
      ], // Default GPU temperature thresholds
      fanSpeeds: [0, 45, 54, 62, 70, 78, 78], // Default GPU fan speeds
    );
  }

  String toStorageString() {
    return '${temperatures.join(',')};${fanSpeeds.join(',')}';
  }

  factory FanCurve.fromStorageString(String? value) {
    if (value == null) return FanCurve.defaults();
    try {
      final parts = value.split(';');
      if (parts.length != 2) return FanCurve.defaults();

      final temps =
          parts[0].split(',').map((s) => int.tryParse(s) ?? 50).toList();
      final speeds =
          parts[1].split(',').map((s) => int.tryParse(s) ?? 0).toList();

      if (temps.length != 6 || speeds.length != 7) return FanCurve.defaults();

      return FanCurve(temperatures: temps, fanSpeeds: speeds);
    } catch (e) {
      return FanCurve.defaults();
    }
  }
}
