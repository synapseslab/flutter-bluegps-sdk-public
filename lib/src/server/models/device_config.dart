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

  const DeviceConfiguration({
    this.appId,
    this.uuid,
    this.pushToken,
    this.nfcToken,
    this.iOSAdvConf,
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
    );
  }
}
