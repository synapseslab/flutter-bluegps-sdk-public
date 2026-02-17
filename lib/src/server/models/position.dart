/// A position on a map as reported by the BlueGPS SSE stream.
class MapPositionModel {
  final int mapId;
  final String? tagid;
  final int? roomId;
  final int? areaId;
  final double x;
  final double y;
  final int? level;
  final String? data;

  const MapPositionModel({
    required this.mapId,
    this.tagid,
    this.roomId,
    this.areaId,
    required this.x,
    required this.y,
    this.level,
    this.data,
  });

  factory MapPositionModel.fromJson(Map<String, dynamic> json) {
    return MapPositionModel(
      mapId: json['mapId'] as int,
      tagid: json['tagid'] as String?,
      roomId: json['roomId'] as int?,
      areaId: json['areaId'] as int?,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      level: json['level'] as int?,
      data: json['data'] as String?,
    );
  }

  @override
  String toString() =>
      'MapPositionModel(tagid: $tagid, x: $x, y: $y, mapId: $mapId)';
}
