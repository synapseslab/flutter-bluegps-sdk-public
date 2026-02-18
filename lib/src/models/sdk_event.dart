import 'bluetooth_state.dart';

/// Base class for all SDK events.
sealed class BlueGpsEvent {}

/// Full state snapshot.
class BlueGpsStateUpdate extends BlueGpsEvent {
  final BlueGpsBluetoothState bluetoothState;
  final bool isAdvertising;
  final String? error;

  BlueGpsStateUpdate({
    required this.bluetoothState,
    required this.isAdvertising,
    this.error,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlueGpsStateUpdate &&
          bluetoothState == other.bluetoothState &&
          isAdvertising == other.isAdvertising &&
          error == other.error;

  @override
  int get hashCode => Object.hash(bluetoothState, isAdvertising, error);

  @override
  String toString() =>
      'BlueGpsStateUpdate(bluetoothState: $bluetoothState, isAdvertising: $isAdvertising, error: $error)';
}

/// Bluetooth adapter state changed.
class BlueGpsBluetoothStateChanged extends BlueGpsEvent {
  final BlueGpsBluetoothState state;
  final bool isReady;

  BlueGpsBluetoothStateChanged({
    required this.state,
    required this.isReady,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlueGpsBluetoothStateChanged &&
          state == other.state &&
          isReady == other.isReady;

  @override
  int get hashCode => Object.hash(state, isReady);

  @override
  String toString() =>
      'BlueGpsBluetoothStateChanged(state: $state, isReady: $isReady)';
}

/// An error occurred.
class BlueGpsError extends BlueGpsEvent {
  final String message;

  BlueGpsError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlueGpsError && message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'BlueGpsError(message: $message)';
}
