import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Utility for requesting the Bluetooth permissions required by the BlueGPS
/// advertising service.
class BlueGpsPermissions {
  BlueGpsPermissions._();

  /// Requests all permissions needed for BLE advertising on Android.
  ///
  /// On Android 12+ (API 31) this requests:
  /// - [Permission.bluetoothScan]
  /// - [Permission.bluetoothAdvertise]
  /// - [Permission.bluetoothConnect]
  /// - [Permission.notification] (foreground service on Android 13+)
  ///
  /// Returns `true` when all permissions are granted, `false` otherwise.
  /// If any permission is permanently denied, opens the app settings page.
  static Future<bool> requestAdvertisingPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.notification,
      ].request();

      bool allGranted = statuses.values.every(
        (status) => status == PermissionStatus.granted,
      );

      if (allGranted) {
        return true;
      }

      if (statuses.values
          .any((status) => status == PermissionStatus.permanentlyDenied)) {
        await openAppSettings();
        return false;
      }

      return false;
    }

    // iOS or other platforms – no BLE advertising permissions needed yet.
    return true;
  }
}