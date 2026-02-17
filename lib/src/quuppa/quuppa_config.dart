import '../models/ble_frequency.dart';
import '../server/models/device_config.dart';

/// Base configuration for Quuppa beacon advertising.
sealed class QuuppaAdvertisingConfig {
  /// Tag identifier.
  String get tagId;

  const QuuppaAdvertisingConfig();
}

/// iOS-specific Quuppa advertising configuration.
class IosQuuppaAdvertisingConfig extends QuuppaAdvertisingConfig {
  @override
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

  const IosQuuppaAdvertisingConfig({
    required this.tagId,
    required this.byte1,
    required this.byte2,
    this.tOn,
    this.tOff,
    this.frequency,
  });

  /// Create from server iOS advertising configuration.
  factory IosQuuppaAdvertisingConfig.fromServerConf(IosAdvertisingConf conf) {
    return IosQuuppaAdvertisingConfig(
      tagId: conf.tagid,
      byte1: conf.byte1,
      byte2: conf.byte2,
      tOn: conf.tOn,
      tOff: conf.tOff,
    );
  }
}

/// Android-specific Quuppa advertising configuration.
class AndroidQuuppaAdvertisingConfig extends QuuppaAdvertisingConfig {
  @override
  final String tagId;

  /// BLE advertising mode.
  final AdvModes? advModes;

  /// BLE advertising TX power level.
  final AdvTxPowers? advTxPowers;

  const AndroidQuuppaAdvertisingConfig({
    required this.tagId,
    this.advModes,
    this.advTxPowers,
  });

  /// Create from server Android advertising configuration.
  factory AndroidQuuppaAdvertisingConfig.fromServerConf(
      AndroidAdvertisingConf conf) {
    return AndroidQuuppaAdvertisingConfig(
      tagId: conf.tagid,
      advModes: conf.advModes,
      advTxPowers: conf.advTxPowers,
    );
  }
}
