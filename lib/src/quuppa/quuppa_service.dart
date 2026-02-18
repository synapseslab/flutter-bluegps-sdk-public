import 'dart:io';

import 'package:bgps_flutter_ios_quuppa_driver/bgps_flutter_quuppa_ios_driver.dart'
    as quuppa;

import '../models/ble_frequency.dart';
import '../models/bluetooth_state.dart';
import '../models/sdk_event.dart';
import '../models/sdk_exception.dart';
import 'android_quuppa_service.dart';
import 'quuppa_config.dart';

/// Abstract service for Quuppa BLE advertising.
///
/// Use [QuuppaService.forPlatform] to get the platform-appropriate
/// implementation via factory method pattern.
abstract class QuuppaService {
  /// Stream of advertising and Bluetooth state events.
  Stream<BlueGpsEvent> get eventStream;

  /// Start advertising with the given configuration.
  Future<void> startAdvertising(QuuppaAdvertisingConfig config);

  /// Stop advertising.
  Future<void> stopAdvertising();

  /// Get current Bluetooth adapter state.
  Future<BlueGpsBluetoothState> getBluetoothState();

  /// Whether the device is currently advertising.
  Future<bool> isAdvertising();

  /// Factory that returns the platform-appropriate [QuuppaService].
  factory QuuppaService.forPlatform() {
    if (Platform.isIOS) return IosQuuppaService();
    if (Platform.isAndroid) return AndroidQuuppaService();
    throw UnsupportedError(
        'QuuppaService is not supported on ${Platform.operatingSystem}');
  }
}

/// iOS implementation of [QuuppaService] using `bgps_flutter_quuppa_driver`.
class IosQuuppaService implements QuuppaService {
  Stream<BlueGpsEvent>? _eventStream;

  @override
  Stream<BlueGpsEvent> get eventStream {
    _eventStream ??=
        quuppa.BgpsFlutterQuuppaDriver.eventStream.map(_mapEvent).distinct();
    return _eventStream!;
  }

  @override
  Future<void> startAdvertising(QuuppaAdvertisingConfig config) async {
    if (config is! IosQuuppaAdvertisingConfig) {
      throw QuuppaException(
          'IosQuuppaService requires IosQuuppaAdvertisingConfig');
    }
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

  @override
  Future<void> stopAdvertising() async {
    try {
      await quuppa.BgpsFlutterQuuppaDriver.stopAdvertising();
    } catch (e) {
      throw QuuppaException('Failed to stop advertising', cause: e);
    }
  }

  @override
  Future<BlueGpsBluetoothState> getBluetoothState() async {
    try {
      final stateStr = await quuppa.BgpsFlutterQuuppaDriver.getBluetoothState();
      return _mapBluetoothStateString(stateStr);
    } catch (e) {
      throw QuuppaException('Failed to get Bluetooth state', cause: e);
    }
  }

  @override
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
      quuppa.BluetoothState.unauthorized => BlueGpsBluetoothState.unauthorized,
      quuppa.BluetoothState.unsupported => BlueGpsBluetoothState.unsupported,
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
