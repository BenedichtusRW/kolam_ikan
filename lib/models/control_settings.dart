import 'package:flutter/material.dart';

class ControlSettings {
  final String id;
  final String pondId;
  final bool autoMode;
  final bool manualMode;
  
  // Temperature control
  final double targetTemperature;
  final double temperatureMin;
  final double temperatureMax;
  final bool heaterEnabled;
  final bool coolerEnabled;
  
  // Oxygen control
  final double targetOxygen;
  final double oxygenMin;
  final bool aeratorEnabled;
  
  // pH control
  final double targetPh;
  final double phMin;
  final double phMax;
  final bool phPumpEnabled;
  
  // Schedule control
  final List<ScheduleRule> scheduleRules;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId; // admin who created/modified

  ControlSettings({
    required this.id,
    required this.pondId,
    required this.autoMode,
    required this.manualMode,
    required this.targetTemperature,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.heaterEnabled,
    required this.coolerEnabled,
    required this.targetOxygen,
    required this.oxygenMin,
    required this.aeratorEnabled,
    required this.targetPh,
    required this.phMin,
    required this.phMax,
    required this.phPumpEnabled,
    required this.scheduleRules,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory ControlSettings.fromMap(Map<String, dynamic> map, String id) {
    return ControlSettings(
      id: id,
      pondId: map['pondId'] ?? '',
      autoMode: map['autoMode'] ?? false,
      manualMode: map['manualMode'] ?? true,
      targetTemperature: map['targetTemperature']?.toDouble() ?? 25.0,
      temperatureMin: map['temperatureMin']?.toDouble() ?? 20.0,
      temperatureMax: map['temperatureMax']?.toDouble() ?? 30.0,
      heaterEnabled: map['heaterEnabled'] ?? false,
      coolerEnabled: map['coolerEnabled'] ?? false,
      targetOxygen: map['targetOxygen']?.toDouble() ?? 6.0,
      oxygenMin: map['oxygenMin']?.toDouble() ?? 5.0,
      aeratorEnabled: map['aeratorEnabled'] ?? false,
      targetPh: map['targetPh']?.toDouble() ?? 7.0,
      phMin: map['phMin']?.toDouble() ?? 6.5,
      phMax: map['phMax']?.toDouble() ?? 8.5,
      phPumpEnabled: map['phPumpEnabled'] ?? false,
      scheduleRules: (map['scheduleRules'] as List<dynamic>?)
          ?.map((rule) => ScheduleRule.fromMap(rule))
          .toList() ?? [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pondId': pondId,
      'autoMode': autoMode,
      'manualMode': manualMode,
      'targetTemperature': targetTemperature,
      'temperatureMin': temperatureMin,
      'temperatureMax': temperatureMax,
      'heaterEnabled': heaterEnabled,
      'coolerEnabled': coolerEnabled,
      'targetOxygen': targetOxygen,
      'oxygenMin': oxygenMin,
      'aeratorEnabled': aeratorEnabled,
      'targetPh': targetPh,
      'phMin': phMin,
      'phMax': phMax,
      'phPumpEnabled': phPumpEnabled,
      'scheduleRules': scheduleRules.map((rule) => rule.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'userId': userId,
    };
  }
}

class ScheduleRule {
  final String id;
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> activeDays; // 1=Monday, 7=Sunday
  final Map<String, dynamic> actions; // What to control during this time
  final bool isActive;

  ScheduleRule({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.activeDays,
    required this.actions,
    required this.isActive,
  });

  factory ScheduleRule.fromMap(Map<String, dynamic> map) {
    return ScheduleRule(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startTime: TimeOfDay(
        hour: map['startHour'] ?? 0,
        minute: map['startMinute'] ?? 0,
      ),
      endTime: TimeOfDay(
        hour: map['endHour'] ?? 0,
        minute: map['endMinute'] ?? 0,
      ),
      activeDays: List<int>.from(map['activeDays'] ?? []),
      actions: Map<String, dynamic>.from(map['actions'] ?? {}),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'activeDays': activeDays,
      'actions': actions,
      'isActive': isActive,
    };
  }
}