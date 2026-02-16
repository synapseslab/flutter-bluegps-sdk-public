import 'package:flutter/material.dart';
import 'package:flutter_bluegps_sdk/flutter_bluegps_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Position? _currentPosition;
  bool _isPositioning = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await FlutterBluegpsSdk.getPlatformVersion() ?? 'Unknown platform version';
    } catch (e) {
      platformVersion = 'Failed to get platform version: $e';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _initializeSdk() async {
    try {
      final config = BluegpsConfig(
        apiKey: 'your_api_key_here',
        serverUrl: 'https://your-server-url.com',
        debugEnabled: true,
      );
      await FlutterBluegpsSdk.initialize(config);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SDK initialized successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize SDK: $e')),
      );
    }
  }

  Future<void> _startPositioning() async {
    try {
      await FlutterBluegpsSdk.startPositioning();
      setState(() {
        _isPositioning = true;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Positioning started')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start positioning: $e')),
      );
    }
  }

  Future<void> _stopPositioning() async {
    try {
      await FlutterBluegpsSdk.stopPositioning();
      setState(() {
        _isPositioning = false;
        _currentPosition = null;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Positioning stopped')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop positioning: $e')),
      );
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      final position = await FlutterBluegpsSdk.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get position: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BlueGPS SDK Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Running on: $_platformVersion\n'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeSdk,
                child: const Text('Initialize SDK'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isPositioning ? null : _startPositioning,
                child: const Text('Start Positioning'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isPositioning ? _stopPositioning : null,
                child: const Text('Stop Positioning'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isPositioning ? _getCurrentPosition : null,
                child: const Text('Get Current Position'),
              ),
              const SizedBox(height: 20),
              if (_currentPosition != null) ...[
                const Text('Current Position:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('X: ${_currentPosition!.x}'),
                Text('Y: ${_currentPosition!.y}'),
                Text('Floor: ${_currentPosition!.floor}'),
                Text('Accuracy: ${_currentPosition!.accuracy}m'),
                Text('Timestamp: ${_currentPosition!.timestamp}'),
              ] else if (_isPositioning) ...[
                const Text('Positioning started. Tap "Get Current Position" to fetch location.'),
              ] else ...[
                const Text('Not positioning'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
