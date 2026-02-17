/// Android BLE advertising mode.
enum AdvModes {
  lowPower,
  balanced,
  lowLatency;

  static const _jsonMap = {
    'ADVERTISE_MODE_LOW_POWER': AdvModes.lowPower,
    'ADVERTISE_MODE_BALANCED': AdvModes.balanced,
    'ADVERTISE_MODE_LOW_LATENCY': AdvModes.lowLatency,
  };

  static AdvModes? fromJson(String? value) => _jsonMap[value];

  String toJson() => _jsonMap.entries.firstWhere((e) => e.value == this).key;
}

/// Android BLE advertising TX power level.
enum AdvTxPowers {
  ultraLow,
  low,
  medium,
  high;

  static const _jsonMap = {
    'ADVERTISE_TX_POWER_ULTRA_LOW': AdvTxPowers.ultraLow,
    'ADVERTISE_TX_POWER_LOW': AdvTxPowers.low,
    'ADVERTISE_TX_POWER_MEDIUM': AdvTxPowers.medium,
    'ADVERTISE_TX_POWER_HIGH': AdvTxPowers.high,
  };

  static AdvTxPowers? fromJson(String? value) => _jsonMap[value];

  String toJson() => _jsonMap.entries.firstWhere((e) => e.value == this).key;
}

/// Android advertising configuration from the server.
class AndroidAdvertisingConf {
  final String tagid;
  final AdvModes? advModes;
  final AdvTxPowers? advTxPowers;

  const AndroidAdvertisingConf({
    required this.tagid,
    this.advModes,
    this.advTxPowers,
  });

  factory AndroidAdvertisingConf.fromJson(Map<String, dynamic> json) {
    return AndroidAdvertisingConf(
      tagid: json['tagid'] as String,
      advModes: AdvModes.fromJson(json['advModes'] as String?),
      advTxPowers: AdvTxPowers.fromJson(json['advTxPowers'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagid': tagid,
      if (advModes != null) 'advModes': advModes!.toJson(),
      if (advTxPowers != null) 'advTxPowers': advTxPowers!.toJson(),
    };
  }
}

/// iOS advertising configuration from the server.
class IosAdvertisingConf {
  final String tagid;
  final int byte1;
  final int byte2;
  final double? tOn;
  final double? tOff;

  const IosAdvertisingConf({
    required this.tagid,
    required this.byte1,
    required this.byte2,
    this.tOn,
    this.tOff,
  });

  factory IosAdvertisingConf.fromJson(Map<String, dynamic> json) {
    return IosAdvertisingConf(
      tagid: json['tagid'] as String,
      byte1: (json['byte1'] as num).toInt(),
      byte2: (json['byte2'] as num).toInt(),
      tOn: (json['tOn'] as num?)?.toDouble(),
      tOff: (json['tOff'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagid': tagid,
      'byte1': byte1,
      'byte2': byte2,
      if (tOn != null) 'tOn': tOn,
      if (tOff != null) 'tOff': tOff,
    };
  }
}

/// Device configuration returned by the server.
class DeviceConfiguration {
  final String? appId;
  final String? uuid;
  final String? pushToken;
  final String? nfcToken;
  final IosAdvertisingConf? iOSAdvConf;
  final AndroidAdvertisingConf? androidAdvConf;

  const DeviceConfiguration({
    this.appId,
    this.uuid,
    this.pushToken,
    this.nfcToken,
    this.iOSAdvConf,
    this.androidAdvConf,
  });

  factory DeviceConfiguration.fromJson(Map<String, dynamic> json) {
    return DeviceConfiguration(
      appId: json['appId'] as String?,
      uuid: json['uuid'] as String?,
      pushToken: json['pushToken'] as String?,
      nfcToken: json['nfcToken'] as String?,
      iOSAdvConf: json['iosadvConf'] != null
          ? IosAdvertisingConf.fromJson(
              json['iosadvConf'] as Map<String, dynamic>)
          : null,
      androidAdvConf: json['androidAdvConf'] != null
          ? AndroidAdvertisingConf.fromJson(
              json['androidAdvConf'] as Map<String, dynamic>)
          : null,
    );
  }
}
