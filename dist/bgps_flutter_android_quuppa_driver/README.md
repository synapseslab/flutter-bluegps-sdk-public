# bluegps_sdk_flutter

Flutter plugin for **BlueGPS BLE advertising** on Android. Wraps the native [BlueGPS Android SDK](https://github.com/synapseslab/android-bluegps-sdk-public) advertising service and exposes it to Dart via platform channels.

## Requirements

| Requirement | Version |
|---|---|
| Flutter | >= 3.29.0 |
| Dart SDK | >= 3.10.8 |
| Android minSdk | 21 |
| Android compileSdk | 35 |

## Installation

Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  bluegps_sdk_flutter:
    path: ../bluegps_sdk_flutter  # local path
    # or from git:
    # git:
    #   url: https://github.com/synapseslab/bluegps_sdk_flutter.git
    #   ref: main
```

### Android setup

#### 1. Add JitPack repository

In your app's `android/build.gradle.kts`, add JitPack to the repositories:

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}
```

#### 2. MainActivity

Your `MainActivity` can be a plain `FlutterActivity` — the plugin handles all channel registration automatically:

```kotlin
package com.example.myapp

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

## Usage

### Import

```dart
import 'package:bluegps_sdk_flutter/bluegps_sdk_flutter.dart';
```

### Request permissions

Before starting advertising, request the required Bluetooth permissions:

```dart
final granted = await BlueGpsPermissions.requestAdvertisingPermissions();
if (!granted) {
  // Handle denied permissions
  return;
}
```

On Android 12+ this requests `BLUETOOTH_SCAN`, `BLUETOOTH_ADVERTISE`, `BLUETOOTH_CONNECT`, and `NOTIFICATION` (for the foreground service). If any permission is permanently denied, the device settings page is opened automatically.

### Start advertising

```dart
final service = BlueGpsAdvertisingService();

final config = AndroidAdvConfiguration(
  tagid: "A0BB00000001",
  advModes: "ADVERTISE_MODE_LOW_LATENCY",
  advTxPowers: "ADVERTISE_TX_POWER_HIGH",
);

await service.startAdvertising(config);
```

### Listen to status updates

```dart
service.statusStream.listen((status) {
  print('Status: ${status.status.name}');  // STARTED, STOPPED, ERROR, UNKNOWN
  print('Message: ${status.message}');
  print('Config: ${status.androidAdvConfiguration?.tagid}');
});
```

### Stop advertising

```dart
await service.stopAdvertising();
```

### Check Bluetooth state

Query the current state once:

```dart
final state = await service.getBluetoothState();
print(state == BluetoothState.on ? 'BT is ON' : 'BT is OFF');
```

Or stream every ON/OFF transition (emits the current state immediately on subscribe):

```dart
service.bluetoothStateStream.listen((state) {
  if (state == BluetoothState.on) {
    print('Bluetooth turned on');
  } else {
    print('Bluetooth turned off');
  }
});
```

### Dispose

When you no longer need the service (e.g. in your widget's `dispose`):

```dart
service.dispose();
```

## API Reference

### BlueGpsAdvertisingService

| Member | Type | Description |
|---|---|---|
| `statusStream` | `Stream<AdvertisingStatus>` | Broadcast stream of status updates from the native service |
| `bluetoothStateStream` | `Stream<BluetoothState>` | Emits current BT state immediately, then streams every ON/OFF change |
| `getBluetoothState()` | `Future<BluetoothState>` | One-shot query for the current Bluetooth adapter state |
| `startAdvertising(config)` | `Future<void>` | Starts BLE advertising with the given configuration |
| `stopAdvertising()` | `Future<void>` | Stops BLE advertising |
| `dispose()` | `void` | Releases platform channel resources |

### BluetoothState

| Value | Description |
|---|---|
| `on` | Bluetooth adapter is enabled |
| `off` | Bluetooth adapter is disabled |

### AndroidAdvConfiguration

| Field | Type | Description |
|---|---|---|
| `tagid` | `String?` | Tag identifier for advertising |
| `advModes` | `String?` | BLE advertising mode (`ADVERTISE_MODE_LOW_LATENCY`, `ADVERTISE_MODE_LOW_POWER`, `ADVERTISE_MODE_BALANCED`) |
| `advTxPowers` | `String?` | BLE TX power level (`ADVERTISE_TX_POWER_HIGH`, `ADVERTISE_TX_POWER_MEDIUM`, `ADVERTISE_TX_POWER_LOW`, `ADVERTISE_TX_POWER_ULTRA_LOW`) |

### ServiceStatus

| Value | Description |
|---|---|
| `STARTED` | Advertising service is running |
| `STOPPED` | Advertising service is stopped |
| `ERROR` | An error occurred |
| `UNKNOWN` | Status not yet reported |

### BlueGpsPermissions

| Method | Returns | Description |
|---|---|---|
| `requestAdvertisingPermissions()` | `Future<bool>` | Requests all required Bluetooth permissions. Returns `true` if all granted. |

## Example

See the [example app](example/) for a complete working implementation.

## License

Proprietary - Synapses Lab
