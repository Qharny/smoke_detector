class GasReading {
  final int id;
  final double level;
  final DateTime timestamp;

  GasReading({required this.id, required this.level, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': level,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GasReading.fromMap(Map<String, dynamic> map) {
    return GasReading(
      id: map['id'],
      level: map['level'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}