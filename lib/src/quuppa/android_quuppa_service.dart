import 'dart:async';

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
    _eventStream ??= _mergeStreams();
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
    try {
      final state = await _service.getBluetoothState();
      return _mapBluetoothState(state);
    } catch (e) {
      if (_isAdvertising) return BlueGpsBluetoothState.poweredOn;
      return BlueGpsBluetoothState.unknown;
    }
  }

  @override
  Future<bool> isAdvertising() async => _isAdvertising;

  /// Request Android BLE advertising permissions.
  ///
  /// Returns `true` when all permissions are granted.
  static Future<bool> requestPermissions() =>
      android_quuppa.BlueGpsPermissions.requestAdvertisingPermissions();

  // ---- Private helpers ----

  /// Merges the advertising status stream and the Bluetooth state stream
  /// into a single [BlueGpsEvent] stream.
  Stream<BlueGpsEvent> _mergeStreams() {
    final controller = StreamController<BlueGpsEvent>.broadcast();

    final advSub = _service.statusStream.listen(
      (status) => controller.add(_mapStatus(status)),
      onError: (e) => controller.addError(e),
    );

    final btSub = _service.bluetoothStateStream.listen(
      (state) => controller.add(_mapBtStateEvent(state)),
      onError: (e) => controller.addError(e),
    );

    controller.onCancel = () {
      advSub.cancel();
      btSub.cancel();
    };

    return controller.stream.distinct();
  }

  BlueGpsEvent _mapBtStateEvent(android_quuppa.BluetoothState state) {
    return BlueGpsBluetoothStateChanged(
      state: _mapBluetoothState(state),
      isReady: state == android_quuppa.BluetoothState.on,
    );
  }

  BlueGpsBluetoothState _mapBluetoothState(
      android_quuppa.BluetoothState state) {
    return switch (state) {
      android_quuppa.BluetoothState.on => BlueGpsBluetoothState.poweredOn,
      android_quuppa.BluetoothState.off => BlueGpsBluetoothState.poweredOff,
    };
  }

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
        // BT state is handled by the dedicated bluetoothStateStream.
        // Stopping advertising does not mean BT is off.
        return BlueGpsStateUpdate(
          bluetoothState: BlueGpsBluetoothState.poweredOn,
          isAdvertising: false,
        );
      case android_quuppa.ServiceStatus.ERROR:
        _isAdvertising = false;
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
