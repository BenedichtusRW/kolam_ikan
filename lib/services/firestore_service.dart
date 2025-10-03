import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Profile methods
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  Future<void> createUserProfile(UserProfile userProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userProfile.uid)
          .set(userProfile.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userProfile.uid)
          .update(userProfile.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Sensor Data methods
  Future<List<SensorData>> getSensorDataByDateRange(
    String pondId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sensor_data')
          .where('pondId', isEqualTo: pondId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('timestamp', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => SensorData.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch sensor data: $e');
    }
  }

  Future<SensorData?> getLatestSensorData(String pondId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sensor_data')
          .where('pondId', isEqualTo: pondId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return SensorData.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch latest sensor data: $e');
    }
  }

  // Device Control methods
  Future<Map<String, bool>> getDeviceStatus(String pondId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('device_status')
          .doc(pondId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'aerator': data['aerator'] ?? false,
          'feeder': data['feeder'] ?? false,
        };
      }
      return {'aerator': false, 'feeder': false};
    } catch (e) {
      throw Exception('Failed to fetch device status: $e');
    }
  }

  Future<void> updateDeviceStatus(String pondId, String device, bool status) async {
    try {
      await _firestore
          .collection('device_status')
          .doc(pondId)
          .set({device: status}, SetOptions(merge: true));
      
      // TODO: Also send command to IoT device through MQTT or HTTP API
    } catch (e) {
      throw Exception('Failed to update device status: $e');
    }
  }

  // Stream methods for real-time data
  Stream<QuerySnapshot> getSensorDataStream(String pondId) {
    return _firestore
        .collection('sensor_data')
        .where('pondId', isEqualTo: pondId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  Stream<DocumentSnapshot> getDeviceStatusStream(String pondId) {
    return _firestore
        .collection('device_status')
        .doc(pondId)
        .snapshots();
  }
}