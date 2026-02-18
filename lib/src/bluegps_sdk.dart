import 'dart:async';
import 'dart:io';

import 'models/bluetooth_state.dart';
import 'models/sdk_event.dart';
import 'models/sdk_exception.dart';
import 'quuppa/quuppa_config.dart';
import 'quuppa/quuppa_service.dart';
import 'server/bluegps_client.dart';
import 'server/models/device_config.dart';
import 'server/models/position.dart';
import 'server/sse/sse_models.dart';

/// Main entry point for the BlueGPS SDK.
///
/// ```dart
/// final sdk = BlueGpsSdk(
///   serverClient: BlueGpsHttpClient(config: BlueGpsServerConfig(...)),
/// );
///
/// // Initialize: login + get config + start advertising
/// await sdk.init();
///
/// // Listen to positions
/// sdk.positionStream().listen((data) {
///   print('Position: $data');
/// });
/// ```
class BlueGpsSdk {
  final QuuppaService _quuppaService;
  final BlueGpsClient? _serverClient;
  DeviceConfiguration? _deviceConfig;

  /// Last advertising config used, stored for auto-restart.
  QuuppaAdvertisingConfig? _lastAdvertisingConfig;
  StreamSubscription<BlueGpsEvent>? _eventSub;
  bool _autoRestartEnabled = true;

  BlueGpsSdk({
    QuuppaService? quuppaService,
    BlueGpsClient? serverClient,
  })  : _quuppaService = quuppaService ?? QuuppaService.forPlatform(),
        _serverClient = serverClient;

  /// The underlying Quuppa service, for advanced usage.
  QuuppaService get quuppa => _quuppaService;

  /// The server client, if configured.
  BlueGpsClient? get server => _serverClient;

  /// The device configuration obtained after [init].
  DeviceConfiguration? get deviceConfig => _deviceConfig;

  /// The last advertising config used, available for manual restart.
  QuuppaAdvertisingConfig? get lastAdvertisingConfig => _lastAdvertisingConfig;

  // ---- High-level flow ----

  /// Initialize the SDK: guest login, fetch device config, start advertising.
  ///
  /// Requires a [BlueGpsClient] to be configured.
  ///
  /// Throws [BlueGpsSdkException] if Bluetooth is not powered on (iOS only —
  /// Android Bluetooth state is reported asynchronously via [eventStream]).
  Future<void> init({
    required String appId,
    required String uuid,
  }) async {
    if (_serverClient == null) {
      throw BlueGpsSdkException('Server client not configured');
    }

    // 1. Guest login
    await _serverClient.guestLogin();

    // 2. Get device config
    _deviceConfig = await _serverClient.getDeviceConfig(
      appId: appId,
      uuid: uuid,
    );

    // 3. Resolve advertising config
    final advertisingConfig = _resolveAdvertisingConfig(_deviceConfig);
    if (advertisingConfig == null) return;

    _lastAdvertisingConfig = advertisingConfig;
    _autoRestartEnabled = true;

    // 4. Start listening for BT state changes (auto-restart)
    _startBluetoothMonitoring();

    // 5. Check Bluetooth state before starting
    final btState = await getBluetoothState();

    if (btState == BlueGpsBluetoothState.poweredOn) {
      await startAdvertising(advertisingConfig);
    } else if (btState != BlueGpsBluetoothState.unknown) {
      // iOS: BT is off — throw so the caller knows, but config is stored
      // and auto-restart will kick in when BT is re-enabled.
      throw BlueGpsSdkException(
        'Bluetooth is not powered on (state: $btState). '
        'Advertising will start automatically when Bluetooth is enabled.',
      );
    } else {
      // Android: state is unknown at init time — try starting anyway.
      // The native plugin will report errors via eventStream.
      await startAdvertising(advertisingConfig);
    }
  }

  /// Open a real-time SSE position stream.
  ///
  /// Requires [init] to have been called first.
  /// Throws [BlueGpsSdkException] if Bluetooth is off or advertising is not active.
  Future<Stream<Map<String, List<MapPositionModel>>>> positionStream(
      [SsePositionRequest? request]) async {
    if (_serverClient == null) {
      throw BlueGpsSdkException('Server client not configured');
    }
    final btState = await getBluetoothState();
    if (btState == BlueGpsBluetoothState.poweredOff) {
      throw BlueGpsSdkException('Bluetooth is off. Cannot start SSE stream.');
    }
    if (!await isAdvertising()) {
      throw BlueGpsSdkException(
          'Advertising is not active. Cannot start SSE stream.');
    }
    return _serverClient.positionStream(request ?? const SsePositionRequest());
  }

  /// Close the current SSE position stream connection.
  void stopPositionStream() {
    _serverClient?.stopPositionStream();
  }

  // ---- Quuppa convenience methods ----

  /// Stream of Bluetooth and advertising state events.
  Stream<BlueGpsEvent> get eventStream => _quuppaService.eventStream;

  /// Start Quuppa beacon advertising.
  ///
  /// Throws [BlueGpsSdkException] if Bluetooth is not powered on.
  Future<void> startAdvertising(QuuppaAdvertisingConfig config) async {
    final btState = await getBluetoothState();
    if (btState == BlueGpsBluetoothState.poweredOff) {
      throw BlueGpsSdkException('Bluetooth is off. Cannot start advertising.');
    }
    _lastAdvertisingConfig = config;
    _autoRestartEnabled = true;
    await _quuppaService.startAdvertising(config);
  }

  /// Stop Quuppa beacon advertising.
  ///
  /// Also disables auto-restart. Call [startAdvertising] to re-enable.
  Future<void> stopAdvertising() async {
    _autoRestartEnabled = false;
    await _quuppaService.stopAdvertising();
  }

  /// Get the current Bluetooth adapter state.
  Future<BlueGpsBluetoothState> getBluetoothState() =>
      _quuppaService.getBluetoothState();

  /// Whether the device is currently advertising.
  Future<bool> isAdvertising() => _quuppaService.isAdvertising();

  /// Release resources.
  void dispose() {
    _eventSub?.cancel();
    _eventSub = null;
    _serverClient?.dispose();
  }

  // ---- Private helpers ----

  void _startBluetoothMonitoring() {
    _eventSub?.cancel();
    _eventSub = _quuppaService.eventStream.listen(_onEvent);
  }

  void _onEvent(BlueGpsEvent event) {
    final shouldRestart = _autoRestartEnabled && _lastAdvertisingConfig != null;

    switch (event) {
      case BlueGpsStateUpdate e:
        if (shouldRestart &&
            e.bluetoothState == BlueGpsBluetoothState.poweredOn &&
            !e.isAdvertising) {
          _quuppaService.startAdvertising(_lastAdvertisingConfig!);
        }
      case BlueGpsBluetoothStateChanged e:
        if (shouldRestart && e.state == BlueGpsBluetoothState.poweredOn) {
          _quuppaService.startAdvertising(_lastAdvertisingConfig!);
        }
      case BlueGpsError():
        break;
    }
  }

  QuuppaAdvertisingConfig? _resolveAdvertisingConfig(
      DeviceConfiguration? config) {
    if (config == null) return null;
    if (Platform.isAndroid) {
      final androidConf = config.androidAdvConf;
      if (androidConf != null) {
        return AndroidQuuppaAdvertisingConfig.fromServerConf(androidConf);
      }
    } else {
      final iosConf = config.iOSAdvConf;
      if (iosConf != null) {
        return IosQuuppaAdvertisingConfig.fromServerConf(iosConf);
      }
    }
    return null;
  }
}
