import 'package:bgps_flutter_quuppa_driver/bgps_flutter_quuppa_driver.dart'
    as quuppa;

import '../models/ble_frequency.dart';
import '../models/bluetooth_state.dart';
import '../models/sdk_event.dart';
import '../models/sdk_exception.dart';
import 'quuppa_config.dart';

/// Service wrapping the Quuppa BLE advertising plugin.
///
/// All interaction with the underlying `bgps_flutter_quuppa_driver` plugin
/// goes through this class. Consumers should not import the raw plugin.
class QuuppaService {
  Stream<BlueGpsEvent>? _eventStream;

  /// Stream of advertising and Bluetooth state events.
  Stream<BlueGpsEvent> get eventStream {
    _eventStream ??= quuppa.BgpsFlutterQuuppaDriver.eventStream.map(_mapEvent);
    return _eventStream!;
  }

  /// Start advertising with the given configuration.
  ///
  /// Throws [QuuppaException] on failure.
  Future<void> startAdvertising(QuuppaAdvertisingConfig config) async {
    try {
      await quuppa.BgpsFlutterQuuppaDriver.startAdvertising(
        tagId: config.tagId,
        byte1: config.byte1,
        byte2: config.byte2,
        tOn: config.tOn,
        tOff: config.tOff,
        frequency:
            config.frequency != null ? _mapFrequency(config.frequency!) : null,
      );
    } catch (e) {
      throw QuuppaException('Failed to start advertising', cause: e);
    }
  }

  /// Stop advertising.
  Future<void> stopAdvertising() async {
    try {
      await quuppa.BgpsFlutterQuuppaDriver.stopAdvertising();
    } catch (e) {
      throw QuuppaException('Failed to stop advertising', cause: e);
    }
  }

  /// Get current Bluetooth adapter state.
  Future<BlueGpsBluetoothState> getBluetoothState() async {
    try {
      final stateStr =
          await quuppa.BgpsFlutterQuuppaDriver.getBluetoothState();
      return _mapBluetoothStateString(stateStr);
    } catch (e) {
      throw QuuppaException('Failed to get Bluetooth state', cause: e);
    }
  }

  /// Whether the device is currently advertising.
  Future<bool> isAdvertising() async {
    try {
      return await quuppa.BgpsFlutterQuuppaDriver.isAdvertising();
    } catch (e) {
      throw QuuppaException('Failed to check advertising status', cause: e);
    }
  }

  // ---- Private mapping helpers ----

  BlueGpsEvent _mapEvent(quuppa.BgpsEvent event) {
    return switch (event) {
      quuppa.StateUpdateEvent e => BlueGpsStateUpdate(
          bluetoothState: _mapBluetoothState(e.bluetoothState),
          isAdvertising: e.isAdvertising,
          error: e.error,
        ),
      quuppa.BluetoothStateChangedEvent e => BlueGpsBluetoothStateChanged(
          state: _mapBluetoothState(e.state),
          isReady: e.isReady,
        ),
      quuppa.ErrorEvent e => BlueGpsError(message: e.error),
      _ => BlueGpsError(message: 'Unknown event received'),
    };
  }

  BlueGpsBluetoothState _mapBluetoothState(quuppa.BluetoothState state) {
    return switch (state) {
      quuppa.BluetoothState.unknown => BlueGpsBluetoothState.unknown,
      quuppa.BluetoothState.poweredOn => BlueGpsBluetoothState.poweredOn,
      quuppa.BluetoothState.poweredOff => BlueGpsBluetoothState.poweredOff,
      quuppa.BluetoothState.unauthorized =>
        BlueGpsBluetoothState.unauthorized,
      quuppa.BluetoothState.unsupported =>
        BlueGpsBluetoothState.unsupported,
      quuppa.BluetoothState.resetting => BlueGpsBluetoothState.resetting,
    };
  }

  BlueGpsBluetoothState _mapBluetoothStateString(String state) {
    return switch (state) {
      'poweredOn' => BlueGpsBluetoothState.poweredOn,
      'poweredOff' => BlueGpsBluetoothState.poweredOff,
      'unauthorized' => BlueGpsBluetoothState.unauthorized,
      'unsupported' => BlueGpsBluetoothState.unsupported,
      'resetting' => BlueGpsBluetoothState.resetting,
      _ => BlueGpsBluetoothState.unknown,
    };
  }

  quuppa.BLEFrequency _mapFrequency(BlueGpsBleFrequency freq) {
    return switch (freq) {
      BlueGpsBleFrequency.low => quuppa.BLEFrequency.low,
      BlueGpsBleFrequency.middle => quuppa.BLEFrequency.middle,
      BlueGpsBleFrequency.high => quuppa.BLEFrequency.high,
      BlueGpsBleFrequency.alwaysOn => quuppa.BLEFrequency.alwaysOn,
    };
  }
}
