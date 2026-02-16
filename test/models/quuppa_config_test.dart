import 'package:flutter_bluegps_sdk/flutter_bluegps_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuuppaAdvertisingConfig', () {
    test('creates with required parameters', () {
      const config = QuuppaAdvertisingConfig(
        tagId: '000000000001',
        byte1: 0x00,
        byte2: 0x01,
      );

      expect(config.tagId, '000000000001');
      expect(config.byte1, 0);
      expect(config.byte2, 1);
      expect(config.tOn, isNull);
      expect(config.tOff, isNull);
      expect(config.frequency, isNull);
    });

    test('creates with all parameters', () {
      const config = QuuppaAdvertisingConfig(
        tagId: 'AABBCCDDEEFF',
        byte1: 255,
        byte2: 128,
        tOn: 0.5,
        tOff: 1.0,
        frequency: BlueGpsBleFrequency.high,
      );

      expect(config.tagId, 'AABBCCDDEEFF');
      expect(config.byte1, 255);
      expect(config.byte2, 128);
      expect(config.tOn, 0.5);
      expect(config.tOff, 1.0);
      expect(config.frequency, BlueGpsBleFrequency.high);
    });

    test('fromIosConf maps all fields', () {
      const iosConf = IosAdvertisingConf(
        tagid: '000000000001',
        byte1: 0,
        byte2: 1,
        tOn: 1.5,
        tOff: 2.0,
      );

      final config = QuuppaAdvertisingConfig.fromIosConf(iosConf);

      expect(config.tagId, '000000000001');
      expect(config.byte1, 0);
      expect(config.byte2, 1);
      expect(config.tOn, 1.5);
      expect(config.tOff, 2.0);
      expect(config.frequency, isNull);
    });
  });
}
