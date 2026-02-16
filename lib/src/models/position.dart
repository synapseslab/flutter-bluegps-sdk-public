/// Represents a position in the BlueGPS system.
class Position {
  /// X coordinate
  final double x;

  /// Y coordinate
  final double y;

  /// Floor/level identifier
  final int? floor;

  /// Timestamp when the position was recorded
  final DateTime timestamp;

  /// Accuracy of the position in meters
  final double? accuracy;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  Position({
    required this.x,
    required this.y,
    this.floor,
    required this.timestamp,
    this.accuracy,
    this.metadata,
  });

  /// Creates a Position from a map.
  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      floor: map['floor'] as int?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      accuracy: map['accuracy'] != null ? (map['accuracy'] as num).toDouble() : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  /// Converts the Position to a map.
  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'floor': floor,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'accuracy': accuracy,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'Position(x: $x, y: $y, floor: $floor, timestamp: $timestamp, accuracy: $accuracy)';
  }
}
