import 'package:flutter_bluegps_sdk/flutter_bluegps_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IosQuuppaAdvertisingConfig', () {
    test('creates with required parameters', () {
      const config = IosQuuppaAdvertisingConfig(
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
      expect(config, isA<QuuppaAdvertisingConfig>());
    });

    test('creates with all parameters', () {
      const config = IosQuuppaAdvertisingConfig(
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

    test('fromServerConf maps all fields', () {
      const iosConf = IosAdvertisingConf(
        tagid: '000000000001',
        byte1: 0,
        byte2: 1,
        tOn: 1.5,
        tOff: 2.0,
      );

      final config = IosQuuppaAdvertisingConfig.fromServerConf(iosConf);

      expect(config.tagId, '000000000001');
      expect(config.byte1, 0);
      expect(config.byte2, 1);
      expect(config.tOn, 1.5);
      expect(config.tOff, 2.0);
      expect(config.frequency, isNull);
    });
  });

  group('AndroidQuuppaAdvertisingConfig', () {
    test('creates with required parameters', () {
      const config = AndroidQuuppaAdvertisingConfig(tagId: 'A0BB00000001');

      expect(config.tagId, 'A0BB00000001');
      expect(config.advModes, isNull);
      expect(config.advTxPowers, isNull);
      expect(config, isA<QuuppaAdvertisingConfig>());
    });

    test('creates with all parameters', () {
      const config = AndroidQuuppaAdvertisingConfig(
        tagId: 'A0BB00000001',
        advModes: AdvModes.lowLatency,
        advTxPowers: AdvTxPowers.high,
      );

      expect(config.tagId, 'A0BB00000001');
      expect(config.advModes, AdvModes.lowLatency);
      expect(config.advTxPowers, AdvTxPowers.high);
    });

    test('fromServerConf maps all fields', () {
      const androidConf = AndroidAdvertisingConf(
        tagid: 'A0BB00000001',
        advModes: AdvModes.balanced,
        advTxPowers: AdvTxPowers.medium,
      );

      final config =
          AndroidQuuppaAdvertisingConfig.fromServerConf(androidConf);

      expect(config.tagId, 'A0BB00000001');
      expect(config.advModes, AdvModes.balanced);
      expect(config.advTxPowers, AdvTxPowers.medium);
    });
  });

  group('Sealed class exhaustiveness', () {
    test('pattern match covers all variants', () {
      const configs = <QuuppaAdvertisingConfig>[
        IosQuuppaAdvertisingConfig(
            tagId: 'ios1', byte1: 0, byte2: 1),
        AndroidQuuppaAdvertisingConfig(tagId: 'android1'),
      ];

      for (final config in configs) {
        final label = switch (config) {
          IosQuuppaAdvertisingConfig() => 'ios',
          AndroidQuuppaAdvertisingConfig() => 'android',
        };
        expect(label, isNotEmpty);
      }
    });
  });
}
