/// A geographic or indoor position as reported by BlueGPS.
class BlueGpsPosition {
  /// X coordinate (or longitude, depending on coordinate system).
  final double x;

  /// Y coordinate (or latitude, depending on coordinate system).
  final double y;

  /// Optional Z coordinate (floor/altitude).
  final double? z;

  /// Optional floor identifier.
  final String? floorId;

  /// Timestamp of the position reading.
  final DateTime timestamp;

  /// Accuracy in meters, if available.
  final double? accuracy;

  const BlueGpsPosition({
    required this.x,
    required this.y,
    this.z,
    this.floorId,
    required this.timestamp,
    this.accuracy,
  });
}
