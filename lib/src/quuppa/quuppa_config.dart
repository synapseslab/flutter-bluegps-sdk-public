import '../models/ble_frequency.dart';
import '../server/models/device_config.dart';

/// Configuration for Quuppa beacon advertising.
class QuuppaAdvertisingConfig {
  /// 12-character hexadecimal tag identifier.
  final String tagId;

  /// First configuration byte (0-255).
  final int byte1;

  /// Second configuration byte (0-255).
  final int byte2;

  /// Time ON in seconds. Ignored when [frequency] is set.
  final double? tOn;

  /// Time OFF in seconds. Ignored when [frequency] is set.
  final double? tOff;

  /// BLE frequency preset. When set, overrides [tOn]/[tOff].
  final BlueGpsBleFrequency? frequency;

  const QuuppaAdvertisingConfig({
    required this.tagId,
    required this.byte1,
    required this.byte2,
    this.tOn,
    this.tOff,
    this.frequency,
  });

  /// Create from server iOS advertising configuration.
  factory QuuppaAdvertisingConfig.fromIosConf(IosAdvertisingConf conf) {
    return QuuppaAdvertisingConfig(
      tagId: conf.tagid,
      byte1: conf.byte1,
      byte2: conf.byte2,
      tOn: conf.tOn,
      tOff: conf.tOff,
    );
  }
}
