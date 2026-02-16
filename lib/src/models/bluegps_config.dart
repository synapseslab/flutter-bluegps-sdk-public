/// Configuration for the BlueGPS SDK.
class BluegpsConfig {
  /// API key for BlueGPS service
  final String apiKey;

  /// Server URL for BlueGPS service
  final String serverUrl;

  /// Whether to enable debug logging
  final bool debugEnabled;

  /// Additional configuration parameters
  final Map<String, dynamic>? additionalParams;

  BluegpsConfig({
    required this.apiKey,
    required this.serverUrl,
    this.debugEnabled = false,
    this.additionalParams,
  });

  /// Creates a BluegpsConfig from a map.
  factory BluegpsConfig.fromMap(Map<String, dynamic> map) {
    return BluegpsConfig(
      apiKey: map['apiKey'] as String,
      serverUrl: map['serverUrl'] as String,
      debugEnabled: map['debugEnabled'] as bool? ?? false,
      additionalParams: map['additionalParams'] != null
          ? Map<String, dynamic>.from(map['additionalParams'] as Map)
          : null,
    );
  }

  /// Converts the BluegpsConfig to a map.
  Map<String, dynamic> toMap() {
    return {
      'apiKey': apiKey,
      'serverUrl': serverUrl,
      'debugEnabled': debugEnabled,
      'additionalParams': additionalParams,
    };
  }

  @override
  String toString() {
    return 'BluegpsConfig(apiKey: $apiKey, serverUrl: $serverUrl, debugEnabled: $debugEnabled)';
  }
}
