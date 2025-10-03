import 'package:flutter/material.dart';

class UserReport {
  final String id;
  final String userId;
  final String userName;
  final String pondId;
  final String title;
  final String description;
  final ReportType type;
  final Priority priority;
  final List<String> imageUrls;
  final DateTime reportTime;
  final ReportStatus status;
  final String? adminResponse;
  final String? assignedAdminId;
  final DateTime? resolvedAt;

  UserReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.pondId,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.imageUrls,
    required this.reportTime,
    required this.status,
    this.adminResponse,
    this.assignedAdminId,
    this.resolvedAt,
  });

  factory UserReport.fromMap(Map<String, dynamic> map, String id) {
    return UserReport(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      pondId: map['pondId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.toString() == 'ReportType.${map['type']}',
        orElse: () => ReportType.general,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.toString() == 'Priority.${map['priority']}',
        orElse: () => Priority.medium,
      ),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      reportTime: DateTime.fromMillisecondsSinceEpoch(map['reportTime'] ?? 0),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == 'ReportStatus.${map['status']}',
        orElse: () => ReportStatus.pending,
      ),
      adminResponse: map['adminResponse'],
      assignedAdminId: map['assignedAdminId'],
      resolvedAt: map['resolvedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'pondId': pondId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'imageUrls': imageUrls,
      'reportTime': reportTime.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'adminResponse': adminResponse,
      'assignedAdminId': assignedAdminId,
      'resolvedAt': resolvedAt?.millisecondsSinceEpoch,
    };
  }
}

enum ReportType {
  waterQuality,
  equipment,
  fishHealth,
  temperature,
  oxygen,
  ph,
  general,
}

enum Priority {
  low,
  medium,
  high,
  critical,
}

enum ReportStatus {
  pending,
  inProgress,
  resolved,
  rejected,
}

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.waterQuality:
        return 'Kualitas Air';
      case ReportType.equipment:
        return 'Peralatan';
      case ReportType.fishHealth:
        return 'Kesehatan Ikan';
      case ReportType.temperature:
        return 'Suhu';
      case ReportType.oxygen:
        return 'Oksigen';
      case ReportType.ph:
        return 'pH Air';
      case ReportType.general:
        return 'Umum';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.waterQuality:
        return Icons.water_drop;
      case ReportType.equipment:
        return Icons.build;
      case ReportType.fishHealth:
        return Icons.pets;
      case ReportType.temperature:
        return Icons.thermostat;
      case ReportType.oxygen:
        return Icons.air;
      case ReportType.ph:
        return Icons.science;
      case ReportType.general:
        return Icons.report;
    }
  }
}

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Rendah';
      case Priority.medium:
        return 'Sedang';
      case Priority.high:
        return 'Tinggi';
      case Priority.critical:
        return 'Kritis';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.critical:
        return Colors.red.shade900;
    }
  }
}

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Menunggu';
      case ReportStatus.inProgress:
        return 'Dalam Proses';
      case ReportStatus.resolved:
        return 'Selesai';
      case ReportStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.inProgress:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }
}