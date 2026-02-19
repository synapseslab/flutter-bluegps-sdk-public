# BGPS Flutter Quuppa Driver

A Flutter plugin for Quuppa beacon advertising on iOS devices. This plugin enables Flutter apps to advertise BLE (Bluetooth Low Energy) beacons using the Quuppa indoor positioning protocol.

## Features

✅ Start and stop Quuppa beacon advertising
✅ Real-time Bluetooth state monitoring
✅ Configurable advertising parameters (tag ID, bytes, frequency)
✅ Event stream for state changes and errors
✅ Full error handling and permission management

## Platform Support

| Platform | Supported |
|----------|-----------|
| iOS      | ✅ Yes    |
| Android  | 🟡 Planned (see [ANDROID_INTEGRATION.md](ANDROID_INTEGRATION.md)) |

## Requirements

- iOS 14.0 or higher
- Bluetooth LE support on device
- Bluetooth permissions granted

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  bgps_flutter_quuppa_driver:
    path: ../bgps_flutter_quuppa_driver  # Update with your path
```

Then run:

```bash
flutter pub get
```

## iOS Setup

### 1. Add Bluetooth Permissions

Add the following keys to your `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to advertise beacon signals for indoor positioning</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to broadcast beacon advertisements</string>
```

### 2. Set Minimum iOS Version

Ensure your `ios/Podfile` has the minimum iOS version set:

```ruby
platform :ios, '14.0'
```

## Usage

### Basic Example

```dart
import 'package:bgps_flutter_quuppa_driver/bgps_flutter_quuppa_driver.dart';

// Start advertising
await BgpsFlutterQuuppaDriver.startAdvertising(
  tagId: '000000000001',  // 12 hex characters
  byte1: 0x00,
  byte2: 0x01,
  tOn: 0,
  tOff: 0,
  frequency: BLEFrequency.alwaysOn,
);

// Stop advertising
await BgpsFlutterQuuppaDriver.stopAdvertising();
```

### Listening to State Changes

```dart
import 'dart:async';
import 'package:bgps_flutter_quuppa_driver/bgps_flutter_quuppa_driver.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription<BgpsEvent>? _subscription;
  BluetoothState _bluetoothState = BluetoothState.unknown;
  bool _isAdvertising = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _listenToEvents();
  }

  void _listenToEvents() {
    _subscription = BgpsFlutterQuuppaDriver.eventStream.listen(
      (event) {
        if (event is StateUpdateEvent) {
          setState(() {
            _bluetoothState = event.bluetoothState;
            _isAdvertising = event.isAdvertising;
            _error = event.error;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Bluetooth: $_bluetoothState'),
        Text('Advertising: $_isAdvertising'),
        if (_error != null) Text('Error: $_error'),
      ],
    );
  }
}
```

## API Reference

### Methods

#### `startAdvertising()`

Starts advertising Quuppa beacon.

```dart
Future<void> startAdvertising({
  required String tagId,      // 12 hex characters
  required int byte1,         // 0-255
  required int byte2,         // 0-255
  double? tOn,                // Optional: time ON in seconds
  double? tOff,               // Optional: time OFF in seconds
  BLEFrequency? frequency,    // Optional: BLE frequency mode
})
```

**Throws:** `Exception` if advertising fails to start.

#### `stopAdvertising()`

Stops advertising beacon.

```dart
Future<void> stopAdvertising()
```

#### `getBluetoothState()`

Gets current Bluetooth state.

```dart
Future<String> getBluetoothState()
```

**Returns:** One of: `unknown`, `poweredOn`, `poweredOff`, `unauthorized`, `unsupported`, `resetting`

#### `isAdvertising()`

Checks if currently advertising.

```dart
Future<bool> isAdvertising()
```

### Events

Subscribe to `BgpsFlutterQuuppaDriver.eventStream` to receive events:

#### `StateUpdateEvent`

Complete state update with Bluetooth state, advertising status, and errors.

```dart
class StateUpdateEvent {
  final BluetoothState bluetoothState;
  final bool isAdvertising;
  final String? error;
}
```

#### `BluetoothStateChangedEvent`

Bluetooth state changed.

```dart
class BluetoothStateChangedEvent {
  final BluetoothState state;
  final bool isReady;
}
```

#### `ErrorEvent`

Error occurred.

```dart
class ErrorEvent {
  final String error;
}
```

### Enums

#### `BluetoothState`

```dart
enum BluetoothState {
  unknown,
  poweredOn,
  poweredOff,
  unauthorized,
  unsupported,
  resetting,
}
```

#### `BLEFrequency`

```dart
enum BLEFrequency {
  low,      // Low frequency
  middle,   // Middle frequency
  high,     // High frequency
  alwaysOn, // Always on (continuous advertising)
}
```

## Error Handling

The plugin handles various error scenarios:

| Error Scenario | Behavior |
|----------------|----------|
| Bluetooth Off | Error event sent, button disabled |
| Bluetooth Unauthorized | Error event sent, shows permission error |
| Invalid Tag ID | Validation error before starting |
| Start fails | Exception thrown with error message |
| Bluetooth turns off during advertising | Stops advertising, error event sent |

## Example App

A complete example app is included in the `example/` directory. To run it:

```bash
cd example
flutter run
```

The example demonstrates:
- Real-time Bluetooth state monitoring
- Start/stop advertising with visual feedback
- Error display
- Configuration UI

## Troubleshooting

### Bluetooth permission denied

Make sure you've added the Bluetooth usage descriptions to your `Info.plist` (see iOS Setup above).

### App crashes on start

Check that your minimum iOS version is set to 14.0 or higher in both `Podfile` and Xcode project settings.

### Advertising doesn't start

1. Check that Bluetooth is enabled on the device
2. Verify the tag ID is exactly 12 hexadecimal characters
3. Check the console for error messages

## Architecture

```
Flutter (Dart)
    ↕️ Method Channel (commands)
    ↕️ Event Channel (state updates)
iOS Native (Swift)
    ↕️ BgpsFlutterQuuppaDriver (bridge)
    ↕️ QuuppaDriver (beacon logic)
    ↕️ CoreBluetooth (iOS framework)
```

## Rebuilding the XCFramework after source changes

The iOS native code is distributed as a pre-compiled XCFramework binary. The source files are kept in `ios/Classes/` for development purposes but are not shipped to plugin consumers.

After modifying any Swift source file in `ios/Classes/`, rebuild the XCFramework by running:

```bash
# 1. Ensure the example app environment is set up
flutter pub get
cd example && flutter pub get
cd ios && pod install
cd ../..

# 2. Temporarily restore source_files in the podspec (needed for compilation)
# In ios/bgps_flutter_ios_quuppa_driver.podspec, replace:
#   s.vendored_frameworks = 'Frameworks/bgps_flutter_ios_quuppa_driver.xcframework'
# with:
#   s.source_files = 'Classes/**/*'
# Then re-run pod install in example/ios/

# 3. Build the XCFramework
./ios/build_xcframework.sh

# 4. Restore vendored_frameworks in the podspec
# In ios/bgps_flutter_ios_quuppa_driver.podspec, replace:
#   s.source_files = 'Classes/**/*'
# with:
#   s.vendored_frameworks = 'Frameworks/bgps_flutter_ios_quuppa_driver.xcframework'
```

The build script produces a universal XCFramework at `ios/Frameworks/bgps_flutter_ios_quuppa_driver.xcframework` containing:

- **iOS device** (arm64)
- **iOS Simulator** (arm64 + x86_64)

## Credits

Written by Costantino Pistagna with ❤️ using Flutter and Swift.
Copyright 2026 - Synapses s.rl. - All rights reserved.
