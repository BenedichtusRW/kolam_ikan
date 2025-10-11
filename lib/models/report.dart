import 'package:flutter/foundation.dart';

class Report {
  final String? id;
  final String userId;
  final String? userName;
  final String pondId;
  final DateTime timestamp;
  final double temperature;
  final double ph;
  final double oxygen;
  final String? note;

  Report({
    this.id,
    required this.userId,
    this.userName,
    required this.pondId,
    required this.timestamp,
    required this.temperature,
    required this.ph,
    required this.oxygen,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName ?? '',
      'pondId': pondId,
      'timestamp': timestamp.toUtc(),
      'temperature': temperature,
      'ph': ph,
      'oxygen': oxygen,
      'note': note ?? '',
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, {String? id}) {
    return Report(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      pondId: map['pondId'] as String? ?? '',
      timestamp: (map['timestamp'] is DateTime)
          ? map['timestamp'] as DateTime
          : DateTime.parse(
              (map['timestamp']?.toDate() ?? DateTime.now()).toString(),
            ),
      temperature: (map['temperature'] is num)
          ? (map['temperature'] as num).toDouble()
          : double.tryParse('${map['temperature']}') ?? 0.0,
      ph: (map['ph'] is num)
          ? (map['ph'] as num).toDouble()
          : double.tryParse('${map['ph']}') ?? 0.0,
      oxygen: (map['oxygen'] is num)
          ? (map['oxygen'] as num).toDouble()
          : double.tryParse('${map['oxygen']}') ?? 0.0,
      note: map['note'] as String? ?? '',
    );
  }
}
