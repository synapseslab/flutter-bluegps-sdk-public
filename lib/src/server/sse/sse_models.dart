/// Tag position type for SSE filtering.
enum TagPositionType {
  all,
  physical,
  emulated;

  String toJson() => name.toUpperCase();
}

/// Filter for SSE position stream.
class SsePositionFilter {
  final List<int> mapIdList;
  final List<String> tagIdList;
  final TagPositionType tagType;

  const SsePositionFilter({
    this.mapIdList = const [],
    this.tagIdList = const [],
    this.tagType = TagPositionType.all,
  });

  Map<String, dynamic> toJson() => {
        'mapIdList': mapIdList,
        'tagIdList': tagIdList,
        'tagType': tagType.toJson(),
      };
}

/// Update parameters for SSE position stream.
class SsePositionUpdate {
  final double? minMovement;
  final int? minMovementTimeout;
  final int? checkTimeout;
  final int? refresh;
  final int? timeout;

  const SsePositionUpdate({
    this.minMovement,
    this.minMovementTimeout,
    this.checkTimeout,
    this.refresh,
    this.timeout,
  });

  Map<String, dynamic> toJson() => {
        if (minMovement != null) 'minMovement': minMovement,
        if (minMovementTimeout != null)
          'minMovementTimeout': minMovementTimeout,
        if (checkTimeout != null) 'checkTimeout': checkTimeout,
        if (refresh != null) 'refresh': refresh,
        if (timeout != null) 'timeout': timeout,
      };
}

/// Request body for the SSE position stream endpoint.
class SsePositionRequest {
  final SsePositionFilter filter;
  final SsePositionUpdate update;
  final bool debug;

  const SsePositionRequest({
    this.filter = const SsePositionFilter(),
    this.update = const SsePositionUpdate(),
    this.debug = false,
  });

  Map<String, dynamic> toJson() => {
        'filter': filter.toJson(),
        'update': update.toJson(),
        'debug': debug,
      };
}
