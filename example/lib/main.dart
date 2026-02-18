import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bluegps_sdk/flutter_bluegps_sdk.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueGPS SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late final BlueGpsSdk _sdk;

  String _status = 'Not initialized';
  String? _error;
  final List<String> _logs = [];
  StreamSubscription<Map<String, List<MapPositionModel>>>? _positionSub;
  StreamSubscription<BlueGpsEvent>? _eventSub;
  BlueGpsBluetoothState _bluetoothState = BlueGpsBluetoothState.unknown;
  bool _isAdvertising = false;

  @override
  void initState() {
    super.initState();

    final client = BlueGpsHttpClient(
      config: const BlueGpsServerConfig(
        baseUrl: 'https://demo.bluegps.cloud',
        keycloakUrl: 'https://demo.bluegps.cloud/auth',
        keycloakRealm: 'bluegps',
        clientId: 'guest-client',
        clientSecret: 'iLm5Hlkv6AYIwImwTqigna75unRxsWr0',
      ),
      httpClient: http.Client(),
    );

    _sdk = BlueGpsSdk(serverClient: client);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _positionSub?.cancel();
    _sdk.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    final timestamp =
        DateTime.now().toIso8601String().substring(11, 23); // HH:mm:ss.SSS
    final entry = '[$timestamp] $message';
    developer.log(entry, name: 'BlueGPS');
    setState(() {
      _logs.insert(0, entry);
      if (_logs.length > 100) _logs.removeLast();
    });
  }

  void _startEventStream() {
    _eventSub?.cancel();
    _eventSub = _sdk.eventStream.listen((event) {
      switch (event) {
        case BlueGpsStateUpdate e:
          _addLog(
              'BT: ${e.bluetoothState}, advertising: ${e.isAdvertising}${e.error != null ? ', ERROR: ${e.error}' : ''}');
          setState(() {
            _bluetoothState = e.bluetoothState;
            _isAdvertising = e.isAdvertising;
          });
        case BlueGpsBluetoothStateChanged e:
          _addLog('BT state changed: ${e.state}, ready: ${e.isReady}');
          setState(() {
            _bluetoothState = e.state;
          });
        case BlueGpsError e:
          _addLog('ERROR: ${e.message}');
          setState(() {
            _error = e.message;
            _bluetoothState = BlueGpsBluetoothState.unknown;
          });
      }
    });
  }

  Future<void> _initialize() async {
    setState(() {
      _status = 'Initializing...';
      _error = null;
    });

    // Subscribe to events before init so we catch the initial STARTED event
    _startEventStream();

    try {
      _addLog('Starting SDK init...');

      await _sdk.init(
        appId: Platform.isAndroid ? 'flutter-sdk-android' : 'flutter-sdk-ios',
        uuid: Platform.isAndroid
            ? 'flutter-device-android'
            : 'flutter-device-ios',
      );

      final config = _sdk.deviceConfig;
      _addLog('Login OK');
      _addLog('Device config: appId=${config?.appId}, uuid=${config?.uuid}');

      if (Platform.isAndroid && config?.androidAdvConf != null) {
        final adv = config!.androidAdvConf!;
        _addLog(
            'Android adv config: tagid=${adv.tagid}, mode=${adv.advModes}, txPower=${adv.advTxPowers}');
      } else if (config?.iOSAdvConf != null) {
        final adv = config!.iOSAdvConf!;
        _addLog(
            'iOS adv config: tagid=${adv.tagid}, byte1=${adv.byte1}, byte2=${adv.byte2}');
      }

      final btState = await _sdk.getBluetoothState();
      setState(() {
        _status = 'Initialized';
        _isAdvertising = true;
        _bluetoothState = btState;
      });
      _addLog('Quuppa advertising started');
    } catch (e) {
      _addLog('ERROR: $e');

      // BT off: SDK still initialized (config fetched), listen for BT restart
      if (_sdk.deviceConfig != null && _sdk.lastAdvertisingConfig != null) {
        setState(() {
          _status = 'Waiting for Bluetooth';
          _error = e.toString();
        });
      } else {
        setState(() {
          _status = 'Error';
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _stopAdvertising() async {
    try {
      await _sdk.stopAdvertising();
      _addLog('Advertising stopped');
      setState(() => _isAdvertising = false);
    } catch (e) {
      _addLog('ERROR stopping: $e');
    }
  }

  Future<void> _startAdvertising() async {
    final config = _sdk.lastAdvertisingConfig;
    if (config == null) return;
    try {
      await _sdk.startAdvertising(config);
      _addLog('Advertising restarted');
      setState(() => _isAdvertising = true);
    } catch (e) {
      _addLog('ERROR starting: $e');
    }
  }

  Future<void> _startPositionStream() async {
    _positionSub?.cancel();
    _addLog('Opening SSE position stream...');

    try {
      final stream = await _sdk.positionStream(
        SsePositionRequest(
          filter: SsePositionFilter(
            tagIdList: _resolveTagIds(),
          ),
        ),
      );
      _positionSub = stream.listen(
        (data) {
          _addLog('Position: $data');
        },
        onError: (error) {
          _addLog('SSE error: $error');
        },
        onDone: () {
          _addLog('SSE stream closed');
        },
      );
      setState(() => _status = 'Streaming positions');
    } catch (e) {
      _addLog('ERROR: $e');
    }
  }

  void _stopPositionStream() {
    _positionSub?.cancel();
    _positionSub = null;
    _sdk.stopPositionStream();
    _addLog('Position stream stopped');
    setState(() => _status = 'Stream stopped');
  }

  Color _bluetoothStateColor() {
    return switch (_bluetoothState) {
      BlueGpsBluetoothState.poweredOn => Colors.green,
      BlueGpsBluetoothState.poweredOff => Colors.red,
      BlueGpsBluetoothState.unauthorized => Colors.orange,
      BlueGpsBluetoothState.unsupported => Colors.grey,
      BlueGpsBluetoothState.resetting => Colors.orange,
      BlueGpsBluetoothState.unknown => Colors.grey,
    };
  }

  List<String> _resolveTagIds() {
    final config = _sdk.deviceConfig;
    if (config == null) return [];
    if (Platform.isAndroid) {
      return config.androidAdvConf != null
          ? [config.androidAdvConf!.tagid]
          : [];
    }
    final iosConf = config.iOSAdvConf;
    return iosConf != null ? [iosConf.tagid] : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BlueGPS SDK Demo')),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: _error != null ? Colors.red.shade50 : Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: $_status',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_error != null)
                  Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
          ),

          // Bluetooth & advertising status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.bluetooth, size: 18, color: _bluetoothStateColor()),
                const SizedBox(width: 4),
                Text(
                  'BT: ${_bluetoothState.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _bluetoothStateColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  _isAdvertising
                      ? Icons.cell_tower
                      : Icons.stop_circle_outlined,
                  size: 18,
                  color: _isAdvertising ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _isAdvertising ? 'Advertising' : 'Not advertising',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isAdvertising ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _sdk.deviceConfig == null ? _initialize : null,
                  child: const Text('Init SDK'),
                ),
                ElevatedButton(
                  onPressed: _sdk.deviceConfig != null && !_isAdvertising
                      ? _startAdvertising
                      : null,
                  child: const Text('Start Adv'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                  onPressed: _isAdvertising ? _stopAdvertising : null,
                  child: const Text('Stop Adv'),
                ),
                ElevatedButton(
                  onPressed: _isAdvertising &&
                          _resolveTagIds().isNotEmpty &&
                          _positionSub == null
                      ? _startPositionStream
                      : null,
                  child: const Text('Start SSE'),
                ),
                ElevatedButton(
                  onPressed: _positionSub != null ? _stopPositionStream : null,
                  child: const Text('Stop SSE'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Log header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Logs (${_logs.length})',
                    style: Theme.of(context).textTheme.titleSmall),
                TextButton(
                  onPressed: () => setState(() => _logs.clear()),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

          // Log list
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    _logs[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: _logs[index].contains('ERROR')
                          ? Colors.red
                          : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
