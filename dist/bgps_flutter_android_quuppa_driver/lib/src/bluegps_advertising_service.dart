import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/advertising_status.dart';
import 'models/bluetooth_state.dart';

/// Dart API for controlling the BlueGPS BLE advertising service.
///
/// Uses platform channels to communicate with the native Android plugin.
///
/// ```dart
/// final service = BlueGpsAdvertisingService();
///
/// service.statusStream.listen((status) {
///   print('Advertising status: ${status.status.name}');
/// });
///
/// await service.startAdvertising(
///   AndroidAdvConfiguration(tagid: 'A0BB00000001'),
/// );
/// ```
class BlueGpsAdvertisingService {
  static const _commandChannel =
      MethodChannel('com.synapseslab.bluegps_sdk_flutter/command');
  static const _eventChannel =
      EventChannel('com.synapseslab.bluegps_sdk_flutter/event');
  static const _bluetoothStateChannel =
      EventChannel('com.synapseslab.bluegps_sdk_flutter/bluetooth_state');

  Stream<AdvertisingStatus>? _statusStream;
  Stream<BluetoothState>? _bluetoothStateStream;

  /// A broadcast stream of [AdvertisingStatus] updates from the native service.
  Stream<AdvertisingStatus> get statusStream {
    _statusStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => AdvertisingStatus.fromMap(event));
    return _statusStream!;
  }

  /// A broadcast stream of [BluetoothState] changes.
  ///
  /// Emits the current state immediately upon first listen, then streams
  /// every subsequent ON/OFF transition.
  Stream<BluetoothState> get bluetoothStateStream {
    _bluetoothStateStream ??= _bluetoothStateChannel
        .receiveBroadcastStream()
        .map((event) => BluetoothState.fromString(event as String?));
    return _bluetoothStateStream!;
  }

  /// Returns the current state of the Bluetooth adapter.
  ///
  /// Throws a [PlatformException] if the native side reports an error.
  Future<BluetoothState> getBluetoothState() async {
    final String? state =
        await _commandChannel.invokeMethod('getBluetoothState');
    return BluetoothState.fromString(state);
  }

  /// Starts BLE advertising with the given [config].
  ///
  /// Throws a [PlatformException] if the native side reports an error.
  Future<void> startAdvertising(AndroidAdvConfiguration config) async {
    final String configJson = jsonEncode(config.toMap());
    await _commandChannel
        .invokeMethod('startAdvertising', {'config': configJson});
  }

  /// Stops BLE advertising.
  ///
  /// Throws a [PlatformException] if the native side reports an error.
  Future<void> stopAdvertising() async {
    await _commandChannel.invokeMethod('stopAdvertising');
  }

  /// Releases platform channel resources.
  ///
  /// After calling this, the service instance should not be reused.
  void dispose() {
    _statusStream = null;
    _bluetoothStateStream = null;
  }
}