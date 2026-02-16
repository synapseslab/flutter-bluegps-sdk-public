import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'flutter_bluegps_sdk_platform_interface.dart';
import 'models/position.dart';
import 'models/bluegps_config.dart';

/// An implementation of [FlutterBluegpsSdkPlatform] that uses method channels.
class MethodChannelFlutterBluegpsSdk extends FlutterBluegpsSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_bluegps_sdk');

  @override
  Future<void> initialize(BluegpsConfig config) async {
    try {
      await methodChannel.invokeMethod('initialize', config.toMap());
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize BlueGPS SDK: ${e.message}');
    }
  }

  @override
  Future<void> startPositioning() async {
    try {
      await methodChannel.invokeMethod('startPositioning');
    } on PlatformException catch (e) {
      throw Exception('Failed to start positioning: ${e.message}');
    }
  }

  @override
  Future<void> stopPositioning() async {
    try {
      await methodChannel.invokeMethod('stopPositioning');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop positioning: ${e.message}');
    }
  }

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('getCurrentPosition');
      if (result == null) return null;
      return Position.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw Exception('Failed to get current position: ${e.message}');
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    try {
      final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
      return version;
    } on PlatformException catch (e) {
      throw Exception('Failed to get platform version: ${e.message}');
    }
  }
}
