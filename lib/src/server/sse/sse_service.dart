import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/position.dart';

/// Service that connects to an SSE endpoint via POST and emits parsed events.
class SseService {
  final String url;
  final String token;
  final Map<String, dynamic> body;

  HttpClient? _httpClient;
  final StreamController<Map<String, List<MapPositionModel>>> _controller =
      StreamController.broadcast();

  SseService({
    required this.url,
    required this.token,
    required this.body,
  }) {
    _connect();
  }

  /// Stream of parsed SSE position data, keyed by tagId.
  Stream<Map<String, List<MapPositionModel>>> get stream => _controller.stream;

  Future<void> _connect() async {
    try {
      _httpClient = HttpClient();
      final uri = Uri.parse(url);
      final request = await _httpClient!.openUrl('POST', uri);

      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');

      request.add(utf8.encode(jsonEncode(body)));
      final response = await request.close();

      if (response.statusCode != 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        _controller.addError(Exception(
            'SSE connection failed (${response.statusCode}): $responseBody'));
        return;
      }

      final lineStream =
          response.transform(utf8.decoder).transform(const LineSplitter());

      String dataBuffer = '';

      await for (final line in lineStream) {
        if (_controller.isClosed) break;
        if (line.startsWith('data:')) {
          dataBuffer += line.substring(5).trim();
        } else if (line.isEmpty && dataBuffer.isNotEmpty) {
          // Empty line = end of event
          try {
            final decoded = jsonDecode(dataBuffer);
            // The server sends an array of {tagId: [positions]} objects.
            // Merge them into a single Map<String, List<MapPositionModel>>.
            final result = <String, List<MapPositionModel>>{};
            final list = decoded is List ? decoded : [decoded];
            for (final entry in list) {
              final map = entry as Map<String, dynamic>;
              for (final tagId in map.keys) {
                final positions = (map[tagId] as List)
                    .map((e) =>
                        MapPositionModel.fromJson(e as Map<String, dynamic>))
                    .toList();
                result[tagId] = positions;
              }
            }
            _controller.add(result);
          } catch (_) {
            // Skip non-JSON data lines
          }
          dataBuffer = '';
        }
      }
    } catch (e) {
      if (!_controller.isClosed) {
        _controller.addError(e);
      }
    }
  }

  void dispose() {
    _httpClient?.close(force: true);
    _httpClient = null;
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
