import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_bluegps_sdk_method_channel.dart';
import 'models/position.dart';
import 'models/bluegps_config.dart';

/// The interface that platform-specific implementations must extend.
abstract class FlutterBluegpsSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterBluegpsSdkPlatform.
  FlutterBluegpsSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBluegpsSdkPlatform _instance = MethodChannelFlutterBluegpsSdk();

  /// The default instance of [FlutterBluegpsSdkPlatform] to use.
  static FlutterBluegpsSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBluegpsSdkPlatform] when
  /// they register themselves.
  static set instance(FlutterBluegpsSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the BlueGPS SDK with the provided configuration.
  Future<void> initialize(BluegpsConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Start positioning services.
  Future<void> startPositioning() {
    throw UnimplementedError('startPositioning() has not been implemented.');
  }

  /// Stop positioning services.
  Future<void> stopPositioning() {
    throw UnimplementedError('stopPositioning() has not been implemented.');
  }

  /// Get the current position.
  Future<Position?> getCurrentPosition() {
    throw UnimplementedError('getCurrentPosition() has not been implemented.');
  }

  /// Get the platform version.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }
}
