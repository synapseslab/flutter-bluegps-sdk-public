import 'dart:async';
import 'dart:developer' as developer;

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
  StreamSubscription<Map<String, dynamic>>? _positionSub;

  @override
  void initState() {
    super.initState();

    final client = BlueGpsHttpClient(
      config: const BlueGpsServerConfig(
        baseUrl: 'http://<HOST>:<PORT>',
        keycloakUrl: 'http://<HOST>:<PORT>',
        keycloakRealm: '<REALM>',
        clientId: '<CLIENT_ID>',
        clientSecret: '<CLIENT_SECRET>',
      ),
      httpClient: http.Client(),
    );

    _sdk = BlueGpsSdk(serverClient: client);
  }

  @override
  void dispose() {
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

  Future<void> _initialize() async {
    setState(() {
      _status = 'Initializing...';
      _error = null;
    });

    try {
      _addLog('Starting SDK init...');

      await _sdk.init(
        appId: 'flutter-sdk',
        uuid: 'flutter-device',
      );

      final config = _sdk.deviceConfig;
      _addLog('Login OK');
      _addLog('Device config: appId=${config?.appId}, uuid=${config?.uuid}');
      if (config?.iOSAdvConf != null) {
        final adv = config!.iOSAdvConf!;
        _addLog(
            'Advertising config: tagid=${adv.tagid}, byte1=${adv.byte1}, byte2=${adv.byte2}');
      }

      setState(() => _status = 'Initialized - Advertising started');
      _addLog('Quuppa advertising started');
    } catch (e) {
      _addLog('ERROR: $e');
      setState(() {
        _status = 'Error';
        _error = e.toString();
      });
    }
  }

  void _startPositionStream() {
    _positionSub?.cancel();
    _addLog('Opening SSE position stream...');

    _positionSub = _sdk
        .positionStream(
      SsePositionRequest(
          filter: SsePositionFilter(
        tagIdList: [_sdk.deviceConfig?.iOSAdvConf?.tagid ?? 'unknown-tag'],
        tagType: TagPositionType.physical,
      )),
    )
        .listen(
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
  }

  void _stopPositionStream() {
    _positionSub?.cancel();
    _positionSub = null;
    _addLog('Position stream stopped');
    setState(() => _status = 'Stream stopped');
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

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed:
                      _sdk.deviceConfig == null || _status.contains('Error')
                          ? _initialize
                          : null,
                  child: const Text('Init SDK'),
                ),
                ElevatedButton(
                  onPressed: _sdk.deviceConfig?.iOSAdvConf != null &&
                          !_status.contains('Error') &&
                          _positionSub == null &&
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
