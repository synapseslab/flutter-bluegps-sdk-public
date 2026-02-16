import 'package:flutter_bluegps_sdk/flutter_bluegps_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlueGpsSdk', () {
    test('creates without server client', () {
      final sdk = BlueGpsSdk();

      expect(sdk.server, isNull);
      expect(sdk.quuppa, isA<QuuppaService>());
    });

    test('dispose does not throw without server client', () {
      final sdk = BlueGpsSdk();

      expect(() => sdk.dispose(), returnsNormally);
    });

    test('init throws without server client', () {
      final sdk = BlueGpsSdk();

      expect(
          () => sdk.init(
                appId: 'test-app',
                uuid: 'test-uuid',
              ),
          throwsA(isA<BlueGpsSdkException>()));
    });

    test('positionStream throws without server client', () {
      final sdk = BlueGpsSdk();

      expect(() => sdk.positionStream(), throwsA(isA<BlueGpsSdkException>()));
    });
  });

  group('BlueGpsSdkException', () {
    test('BlueGpsSdkException toString', () {
      final e = BlueGpsSdkException('test error');
      expect(e.toString(), 'BlueGpsSdkException: test error');
      expect(e.message, 'test error');
      expect(e.cause, isNull);
    });

    test('QuuppaException toString', () {
      final cause = Exception('underlying');
      final e = QuuppaException('quuppa failed', cause: cause);
      expect(e.toString(), 'QuuppaException: quuppa failed');
      expect(e.cause, cause);
      expect(e, isA<BlueGpsSdkException>());
    });

    test('BlueGpsServerException toString', () {
      final e = BlueGpsServerException('not found', statusCode: 404);
      expect(e.toString(), 'BlueGpsServerException(404): not found');
      expect(e.statusCode, 404);
      expect(e, isA<BlueGpsSdkException>());
    });
  });

  group('Server models', () {
    test('BlueGpsServerConfig with required fields', () {
      const config = BlueGpsServerConfig(
        baseUrl: 'https://api.example.com',
        keycloakUrl: 'https://keycloak.example.com',
        clientId: 'test-client',
        clientSecret: 'test-secret',
      );
      expect(config.baseUrl, 'https://api.example.com');
      expect(config.keycloakUrl, 'https://keycloak.example.com');
      expect(config.keycloakRealm, 'bluegps');
      expect(config.clientId, 'test-client');
      expect(config.clientSecret, 'test-secret');
      expect(config.timeoutMs, 30000);
    });

    test('BlueGpsServerConfig tokenEndpoint', () {
      const config = BlueGpsServerConfig(
        baseUrl: 'https://api.example.com',
        keycloakUrl: 'https://keycloak.example.com',
        keycloakRealm: 'myrealm',
        clientId: 'c',
        clientSecret: 's',
      );
      expect(
        config.tokenEndpoint,
        'https://keycloak.example.com/realms/myrealm/protocol/openid-connect/token',
      );
    });

    test('BlueGpsAuthToken isExpired', () {
      final expired = BlueGpsAuthToken(
        accessToken: 'token',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(expired.isExpired, true);

      final valid = BlueGpsAuthToken(
        accessToken: 'token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(valid.isExpired, false);

      const noExpiry = BlueGpsAuthToken(accessToken: 'token');
      expect(noExpiry.isExpired, false);
    });

    test('BlueGpsAuthToken.fromJson', () {
      final token = BlueGpsAuthToken.fromJson({
        'access_token': 'abc123',
        'refresh_token': 'ref456',
        'expires_in': 300,
      });
      expect(token.accessToken, 'abc123');
      expect(token.refreshToken, 'ref456');
      expect(token.isExpired, false);
    });

    test('BlueGpsPosition', () {
      final now = DateTime.now();
      final pos = BlueGpsPosition(
        x: 10.5,
        y: 20.3,
        z: 1.0,
        floorId: 'floor-1',
        timestamp: now,
        accuracy: 2.5,
      );
      expect(pos.x, 10.5);
      expect(pos.y, 20.3);
      expect(pos.z, 1.0);
      expect(pos.floorId, 'floor-1');
      expect(pos.timestamp, now);
      expect(pos.accuracy, 2.5);
    });

    test('BlueGpsApiResponse.success', () {
      final resp = BlueGpsApiResponse.success('data');
      expect(resp.success, true);
      expect(resp.data, 'data');
      expect(resp.errorMessage, isNull);
    });

    test('BlueGpsApiResponse.error', () {
      final resp = BlueGpsApiResponse<String>.error('fail', statusCode: 500);
      expect(resp.success, false);
      expect(resp.data, isNull);
      expect(resp.errorMessage, 'fail');
      expect(resp.statusCode, 500);
    });
  });

  group('DeviceConfiguration', () {
    test('fromJson parses full response', () {
      final config = DeviceConfiguration.fromJson({
        'appId': 'app1',
        'uuid': 'uuid1',
        'pushToken': 'push1',
        'nfcToken': 'nfc1',
        'iOSAdvConf': {
          'tagid': '000000000001',
          'byte1': 0,
          'byte2': 1,
          'tOn': 1.0,
          'tOff': 1.0,
        },
      });
      expect(config.appId, 'app1');
      expect(config.uuid, 'uuid1');
      expect(config.iOSAdvConf, isNotNull);
      expect(config.iOSAdvConf!.tagid, '000000000001');
      expect(config.iOSAdvConf!.byte1, 0);
      expect(config.iOSAdvConf!.byte2, 1);
    });

    test('fromJson handles missing iOSAdvConf', () {
      final config = DeviceConfiguration.fromJson({
        'appId': 'app1',
      });
      expect(config.appId, 'app1');
      expect(config.iOSAdvConf, isNull);
    });
  });

  group('SSE models', () {
    test('SsePositionRequest toJson', () {
      const req = SsePositionRequest(
        filter: SsePositionFilter(
          tagIdList: ['tag1'],
          tagType: TagPositionType.physical,
        ),
        update: SsePositionUpdate(refresh: 1000),
        debug: true,
      );
      final json = req.toJson();
      expect(json['debug'], true);
      expect((json['filter'] as Map)['tagIdList'], ['tag1']);
      expect((json['filter'] as Map)['tagType'], 'PHYSICAL');
      expect((json['update'] as Map)['refresh'], 1000);
    });

    test('SsePositionRequest defaults', () {
      const req = SsePositionRequest();
      final json = req.toJson();
      expect(json['debug'], false);
      expect((json['filter'] as Map)['tagType'], 'ALL');
    });

    test('TagPositionType toJson', () {
      expect(TagPositionType.all.toJson(), 'ALL');
      expect(TagPositionType.physical.toJson(), 'PHYSICAL');
      expect(TagPositionType.emulated.toJson(), 'EMULATED');
    });
  });
}
