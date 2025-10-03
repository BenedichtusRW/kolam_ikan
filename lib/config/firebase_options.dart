import 'package:firebase_core/firebase_core.dart';

// Firebase Configuration for Flutter
// Generated from firebase/firebase-config.js
// Update using: node firebase/firebase-config.js

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: '1:123456789:android:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    authDomain: 'your-project.firebaseapp.com',
    storageBucket: 'your-project.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    authDomain: 'your-project.firebaseapp.com',
    storageBucket: 'your-project.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );
}

// Collection names - shared with backend
class FirebaseCollections {
  static const String users = 'users';
  static const String sensorData = 'sensor_data';
  static const String controlSettings = 'control_settings';
  static const String userReports = 'user_reports';
  static const String devices = 'devices';
  static const String deviceStatus = 'device_status';
  static const String deviceCommands = 'device_commands';
  static const String alerts = 'alerts';
  static const String ponds = 'ponds';
  static const String analytics = 'analytics';
}

// Storage paths
class FirebaseStoragePaths {
  static const String reports = 'reports/';
  static const String deviceImages = 'devices/';
  static const String userAvatars = 'avatars/';
  static const String systemBackup = 'backups/';
}

// FCM Topics
class FCMTopics {
  static const String allUsers = 'all_users';
  static const String admins = 'admins';
  static const String alerts = 'critical_alerts';
  static const String pondUpdates = 'pond_updates';
}