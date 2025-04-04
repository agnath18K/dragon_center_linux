enum FanProfile {
  auto,
  basic,
  advanced,
  boost;

  String get name {
    switch (this) {
      case FanProfile.auto:
        return 'Auto';
      case FanProfile.basic:
        return 'Basic';
      case FanProfile.advanced:
        return 'Advanced';
      case FanProfile.boost:
        return 'Boost';
    }
  }

  String get description {
    switch (this) {
      case FanProfile.auto:
        return 'Automatic fan control based on temperature';
      case FanProfile.basic:
        return 'Slightly higher fan speeds for better cooling';
      case FanProfile.advanced:
        return 'Higher fan speeds for maximum cooling';
      case FanProfile.boost:
        return 'Maximum fan speeds for extreme cooling';
    }
  }
}
