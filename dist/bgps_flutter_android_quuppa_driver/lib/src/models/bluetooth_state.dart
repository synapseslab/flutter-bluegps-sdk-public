/// The current state of the device's Bluetooth adapter.
enum BluetoothState {
  /// Bluetooth is enabled and ready.
  on,

  /// Bluetooth is disabled.
  off;

  /// Parses a [value] string (`"ON"` / `"OFF"`) into a [BluetoothState].
  static BluetoothState fromString(String? value) {
    return value == 'ON' ? BluetoothState.on : BluetoothState.off;
  }
}