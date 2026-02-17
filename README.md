# BlueGPS SDK for Flutter

A Flutter package for BlueGPS indoor positioning: Quuppa BLE advertising, server authentication, device configuration, and real-time SSE position streaming.

Supports both **iOS** and **Android** with platform-specific BLE advertising plugins:
- iOS: [ios-bgps-quuppa-flutter-plugin](https://github.com/synapseslab/ios-bgps-quuppa-flutter-plugin)
- Android: [android-bgps-quuppa-flutter-plugin](https://github.com/synapseslab/android-bgps-quuppa-flutter-plugin)

## Features

- **Guest Login** — OAuth2 `client_credentials` via Keycloak
- **Device Configuration** — fetch platform-specific advertising config from the server
- **Quuppa BLE Advertising** — start/stop beacon advertising with server-provided config (iOS & Android)
- **SSE Position Streaming** — real-time filtered position stream via Server-Sent Events
- **Bluetooth State Monitoring** — reactive event stream with sealed classes for exhaustive pattern matching
- **Platform Abstraction** — factory method pattern auto-selects the correct Quuppa service for iOS or Android

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bluegps_sdk:
    git:
      url: https://github.com/synapseslab/flutter-bluegps-sdk.git
```

## Platform Setup

### iOS

Add Bluetooth permissions to `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to advertise beacon signals for indoor positioning</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to broadcast beacon advertisements</string>
```

Set minimum iOS deployment target to 14.0 in your `ios/Podfile`:

```ruby
platform :ios, '14.0'
```

### Android

Request BLE advertising permissions before initializing the SDK:

```dart
import 'package:flutter_bluegps_sdk/flutter_bluegps_sdk.dart';

final granted = await AndroidQuuppaService.requestPermissions();
if (!granted) {
  // Handle permission denial
}
```

On Android 12+ (API 31), the following permissions are requested automatically:
- `BLUETOOTH_SCAN`, `BLUETOOTH_ADVERTISE`, `BLUETOOTH_CONNECT`, `POST_NOTIFICATIONS`

## Quick Start

### 1. Create the SDK with server configuration

```dart
import 'package:flutter_bluegps_sdk/flutter_bluegps_sdk.dart';

final client = BlueGpsHttpClient(
  config: const BlueGpsServerConfig(
    baseUrl: 'http://<HOST>:<PORT>',
    keycloakUrl: 'http://<HOST>:<PORT>',
    keycloakRealm: '<REALM>',
    clientId: '<CLIENT_ID>',
    clientSecret: '<CLIENT_SECRET>',
  ),
);

final sdk = BlueGpsSdk(serverClient: client);
```

### 2. Initialize (login + config + start advertising)

```dart
await sdk.init(appId: 'my-app', uuid: 'device-uuid');
// This performs:
// 1. Guest login via Keycloak client_credentials
// 2. Fetch device config from the platform-specific endpoint:
//    - iOS:     /api/v1/device/ios/conf
//    - Android: /api/v1/device/android/conf
// 3. Start Quuppa advertising with the received config
```

### 3. Stream real-time positions

```dart
sdk.positionStream().listen((data) {
  print('Position: $data');
});

// With custom filters
sdk.positionStream(const SsePositionRequest(
  filter: SsePositionFilter(
    tagIdList: ['000000000001'],
    tagType: TagPositionType.physical,
  ),
  update: SsePositionUpdate(refresh: 1000),
)).listen((data) {
  print('Position: $data');
});
```

### 4. Listen to Bluetooth/advertising events

```dart
sdk.eventStream.listen((event) {
  switch (event) {
    case BlueGpsStateUpdate e:
      print('BT: ${e.bluetoothState}, advertising: ${e.isAdvertising}');
    case BlueGpsBluetoothStateChanged e:
      print('BT state changed: ${e.state}');
    case BlueGpsError e:
      print('Error: ${e.message}');
  }
});
```

### 5. Cleanup

```dart
sdk.dispose();
```

## Manual Advertising

You can start advertising manually without the server flow. Pass a platform-specific config:

```dart
// iOS
final sdk = BlueGpsSdk(quuppaService: IosQuuppaService());

await sdk.startAdvertising(
  const IosQuuppaAdvertisingConfig(
    tagId: '000000000001',
    byte1: 0x00,
    byte2: 0x01,
    frequency: BlueGpsBleFrequency.alwaysOn,
  ),
);

// Android
final sdk = BlueGpsSdk(quuppaService: AndroidQuuppaService());

await sdk.startAdvertising(
  const AndroidQuuppaAdvertisingConfig(
    tagId: 'A0BB00000001',
    advModes: AdvModes.lowLatency,
    advTxPowers: AdvTxPowers.high,
  ),
);

await sdk.stopAdvertising();
```

## API Reference

### BlueGpsSdk

| Method | Description |
|---|---|
| `init({required String appId, required String uuid})` | Guest login, fetch device config, start advertising |
| `positionStream([SsePositionRequest])` | Open SSE position stream |
| `startAdvertising(QuuppaAdvertisingConfig)` | Start BLE beacon advertising |
| `stopAdvertising()` | Stop advertising |
| `getBluetoothState()` | Get current Bluetooth adapter state |
| `isAdvertising()` | Check if currently advertising |
| `eventStream` | Stream of `BlueGpsEvent` updates |
| `deviceConfig` | Device configuration (available after `init()`) |
| `server` | Access to `BlueGpsClient` |
| `quuppa` | Direct access to `QuuppaService` |
| `dispose()` | Release resources |

### Server Configuration

| Field | Description |
|---|---|
| `baseUrl` | BlueGPS server URL (e.g. `http://localhost:7280`) |
| `keycloakUrl` | Keycloak server URL (e.g. `http://keycloak:8081`) |
| `keycloakRealm` | Keycloak realm (default: `bluegps`) |
| `clientId` | OAuth2 client ID |
| `clientSecret` | OAuth2 client secret |
| `timeoutMs` | Connection timeout in milliseconds (default: `30000`) |

### Models

- **`BlueGpsServerConfig`** — server and Keycloak connection settings
- **`BlueGpsAuthToken`** — OAuth2 token with expiry check
- **`DeviceConfiguration`** — device config with `IosAdvertisingConf` and `AndroidAdvertisingConf`
- **`QuuppaAdvertisingConfig`** (sealed) — base class for platform-specific advertising configs
  - **`IosQuuppaAdvertisingConfig`** — tagId, byte1, byte2, tOn, tOff, frequency
  - **`AndroidQuuppaAdvertisingConfig`** — tagId, advModes, advTxPowers
- **`AndroidAdvertisingConf`** — server model for Android advertising config
- **`AdvModes`** — lowPower, balanced, lowLatency
- **`AdvTxPowers`** — ultraLow, low, medium, high
- **`SsePositionRequest`** — SSE stream request with filter and update params
- **`SsePositionFilter`** — filter by mapId, tagId, tagType
- **`SsePositionUpdate`** — refresh rate, timeout, movement thresholds
- **`BlueGpsEvent`** (sealed) — `BlueGpsStateUpdate`, `BlueGpsBluetoothStateChanged`, `BlueGpsError`
- **`BlueGpsBluetoothState`** — unknown, poweredOn, poweredOff, unauthorized, unsupported, resetting
- **`BlueGpsBleFrequency`** — low, middle, high, alwaysOn

## Architecture

```
BlueGpsSdk (facade)
├── BlueGpsHttpClient (server communication)
│   ├── guestLogin()      → Keycloak OAuth2
│   ├── getDeviceConfig() → /api/v1/device/ios/conf (iOS)
│   │                     → /api/v1/device/android/conf (Android)
│   └── positionStream()  → SSE /api/v1/realtime/sse/position/filtered
│       └── SseService    → dart:io HttpClient for streaming
└── QuuppaService (abstract, factory method pattern)
    ├── IosQuuppaService     → bgps_flutter_ios_quuppa_driver (iOS plugin)
    └── AndroidQuuppaService → bgps_flutter_android_quuppa_driver (Android plugin)
```

The SDK uses **factory method pattern** (`QuuppaService.forPlatform()`) and **dependency injection** to automatically select the correct platform implementation at runtime. You can also inject a custom `QuuppaService` via the `BlueGpsSdk` constructor for testing or advanced use cases.

## License

MIT
