/// Configuration for connecting to the BlueGPS server.
class BlueGpsServerConfig {
  /// Base URL of the BlueGPS server (e.g. "http://localhost:7280").
  final String baseUrl;

  /// Keycloak server URL (e.g. "http://keycloak:8081").
  final String keycloakUrl;

  /// Keycloak realm name.
  final String keycloakRealm;

  /// OAuth2 client ID for client_credentials grant.
  final String clientId;

  /// OAuth2 client secret.
  final String clientSecret;

  /// Connection timeout in milliseconds.
  final int timeoutMs;

  const BlueGpsServerConfig({
    required this.baseUrl,
    required this.keycloakUrl,
    this.keycloakRealm = 'bluegps',
    required this.clientId,
    required this.clientSecret,
    this.timeoutMs = 30000,
  });

  /// Keycloak token endpoint URL.
  String get tokenEndpoint =>
      '$keycloakUrl/realms/$keycloakRealm/protocol/openid-connect/token';
}
