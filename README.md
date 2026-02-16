# flutter_bluegps_sdk

BlueGPS SDK for Flutter Applications - A Flutter plugin for integrating BlueGPS indoor positioning system in iOS and Android applications.

## Features

- Initialize BlueGPS SDK with custom configuration
- Start and stop positioning services
- Get current position with coordinates and accuracy
- Support for both iOS and Android platforms
- Easy-to-use API

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_bluegps_sdk:
    git:
      url: https://github.com/synapseslab/flutter-bluegps-sdk.git
```

### iOS Setup

Add the following to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide indoor positioning</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to provide indoor positioning</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access for indoor positioning</string>
```

### Android Setup

Make sure your `AndroidManifest.xml` includes the necessary permissions (already included in the plugin):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

## Usage

### Initialize the SDK

```dart
import 'package:flutter_bluegps_sdk/flutter_bluegps_sdk.dart';

// Create configuration
final config = BluegpsConfig(
  apiKey: 'your_api_key_here',
  serverUrl: 'https://your-server-url.com',
  debugEnabled: true,
);

// Initialize SDK
await FlutterBluegpsSdk.initialize(config);
```

### Start Positioning

```dart
await FlutterBluegpsSdk.startPositioning();
```

### Get Current Position

```dart
Position? position = await FlutterBluegpsSdk.getCurrentPosition();
if (position != null) {
  print('X: ${position.x}, Y: ${position.y}');
  print('Floor: ${position.floor}');
  print('Accuracy: ${position.accuracy}m');
}
```

### Stop Positioning

```dart
await FlutterBluegpsSdk.stopPositioning();
```

## Example

See the [example](example) directory for a complete sample application demonstrating how to use the plugin.

## Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅      |
| iOS      | ✅      |

## API Reference

### Classes

#### `FlutterBluegpsSdk`

Main class for interacting with the BlueGPS SDK.

##### Methods

- `initialize(BluegpsConfig config)` - Initialize the SDK with configuration
- `startPositioning()` - Start positioning services
- `stopPositioning()` - Stop positioning services
- `getCurrentPosition()` - Get the current position
- `getPlatformVersion()` - Get the platform version

#### `BluegpsConfig`

Configuration class for the BlueGPS SDK.

##### Properties

- `apiKey` (String) - API key for BlueGPS service
- `serverUrl` (String) - Server URL for BlueGPS service
- `debugEnabled` (bool) - Enable debug logging
- `additionalParams` (Map<String, dynamic>?) - Additional configuration parameters

#### `Position`

Represents a position in the BlueGPS system.

##### Properties

- `x` (double) - X coordinate
- `y` (double) - Y coordinate
- `floor` (int?) - Floor/level identifier
- `timestamp` (DateTime) - Timestamp when the position was recorded
- `accuracy` (double?) - Accuracy of the position in meters
- `metadata` (Map<String, dynamic>?) - Additional metadata

## iOS Plugin Integration

This SDK is designed to work with the iOS BlueGPS Quuppa Flutter plugin available at:
https://github.com/synapseslab/ios-bgps-quuppa-flutter-plugin

To integrate the iOS plugin:

1. Add the iOS plugin to your `ios/Podfile` or as a dependency
2. Follow the iOS plugin's setup instructions
3. The Flutter SDK will automatically communicate with the native iOS implementation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
