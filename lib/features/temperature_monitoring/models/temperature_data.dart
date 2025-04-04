class TemperatureData {
  final List<int> currentTemps;

  final List<int> minMaxTemps;

  final List<int> rpms;

  TemperatureData({
    required this.currentTemps,
    required this.minMaxTemps,
    required this.rpms,
  });

  TemperatureData copyWith({
    List<int>? currentTemps,
    List<int>? minMaxTemps,
    List<int>? rpms,
  }) {
    return TemperatureData(
      currentTemps: currentTemps ?? this.currentTemps,
      minMaxTemps: minMaxTemps ?? this.minMaxTemps,
      rpms: rpms ?? this.rpms,
    );
  }

  factory TemperatureData.initial() {
    return TemperatureData(
      currentTemps: [0, 0],
      minMaxTemps: [100, 0, 100, 0],
      rpms: [0, 0],
    );
  }
}
