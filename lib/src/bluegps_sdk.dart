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

  // ---- High-level flow ----

  /// Initialize the SDK: guest login, fetch device config, start advertising.
  ///
  /// Requires a [BlueGpsClient] to be configured.
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

    // 3. Start Quuppa advertising if config available
    final advertisingConfig = _resolveAdvertisingConfig(_deviceConfig);
    if (advertisingConfig != null) {
      await startAdvertising(advertisingConfig);
    }
  }

  /// Open a real-time SSE position stream.
  ///
  /// Requires [init] to have been called first.
  Stream<Map<String, List<MapPositionModel>>> positionStream(
      [SsePositionRequest? request]) {
    if (_serverClient == null) {
      throw BlueGpsSdkException('Server client not configured');
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
  Future<void> startAdvertising(QuuppaAdvertisingConfig config) =>
      _quuppaService.startAdvertising(config);

  /// Stop Quuppa beacon advertising.
  Future<void> stopAdvertising() => _quuppaService.stopAdvertising();

  /// Get the current Bluetooth adapter state.
  Future<BlueGpsBluetoothState> getBluetoothState() =>
      _quuppaService.getBluetoothState();

  /// Whether the device is currently advertising.
  Future<bool> isAdvertising() => _quuppaService.isAdvertising();

  /// Release resources.
  void dispose() {
    _serverClient?.dispose();
  }

  // ---- Private helpers ----

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
