import 'package:bgps_flutter_android_quuppa_driver/bgps_flutter_android_quuppa_driver.dart'
    as android_quuppa;
import 'package:flutter/services.dart';

import '../models/bluetooth_state.dart';
import '../models/sdk_event.dart';
import '../models/sdk_exception.dart';
import 'quuppa_config.dart';
import 'quuppa_service.dart';

/// Android implementation of [QuuppaService] using `bgps_flutter_android_quuppa_driver`.
class AndroidQuuppaService implements QuuppaService {
  static const _commandChannel =
      MethodChannel('com.synapseslab.bluegps_sdk_flutter/command');

  final android_quuppa.BlueGpsAdvertisingService _service =
      android_quuppa.BlueGpsAdvertisingService();

  Stream<BlueGpsEvent>? _eventStream;
  bool _isAdvertising = false;
  bool _userStopped = false;

  @override
  Stream<BlueGpsEvent> get eventStream {
    _eventStream ??= _service.statusStream.map(_mapStatus);
    return _eventStream!;
  }

  @override
  Future<void> startAdvertising(QuuppaAdvertisingConfig config) async {
    bool permissionsGranted = await requestPermissions();

    if (!permissionsGranted) {
      throw QuuppaException('Bluetooth permission not granted');
    }

    if (config is! AndroidQuuppaAdvertisingConfig) {
      throw QuuppaException(
          'AndroidQuuppaService requires AndroidQuuppaAdvertisingConfig');
    }
    try {
      final nativeConfig = android_quuppa.AndroidAdvConfiguration(
        tagid: config.tagId,
        advModes: config.advModes?.toJson(),
        advTxPowers: config.advTxPowers?.toJson(),
      );
      await _service.startAdvertising(nativeConfig);
      _isAdvertising = true;
      _userStopped = false;
    } catch (e) {
      throw QuuppaException('Failed to start advertising', cause: e);
    }
  }

  @override
  Future<void> stopAdvertising() async {
    try {
      _userStopped = true;
      await _service.stopAdvertising();
      _isAdvertising = false;
    } catch (e) {
      throw QuuppaException('Failed to stop advertising', cause: e);
    }
  }

  @override
  Future<BlueGpsBluetoothState> getBluetoothState() async {
    try {
      final enabled =
          await _commandChannel.invokeMethod<bool>('isBluetoothEnabled');
      if (enabled == true) return BlueGpsBluetoothState.poweredOn;
      if (enabled == false) return BlueGpsBluetoothState.poweredOff;
    } on MissingPluginException {
      // Plugin does not implement isBluetoothEnabled yet — fall back.
    } on PlatformException {
      // Native error — fall back.
    }
    if (_isAdvertising) return BlueGpsBluetoothState.poweredOn;
    return BlueGpsBluetoothState.unknown;
  }

  @override
  Future<bool> isAdvertising() async => _isAdvertising;

  /// Request Android BLE advertising permissions.
  ///
  /// Returns `true` when all permissions are granted.
  static Future<bool> requestPermissions() =>
      android_quuppa.BlueGpsPermissions.requestAdvertisingPermissions();

  // ---- Private mapping helpers ----

  BlueGpsEvent _mapStatus(android_quuppa.AdvertisingStatus status) {
    switch (status.status) {
      case android_quuppa.ServiceStatus.STARTED:
        _isAdvertising = true;
        return BlueGpsStateUpdate(
          bluetoothState: BlueGpsBluetoothState.poweredOn,
          isAdvertising: true,
        );
      case android_quuppa.ServiceStatus.STOPPED:
        _isAdvertising = false;
        // User-initiated stop: BT is still on.
        // External stop (BT turned off): report poweredOff.
        final btState = _userStopped
            ? BlueGpsBluetoothState.poweredOn
            : BlueGpsBluetoothState.poweredOff;
        _userStopped = false;
        return BlueGpsStateUpdate(
          bluetoothState: btState,
          isAdvertising: false,
        );
      case android_quuppa.ServiceStatus.ERROR:
        _isAdvertising = false;
        // Native BroadcastReceiver sends ERROR when BT is turned off.
        if (status.message.contains('Bluetooth')) {
          return BlueGpsStateUpdate(
            bluetoothState: BlueGpsBluetoothState.poweredOff,
            isAdvertising: false,
            error: status.message,
          );
        }
        return BlueGpsError(message: status.message);
      case android_quuppa.ServiceStatus.UNKNOWN:
        return BlueGpsStateUpdate(
          bluetoothState: BlueGpsBluetoothState.unknown,
          isAdvertising: _isAdvertising,
        );
    }
  }
}
