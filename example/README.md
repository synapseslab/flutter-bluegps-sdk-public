# BlueGPS SDK Demo

Demo app for the `flutter_bluegps_sdk` package. Initializes the SDK, starts Quuppa advertising, and streams real-time positions via SSE.

Supports both **iOS** and **Android** — the SDK auto-detects the platform and uses the appropriate BLE advertising plugin and server endpoint.

## What it does

1. **Init SDK** — performs guest login (Keycloak), fetches device config, checks Bluetooth state, and starts Quuppa BLE advertising. If Bluetooth is off, shows an error and waits for auto-restart.
2. **Start/Stop Adv** — manually start or stop BLE advertising. Start is blocked when Bluetooth is off. Stopping disables auto-restart; starting re-enables it.
3. **Start/Stop SSE** — open or close a Server-Sent Events stream for real-time filtered positions. Start SSE is only enabled when advertising is active.

The app shows a live **Bluetooth status indicator** (color-coded: green=on, red=off, orange=unauthorized/resetting) and **advertising status**. On Android, Bluetooth on/off is detected in real-time via the native BroadcastReceiver. On iOS, the event stream is deduplicated so only actual state changes appear in the log. All events are logged in a scrollable list with timestamps.

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

## Platform Notes

### iOS

The example app is already configured with:

- Bluetooth permission keys in `ios/Runner/Info.plist`
- Minimum deployment target `ios 14.0` in `ios/Podfile`

> Quuppa advertising requires a physical iOS device. The server API calls work on simulator but BLE advertising does not.

### Android

On Android 12+ (API 31), BLE advertising permissions (`BLUETOOTH_SCAN`, `BLUETOOTH_ADVERTISE`, `BLUETOOTH_CONNECT`, `POST_NOTIFICATIONS`) are requested at runtime by the SDK. The device config is fetched from `/api/v1/device/android/conf` and includes `AndroidAdvertisingConf` with `advModes` and `advTxPowers`.
