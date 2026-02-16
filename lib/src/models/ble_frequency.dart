/// BLE advertising frequency presets for Quuppa.
enum BlueGpsBleFrequency {
  /// Low frequency (tOn: 0.5s, tOff: 1.0s)
  low,

  /// Middle frequency (tOn: 1.0s, tOff: 1.0s)
  middle,

  /// High frequency (always on)
  high,

  /// Continuous advertising
  alwaysOn,
}
