import 'flutter_bluegps_sdk_platform_interface.dart';
import 'models/position.dart';
import 'models/bluegps_config.dart';

/// Main class for interacting with the BlueGPS SDK.
class FlutterBluegpsSdk {
  /// Initialize the BlueGPS SDK with the provided configuration.
  ///
  /// [config] - Configuration object containing SDK settings.
  static Future<void> initialize(BluegpsConfig config) {
    return FlutterBluegpsSdkPlatform.instance.initialize(config);
  }

  /// Start positioning services.
  ///
  /// Begins tracking the user's position using BlueGPS.
  static Future<void> startPositioning() {
    return FlutterBluegpsSdkPlatform.instance.startPositioning();
  }

  /// Stop positioning services.
  ///
  /// Stops tracking the user's position.
  static Future<void> stopPositioning() {
    return FlutterBluegpsSdkPlatform.instance.stopPositioning();
  }

  /// Get the current position.
  ///
  /// Returns the current [Position] or null if not available.
  static Future<Position?> getCurrentPosition() {
    return FlutterBluegpsSdkPlatform.instance.getCurrentPosition();
  }

  /// Get the platform version.
  ///
  /// Returns the platform version string.
  static Future<String?> getPlatformVersion() {
    return FlutterBluegpsSdkPlatform.instance.getPlatformVersion();
  }
}
