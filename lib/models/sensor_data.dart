class SensorData {
  final String id;
  final double temperature; // Celsius
  final double oxygen; // mg/L atau %
  final double phLevel; // pH level (6-9 normal range)
  final DateTime timestamp;
  final String pondId;
  final String deviceId;
  final String location;

  SensorData({
    required this.id,
    required this.temperature,
    required this.oxygen,
    required this.phLevel,
    required this.timestamp,
    required this.pondId,
    required this.deviceId,
    required this.location,
  });

  // Convert from Firestore document
  factory SensorData.fromMap(Map<String, dynamic> map, String id) {
    return SensorData(
      id: id,
      temperature: map['temperature']?.toDouble() ?? 0.0,
      oxygen: map['oxygen']?.toDouble() ?? 0.0,
      phLevel: map['phLevel']?.toDouble() ?? 7.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      pondId: map['pondId'] ?? '',
      deviceId: map['deviceId'] ?? '',
      location: map['location'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'oxygen': oxygen,
      'phLevel': phLevel,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'pondId': pondId,
      'deviceId': deviceId,
      'location': location,
    };
  }

  // Check if values are in normal range for fish pond
  bool get isTemperatureNormal => temperature >= 20.0 && temperature <= 30.0;
  bool get isOxygenNormal => oxygen >= 5.0; // mg/L minimum for fish
  bool get isPhNormal => phLevel >= 6.5 && phLevel <= 8.5;
  
  bool get isAllNormal => isTemperatureNormal && isOxygenNormal && isPhNormal;

  // Get status color for UI
  String get temperatureStatus {
    if (temperature < 20) return 'cold';
    if (temperature > 30) return 'hot';
    return 'normal';
  }

  String get oxygenStatus {
    if (oxygen < 3) return 'critical';
    if (oxygen < 5) return 'low';
    return 'normal';
  }

  String get phStatus {
    if (phLevel < 6.5) return 'acidic';
    if (phLevel > 8.5) return 'alkaline';
    return 'normal';
  }
}