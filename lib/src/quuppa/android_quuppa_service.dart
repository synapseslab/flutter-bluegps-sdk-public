import 'package:bgps_flutter_android_quuppa_driver/bgps_flutter_android_quuppa_driver.dart'
    as android_quuppa;

import '../models/bluetooth_state.dart';
import '../models/sdk_event.dart';
import '../models/sdk_exception.dart';
import 'quuppa_config.dart';
import 'quuppa_service.dart';

/// Android implementation of [QuuppaService] using `bgps_flutter_android_quuppa_driver`.
class AndroidQuuppaService implements QuuppaService {
  final android_quuppa.BlueGpsAdvertisingService _service =
      android_quuppa.BlueGpsAdvertisingService();

  Stream<BlueGpsEvent>? _eventStream;
  bool _isAdvertising = false;

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
    } catch (e) {
      throw QuuppaException('Failed to start advertising', cause: e);
    }
  }

  @override
  Future<void> stopAdvertising() async {
    try {
      await _service.stopAdvertising();
      _isAdvertising = false;
    } catch (e) {
      throw QuuppaException('Failed to stop advertising', cause: e);
    }
  }

  @override
  Future<BlueGpsBluetoothState> getBluetoothState() async {
    // Android plugin does not expose Bluetooth state directly.
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
        return BlueGpsStateUpdate(
          bluetoothState: BlueGpsBluetoothState.poweredOn,
          isAdvertising: false,
        );
      case android_quuppa.ServiceStatus.ERROR:
        _isAdvertising = false;
        return BlueGpsError(message: status.message);
      case android_quuppa.ServiceStatus.UNKNOWN:
        return BlueGpsStateUpdate(
          bluetoothState: BlueGpsBluetoothState.unknown,
          isAdvertising: _isAdvertising,
        );
    }
  }
}
