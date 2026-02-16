# Flutter BlueGPS SDK Example

Demonstrates how to use the flutter_bluegps_sdk plugin.

## Getting Started

This example shows how to:

1. Initialize the BlueGPS SDK
2. Start and stop positioning
3. Get the current position
4. Handle SDK events

## Running the Example

```bash
cd example
flutter pub get
flutter run
```

## Configuration

Before running the example, make sure to update the API key and server URL in `lib/main.dart`:

```dart
final config = BluegpsConfig(
  apiKey: 'your_api_key_here',
  serverUrl: 'https://your-server-url.com',
  debugEnabled: true,
);
```
