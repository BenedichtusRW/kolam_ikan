import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data.dart';
import '../models/control_settings.dart';
import '../models/user_report.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String SENSOR_DATA = 'sensor_data';
  static const String CONTROL_SETTINGS = 'control_settings';
  static const String USER_REPORTS = 'user_reports';
  static const String PONDS = 'ponds';
  static const String DEVICES = 'devices';

  // ========== SENSOR DATA ==========
  
  /// Stream sensor data in real-time
  static Stream<List<SensorData>> getSensorDataStream(String pondId) {
    return _firestore
        .collection(SENSOR_DATA)
        .where('pondId', isEqualTo: pondId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SensorData.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get latest sensor data
  static Future<SensorData?> getLatestSensorData(String pondId) async {
    try {
      final snapshot = await _firestore
          .collection(SENSOR_DATA)
          .where('pondId', isEqualTo: pondId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return SensorData.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      print('Error getting latest sensor data: $e');
      return null;
    }
  }

  /// Add new sensor data (usually called by IoT device)
  static Future<bool> addSensorData(SensorData data) async {
    try {
      await _firestore.collection(SENSOR_DATA).add(data.toMap());
      return true;
    } catch (e) {
      print('Error adding sensor data: $e');
      return false;
    }
  }

  /// Get sensor data history for specific date range
  static Future<List<SensorData>> getSensorDataHistory(
    String pondId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(SENSOR_DATA)
          .where('pondId', isEqualTo: pondId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('timestamp', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SensorData.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting sensor data history: $e');
      return [];
    }
  }

  // ========== CONTROL SETTINGS ==========

  /// Get control settings for a pond
  static Future<ControlSettings?> getControlSettings(String pondId) async {
    try {
      final snapshot = await _firestore
          .collection(CONTROL_SETTINGS)
          .where('pondId', isEqualTo: pondId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ControlSettings.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      print('Error getting control settings: $e');
      return null;
    }
  }

  /// Update control settings
  static Future<bool> updateControlSettings(ControlSettings settings) async {
    try {
      await _firestore
          .collection(CONTROL_SETTINGS)
          .doc(settings.id)
          .set(settings.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating control settings: $e');
      return false;
    }
  }

  /// Stream control settings changes
  static Stream<ControlSettings?> getControlSettingsStream(String pondId) {
    return _firestore
        .collection(CONTROL_SETTINGS)
        .where('pondId', isEqualTo: pondId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return ControlSettings.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
          }
          return null;
        });
  }

  // ========== USER REPORTS ==========

  /// Submit user report
  static Future<String?> submitUserReport(UserReport report) async {
    try {
      final docRef = await _firestore.collection(USER_REPORTS).add(report.toMap());
      return docRef.id;
    } catch (e) {
      print('Error submitting user report: $e');
      return null;
    }
  }

  /// Get user reports (for admin)
  static Stream<List<UserReport>> getUserReportsStream({
    ReportStatus? status,
    Priority? priority,
    String? pondId,
  }) {
    Query query = _firestore.collection(USER_REPORTS);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }
    if (priority != null) {
      query = query.where('priority', isEqualTo: priority.toString().split('.').last);
    }
    if (pondId != null) {
      query = query.where('pondId', isEqualTo: pondId);
    }

    return query
        .orderBy('reportTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserReport.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Update report status (admin action)
  static Future<bool> updateReportStatus(
    String reportId,
    ReportStatus status, {
    String? adminResponse,
    String? adminId,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (adminResponse != null) {
        updateData['adminResponse'] = adminResponse;
      }
      if (adminId != null) {
        updateData['assignedAdminId'] = adminId;
      }
      if (status == ReportStatus.resolved) {
        updateData['resolvedAt'] = DateTime.now().millisecondsSinceEpoch;
      }

      await _firestore.collection(USER_REPORTS).doc(reportId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating report status: $e');
      return false;
    }
  }

  // ========== DEVICE MANAGEMENT ==========

  /// Send command to IoT device (MQTT through Firebase)
  static Future<bool> sendDeviceCommand(
    String deviceId,
    String command,
    Map<String, dynamic> parameters,
  ) async {
    try {
      await _firestore.collection('device_commands').add({
        'deviceId': deviceId,
        'command': command,
        'parameters': parameters,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': 'pending',
      });
      return true;
    } catch (e) {
      print('Error sending device command: $e');
      return false;
    }
  }

  /// Get device status
  static Stream<Map<String, dynamic>> getDeviceStatusStream(String deviceId) {
    return _firestore
        .collection('device_status')
        .doc(deviceId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  // ========== ANALYTICS ==========

  /// Get daily statistics
  static Future<Map<String, dynamic>> getDailyStatistics(
    String pondId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final snapshot = await _firestore
          .collection(SENSOR_DATA)
          .where('pondId', isEqualTo: pondId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('timestamp', isLessThan: endOfDay.millisecondsSinceEpoch)
          .orderBy('timestamp')
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'averageTemperature': 0.0,
          'averageOxygen': 0.0,
          'averagePh': 0.0,
          'minTemperature': 0.0,
          'maxTemperature': 0.0,
          'dataPoints': 0,
        };
      }

      final data = snapshot.docs
          .map((doc) => SensorData.fromMap(doc.data(), doc.id))
          .toList();

      double totalTemp = 0, totalOxygen = 0, totalPh = 0;
      double minTemp = double.infinity, maxTemp = double.negativeInfinity;

      for (final reading in data) {
        totalTemp += reading.temperature;
        totalOxygen += reading.oxygen;
        totalPh += reading.phLevel;
        
        if (reading.temperature < minTemp) minTemp = reading.temperature;
        if (reading.temperature > maxTemp) maxTemp = reading.temperature;
      }

      final count = data.length;
      return {
        'averageTemperature': totalTemp / count,
        'averageOxygen': totalOxygen / count,
        'averagePh': totalPh / count,
        'minTemperature': minTemp,
        'maxTemperature': maxTemp,
        'dataPoints': count,
        'date': date.toIso8601String(),
      };
    } catch (e) {
      print('Error getting daily statistics: $e');
      return {};
    }
  }
}