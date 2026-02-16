import 'package:flutter_bluegps_sdk/flutter_bluegps_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlueGpsEvent sealed class', () {
    test('BlueGpsStateUpdate holds correct values', () {
      final event = BlueGpsStateUpdate(
        bluetoothState: BlueGpsBluetoothState.poweredOn,
        isAdvertising: true,
        error: null,
      );

      expect(event.bluetoothState, BlueGpsBluetoothState.poweredOn);
      expect(event.isAdvertising, true);
      expect(event.error, isNull);
    });

    test('BlueGpsStateUpdate with error', () {
      final event = BlueGpsStateUpdate(
        bluetoothState: BlueGpsBluetoothState.poweredOff,
        isAdvertising: false,
        error: 'Bluetooth is off',
      );

      expect(event.error, 'Bluetooth is off');
    });

    test('BlueGpsBluetoothStateChanged holds correct values', () {
      final event = BlueGpsBluetoothStateChanged(
        state: BlueGpsBluetoothState.poweredOn,
        isReady: true,
      );

      expect(event.state, BlueGpsBluetoothState.poweredOn);
      expect(event.isReady, true);
    });

    test('BlueGpsError holds message', () {
      final event = BlueGpsError(message: 'Something went wrong');

      expect(event.message, 'Something went wrong');
    });

    test('exhaustive pattern matching works', () {
      final BlueGpsEvent event = BlueGpsStateUpdate(
        bluetoothState: BlueGpsBluetoothState.unknown,
        isAdvertising: false,
      );

      // This must compile without a default case thanks to sealed class
      final result = switch (event) {
        BlueGpsStateUpdate _ => 'stateUpdate',
        BlueGpsBluetoothStateChanged _ => 'btChanged',
        BlueGpsError _ => 'error',
      };

      expect(result, 'stateUpdate');
    });
  });

  group('BlueGpsBluetoothState', () {
    test('has all expected values', () {
      expect(BlueGpsBluetoothState.values, hasLength(6));
      expect(BlueGpsBluetoothState.values, contains(BlueGpsBluetoothState.unknown));
      expect(BlueGpsBluetoothState.values, contains(BlueGpsBluetoothState.poweredOn));
      expect(BlueGpsBluetoothState.values, contains(BlueGpsBluetoothState.poweredOff));
      expect(BlueGpsBluetoothState.values, contains(BlueGpsBluetoothState.unauthorized));
      expect(BlueGpsBluetoothState.values, contains(BlueGpsBluetoothState.unsupported));
      expect(BlueGpsBluetoothState.values, contains(BlueGpsBluetoothState.resetting));
    });
  });

  group('BlueGpsBleFrequency', () {
    test('has all expected values', () {
      expect(BlueGpsBleFrequency.values, hasLength(4));
      expect(BlueGpsBleFrequency.values, contains(BlueGpsBleFrequency.low));
      expect(BlueGpsBleFrequency.values, contains(BlueGpsBleFrequency.middle));
      expect(BlueGpsBleFrequency.values, contains(BlueGpsBleFrequency.high));
      expect(BlueGpsBleFrequency.values, contains(BlueGpsBleFrequency.alwaysOn));
    });
  });
}
