library;

import 'dart:async';
import 'package:flutter/services.dart';

/// Main plugin class for BGPS Flutter Plugin
/// Provides access to Quuppa beacon advertising functionality
class BgpsFlutterQuuppaDriver {
  static const MethodChannel _methodChannel =
      MethodChannel('bgps_flutter_ios_quuppa_driver/methods');
  static const EventChannel _eventChannel =
      EventChannel('bgps_flutter_ios_quuppa_driver/events');

  static Stream<BgpsEvent>? _eventStream;

  /// Stream of Bluetooth state changes, advertising status, and errors
  /// Subscribe to this stream to receive real-time updates
  static Stream<BgpsEvent> get eventStream {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _parseEvent(event));
    return _eventStream!;
  }

  /// Start advertising Quuppa beacon
  ///
  /// [tagId] - 12 character hexadecimal tag ID
  /// [byte1] - First configuration byte (0-255)
  /// [byte2] - Second configuration byte (0-255)
  /// [tOn] - Optional time ON in seconds
  /// [tOff] - Optional time OFF in seconds
  /// [frequency] - Optional BLE frequency mode
  ///
  /// Throws [PlatformException] if advertising fails to start
  static Future<void> startAdvertising({
    required String tagId,
    required int byte1,
    required int byte2,
    double? tOn,
    double? tOff,
    BLEFrequency? frequency,
  }) async {
    if (tagId.length != 12) {
      throw ArgumentError('tagId must be exactly 12 hexadecimal characters');
    }
    if (byte1 < 0 || byte1 > 255) {
      throw ArgumentError('byte1 must be between 0 and 255');
    }
    if (byte2 < 0 || byte2 > 255) {
      throw ArgumentError('byte2 must be between 0 and 255');
    }

    try {
      await _methodChannel.invokeMethod('startAdvertising', {
        'tagId': tagId,
        'byte1': byte1,
        'byte2': byte2,
        if (tOn != null) 'tOn': tOn,
        if (tOff != null) 'tOff': tOff,
        if (frequency != null) 'frequency': frequency.index,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to start advertising: ${e.message}');
    }
  }

  /// Stop advertising beacon
  static Future<void> stopAdvertising() async {
    try {
      await _methodChannel.invokeMethod('stopAdvertising');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop advertising: ${e.message}');
    }
  }

  /// Get current Bluetooth state
  /// Returns one of: unknown, poweredOn, poweredOff, unauthorized, unsupported, resetting
  static Future<String> getBluetoothState() async {
    try {
      final String state =
          await _methodChannel.invokeMethod('getBluetoothState');
      return state;
    } on PlatformException catch (e) {
      throw Exception('Failed to get Bluetooth state: ${e.message}');
    }
  }

  /// Check if currently advertising
  static Future<bool> isAdvertising() async {
    try {
      final bool advertising =
          await _methodChannel.invokeMethod('isAdvertising');
      return advertising;
    } on PlatformException catch (e) {
      throw Exception('Failed to check advertising status: ${e.message}');
    }
  }

  /// Parse event from native code
  static BgpsEvent _parseEvent(dynamic event) {
    if (event is! Map) {
      return UnknownEvent();
    }

    final map = Map<String, dynamic>.from(event);
    final type = map['type'] as String?;

    switch (type) {
      case 'stateUpdate':
        return StateUpdateEvent(
          bluetoothState:
              _parseBluetoothState(map['bluetoothState'] as String?),
          isAdvertising: map['isAdvertising'] as bool? ?? false,
          error: map['error'] as String?,
        );
      case 'bluetoothStateChanged':
        return BluetoothStateChangedEvent(
          state: _parseBluetoothState(map['state'] as String?),
          isReady: map['isReady'] as bool? ?? false,
        );
      case 'error':
        return ErrorEvent(
          error: map['error'] as String? ?? 'Unknown error',
        );
      default:
        return UnknownEvent();
    }
  }

  /// Parse Bluetooth state string to enum
  static BluetoothState _parseBluetoothState(String? state) {
    switch (state) {
      case 'poweredOn':
        return BluetoothState.poweredOn;
      case 'poweredOff':
        return BluetoothState.poweredOff;
      case 'unauthorized':
        return BluetoothState.unauthorized;
      case 'unsupported':
        return BluetoothState.unsupported;
      case 'resetting':
        return BluetoothState.resetting;
      default:
        return BluetoothState.unknown;
    }
  }

  getPlatformVersion() {}
}

/// Base class for all events from the plugin
abstract class BgpsEvent {}

/// State update event containing current Bluetooth state, advertising status, and any errors
class StateUpdateEvent extends BgpsEvent {
  final BluetoothState bluetoothState;
  final bool isAdvertising;
  final String? error;

  StateUpdateEvent({
    required this.bluetoothState,
    required this.isAdvertising,
    this.error,
  });

  @override
  String toString() =>
      'StateUpdateEvent(bluetoothState: $bluetoothState, isAdvertising: $isAdvertising, error: $error)';
}

/// Bluetooth state changed event
class BluetoothStateChangedEvent extends BgpsEvent {
  final BluetoothState state;
  final bool isReady;

  BluetoothStateChangedEvent({
    required this.state,
    required this.isReady,
  });

  @override
  String toString() =>
      'BluetoothStateChangedEvent(state: $state, isReady: $isReady)';
}

/// Error event
class ErrorEvent extends BgpsEvent {
  final String error;

  ErrorEvent({required this.error});

  @override
  String toString() => 'ErrorEvent(error: $error)';
}

/// Unknown event type
class UnknownEvent extends BgpsEvent {
  @override
  String toString() => 'UnknownEvent()';
}

/// Bluetooth state enum
enum BluetoothState {
  unknown,
  poweredOn,
  poweredOff,
  unauthorized,
  unsupported,
  resetting,
}

/// BLE Frequency modes for Quuppa advertising
enum BLEFrequency {
  low, // 0 - Low frequency
  middle, // 1 - Middle frequency
  high, // 2 - High frequency
  alwaysOn, // 3 - Always on
}
