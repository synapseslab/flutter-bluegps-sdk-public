import 'auth/auth_models.dart';
import 'config/server_config.dart';
import 'models/device_config.dart';
import 'models/position.dart';
import 'sse/sse_models.dart';

/// Abstract client for communicating with the BlueGPS server.
abstract class BlueGpsClient {
  /// The server configuration.
  BlueGpsServerConfig get config;

  /// The current auth token, or null if not authenticated.
  BlueGpsAuthToken? get currentToken;

  /// Perform guest login via OAuth2 client_credentials.
  Future<BlueGpsAuthToken> guestLogin();

  /// Retrieve the iOS device configuration from the server.
  /// The [appId] and [uuid] parameters are sent to the server for device identification.
  Future<DeviceConfiguration> getDeviceConfig(
      {required String appId, required String uuid});

  /// Open an SSE stream for real-time filtered positions.
  /// Returns a stream of position data keyed by tagId.
  Stream<Map<String, List<MapPositionModel>>> positionStream(
      SsePositionRequest request);

  /// Close the current SSE position stream connection.
  void stopPositionStream();

  /// Dispose of resources (HTTP client, etc.).
  void dispose();
}
