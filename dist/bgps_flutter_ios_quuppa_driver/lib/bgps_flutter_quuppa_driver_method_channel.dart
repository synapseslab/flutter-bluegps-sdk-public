import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bgps_flutter_quuppa_driver_platform_interface.dart';

/// An implementation of [BgpsFlutterQuuppaDriverPlatform] that uses method channels.
class MethodChannelBgpsFlutterQuuppaDriver
    extends BgpsFlutterQuuppaDriverPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bgps_flutter_ios_quuppa_driver');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
