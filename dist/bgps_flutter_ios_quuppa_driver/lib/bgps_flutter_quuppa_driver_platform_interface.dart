import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bgps_flutter_quuppa_driver_method_channel.dart';

abstract class BgpsFlutterQuuppaDriverPlatform extends PlatformInterface {
  /// Constructs a BgpsFlutterQuuppaDriverPlatform.
  BgpsFlutterQuuppaDriverPlatform() : super(token: _token);

  static final Object _token = Object();

  static BgpsFlutterQuuppaDriverPlatform _instance = MethodChannelBgpsFlutterQuuppaDriver();

  /// The default instance of [BgpsFlutterQuuppaDriverPlatform] to use.
  ///
  /// Defaults to [MethodChannelBgpsFlutterQuuppaDriver].
  static BgpsFlutterQuuppaDriverPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BgpsFlutterQuuppaDriverPlatform] when
  /// they register themselves.
  static set instance(BgpsFlutterQuuppaDriverPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
