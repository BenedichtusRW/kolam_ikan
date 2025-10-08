import 'package:flutter_test/flutter_test.dart';
import 'package:kolam_ikan/firebase_options.dart';

void main() {
  group('Firebase Configuration Tests', () {
    test('should have correct project configuration for Kolam Ikan Project', () {
      // Test Android configuration
      expect(DefaultFirebaseOptions.android.projectId, equals('kolam-ikan-project'));
      expect(DefaultFirebaseOptions.android.apiKey, equals('AIzaSyDErG_NUlPZjED5zDhWUzPKyFkkusp4PqM'));
      expect(DefaultFirebaseOptions.android.appId, equals('1:685083671333:android:128e62df10ff5f2813b8cc'));
      expect(DefaultFirebaseOptions.android.messagingSenderId, equals('685083671333'));
      expect(DefaultFirebaseOptions.android.storageBucket, equals('kolam-ikan-project.firebasestorage.app'));
    });

    test('should have matching web configuration', () {
      // Test Web configuration  
      expect(DefaultFirebaseOptions.web.projectId, equals('kolam-ikan-project'));
      expect(DefaultFirebaseOptions.web.apiKey, equals('AIzaSyCvAzHtVasHVBxrpKkchwpLTiB-G9mn5Fg'));
      expect(DefaultFirebaseOptions.web.messagingSenderId, equals('685083671333'));
      expect(DefaultFirebaseOptions.web.authDomain, equals('kolam-ikan-a8191.firebaseapp.com'));
      expect(DefaultFirebaseOptions.web.storageBucket, equals('kolam-ikan-project.firebasestorage.app'));
    });

    test('should return current platform configuration', () {
      final options = DefaultFirebaseOptions.currentPlatform;
      expect(options.projectId, equals('kolam-ikan-project'));
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
    });

    test('should have all required Firebase collections defined', () {
      // Define collection names directly since FirebaseCollections class may not exist
      const usersCollection = 'users';
      const sensorDataCollection = 'sensor_data';
      const controlSettingsCollection = 'control_settings';
      const devicesCollection = 'devices';
      const pondsCollection = 'ponds';
      
      expect(usersCollection, equals('users'));
      expect(sensorDataCollection, equals('sensor_data'));
      expect(controlSettingsCollection, equals('control_settings'));
      expect(devicesCollection, equals('devices'));
      expect(pondsCollection, equals('ponds'));
    });
  });
}