import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/sdk_exception.dart';
import 'auth/auth_models.dart';
import 'bluegps_client.dart';
import 'config/server_config.dart';
import 'models/device_config.dart';
import 'models/position.dart';
import 'sse/sse_models.dart';
import 'sse/sse_service.dart';

/// Concrete HTTP implementation of [BlueGpsClient].
class BlueGpsHttpClient implements BlueGpsClient {
  @override
  final BlueGpsServerConfig config;

  final http.Client _httpClient;
  BlueGpsAuthToken? _token;
  SseService? _sseService;

  BlueGpsHttpClient({required this.config, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  BlueGpsAuthToken? get currentToken => _token;

  Map<String, String> get _authHeaders => {
        if (_token != null) 'Authorization': 'Bearer ${_token!.accessToken}',
      };

  @override
  Future<BlueGpsAuthToken> guestLogin() async {
    try {
      final response = await _httpClient.post(
        Uri.parse(config.tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': config.clientId,
          'client_secret': config.clientSecret,
        },
      );

      if (response.statusCode != 200) {
        throw BlueGpsServerException(
          'Guest login failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      _token = BlueGpsAuthToken.fromJson(json);
      return _token!;
    } on BlueGpsServerException {
      rethrow;
    } catch (e) {
      throw BlueGpsServerException('Guest login failed', cause: e);
    }
  }

  @override
  Future<DeviceConfiguration> getDeviceConfig(
      {String appId = 'flutter-sdk',
      String uuid = 'flutter-sdk-device'}) async {
    _requireAuth();
    try {
      final endpoint = Platform.isAndroid
          ? '/api/v1/device/android/conf'
          : '/api/v1/device/ios/conf';

      final response = await _httpClient.post(
        Uri.parse('${config.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          ..._authHeaders,
        },
        body: jsonEncode({'appId': appId, 'uuid': uuid}),
      );

      if (response.statusCode != 200) {
        throw BlueGpsServerException(
          'Failed to get device config: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeviceConfiguration.fromJson(json);
    } on BlueGpsServerException {
      rethrow;
    } catch (e) {
      throw BlueGpsServerException('Failed to get device config', cause: e);
    }
  }

  @override
  Stream<Map<String, List<MapPositionModel>>> positionStream(
      SsePositionRequest request) {
    _requireAuth();
    _sseService?.dispose();
    _sseService = SseService(
      url: '${config.baseUrl}/api/v1/realtime/sse/position/filtered',
      token: _token!.accessToken,
      body: request.toJson(),
    );
    return _sseService!.stream;
  }

  @override
  void stopPositionStream() {
    _sseService?.dispose();
    _sseService = null;
  }

  void _requireAuth() {
    if (_token == null) {
      throw BlueGpsServerException(
          'Not authenticated. Call guestLogin() first.');
    }
  }

  @override
  void dispose() {
    _sseService?.dispose();
    _httpClient.close();
  }
}
