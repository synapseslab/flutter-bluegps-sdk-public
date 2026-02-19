/// Status of the BlueGPS advertising service.
enum ServiceStatus {
  /// The advertising service is running.
  STARTED,

  /// The advertising service is stopped.
  STOPPED,

  /// An error occurred in the advertising service.
  ERROR,

  /// The status is unknown or not yet reported.
  UNKNOWN;

  /// Parses a [status] string into a [ServiceStatus] value.
  static ServiceStatus fromString(String? status) {
    switch (status) {
      case 'STARTED':
        return ServiceStatus.STARTED;
      case 'STOPPED':
        return ServiceStatus.STOPPED;
      case 'ERROR':
        return ServiceStatus.ERROR;
      default:
        return ServiceStatus.UNKNOWN;
    }
  }
}

/// Configuration for the Android BLE advertising.
class AndroidAdvConfiguration {
  /// The tag identifier used for advertising.
  final String? tagid;

  /// The BLE advertising mode (e.g. `ADVERTISE_MODE_LOW_LATENCY`).
  final String? advModes;

  /// The BLE advertising TX power (e.g. `ADVERTISE_TX_POWER_HIGH`).
  final String? advTxPowers;

  /// Creates an [AndroidAdvConfiguration].
  AndroidAdvConfiguration({this.tagid, this.advModes, this.advTxPowers});

  /// Creates an [AndroidAdvConfiguration] from a platform [map].
  factory AndroidAdvConfiguration.fromMap(Map<dynamic, dynamic> map) {
    return AndroidAdvConfiguration(
      tagid: map['tagid'],
      advModes: map['advModes'],
      advTxPowers: map['advTxPowers'],
    );
  }

  /// Converts this configuration to a platform map.
  Map<String, dynamic> toMap() {
    return {
      'tagid': tagid,
      'advModes': advModes,
      'advTxPowers': advTxPowers,
    };
  }
}

/// Status update emitted by the BlueGPS advertising service.
class AdvertisingStatus {
  /// The current service status.
  final ServiceStatus status;

  /// A human-readable message describing the current state.
  final String message;

  /// The advertising configuration in use, if any.
  final AndroidAdvConfiguration? androidAdvConfiguration;

  /// Creates an [AdvertisingStatus].
  AdvertisingStatus({
    required this.status,
    required this.message,
    this.androidAdvConfiguration,
  });

  /// Creates an [AdvertisingStatus] from a platform [map].
  factory AdvertisingStatus.fromMap(Map<dynamic, dynamic> map) {
    return AdvertisingStatus(
      status: ServiceStatus.fromString(map['status']),
      message: map['message'] ?? 'No message',
      androidAdvConfiguration: map['androidAdvConfiguration'] != null
          ? AndroidAdvConfiguration.fromMap(map['androidAdvConfiguration'])
          : null,
    );
  }
}