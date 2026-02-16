# BlueGPS SDK Demo

Demo app for the `flutter_bluegps_sdk` package. Initializes the SDK, starts Quuppa advertising, and streams real-time positions via SSE.

## What it does

1. **Init SDK** — performs guest login (Keycloak), fetches device config, and starts Quuppa BLE advertising
2. **Start SSE** — opens a Server-Sent Events stream for real-time filtered positions
3. **Stop SSE** — closes the position stream

All events are logged in a scrollable list with timestamps.

## Configuration

Edit the server settings in `lib/main.dart` before running:

```dart
final client = BlueGpsHttpClient(
  config: const BlueGpsServerConfig(
    baseUrl: 'http://<HOST>:<PORT>',
    keycloakUrl: 'http://<HOST>:<PORT>',
    keycloakRealm: '<REALM>',
    clientId: '<CLIENT_ID>',
    clientSecret: '<CLIENT_SECRET>',
  ),
  httpClient: http.Client(),
);
```

Replace the placeholders with your BlueGPS server environment values.

## Running

```bash
cd example
flutter pub get
flutter run
```

> **Note:** Quuppa advertising requires a physical iOS device. The server API calls work on simulator but BLE advertising does not.

## iOS Setup

The example app is already configured with:

- Bluetooth permission keys in `ios/Runner/Info.plist`
- Minimum deployment target `ios 14.0` in `ios/Podfile`
