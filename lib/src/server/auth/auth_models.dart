/// Authentication token returned by Keycloak OAuth2.
class BlueGpsAuthToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const BlueGpsAuthToken({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  factory BlueGpsAuthToken.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] as int?;
    return BlueGpsAuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: expiresIn != null
          ? DateTime.now().add(Duration(seconds: expiresIn))
          : null,
    );
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
