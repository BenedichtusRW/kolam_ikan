// Script untuk update Flutter config dari JavaScript config
// Digunakan agar Flutter dan JavaScript backend selalu sync

const fs = require('fs');
const path = require('path');

// Load Firebase config
const firebaseConfig = require('./firebase-config.js');

function updateFlutterConfig() {
  console.log('🔄 Updating Flutter Firebase configuration...');

  const flutterConfigContent = `import 'package:firebase_core/firebase_core.dart';

// Firebase Configuration for Flutter
// Generated from firebase/firebase-config.js
// DO NOT EDIT MANUALLY - Update using: node firebase/update-flutter-config.js

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '${firebaseConfig.web.apiKey}',
    appId: '${firebaseConfig.web.appId.replace('web', 'android')}',
    messagingSenderId: '${firebaseConfig.web.messagingSenderId}',
    projectId: '${firebaseConfig.web.projectId}',
    authDomain: '${firebaseConfig.web.authDomain}',
    storageBucket: '${firebaseConfig.web.storageBucket}',
    measurementId: '${firebaseConfig.web.measurementId}',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '${firebaseConfig.web.apiKey}',
    appId: '${firebaseConfig.web.appId}',
    messagingSenderId: '${firebaseConfig.web.messagingSenderId}',
    projectId: '${firebaseConfig.web.projectId}',
    authDomain: '${firebaseConfig.web.authDomain}',
    storageBucket: '${firebaseConfig.web.storageBucket}',
    measurementId: '${firebaseConfig.web.measurementId}',
  );
}

// Collection names - shared with backend
class FirebaseCollections {
  static const String users = '${firebaseConfig.collections.users}';
  static const String sensorData = '${firebaseConfig.collections.sensor_data}';
  static const String controlSettings = '${firebaseConfig.collections.control_settings}';
  static const String userReports = '${firebaseConfig.collections.user_reports}';
  static const String devices = '${firebaseConfig.collections.devices}';
  static const String deviceStatus = '${firebaseConfig.collections.device_status}';
  static const String deviceCommands = '${firebaseConfig.collections.device_commands}';
  static const String alerts = '${firebaseConfig.collections.alerts}';
  static const String ponds = '${firebaseConfig.collections.ponds}';
  static const String analytics = '${firebaseConfig.collections.analytics}';
}

// Storage paths
class FirebaseStoragePaths {
  static const String reports = '${firebaseConfig.storage.reports}';
  static const String deviceImages = '${firebaseConfig.storage.device_images}';
  static const String userAvatars = '${firebaseConfig.storage.user_avatars}';
  static const String systemBackup = '${firebaseConfig.storage.system_backup}';
}

// FCM Topics
class FCMTopics {
  static const String allUsers = '${firebaseConfig.fcm.all_users}';
  static const String admins = '${firebaseConfig.fcm.admins}';
  static const String alerts = '${firebaseConfig.fcm.alerts}';
  static const String pondUpdates = '${firebaseConfig.fcm.pond_updates}';
}
`;

  // Write to Flutter config file
  const flutterConfigPath = path.join(__dirname, '../lib/config/firebase_options.dart');
  
  try {
    fs.writeFileSync(flutterConfigPath, flutterConfigContent);
    console.log('✅ Flutter Firebase config updated successfully');
  } catch (error) {
    console.error('❌ Error updating Flutter config:', error);
  }
}

function updateBackendEnv() {
  console.log('🔄 Updating backend environment variables...');

  const envContent = `# Backend Configuration - Auto-generated
NODE_ENV=production
PORT=3000

# MQTT Configuration
MQTT_BROKER=mosquitto
MQTT_PORT=1883

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# InfluxDB Configuration
INFLUXDB_URL=http://influxdb:8086
INFLUXDB_TOKEN=my-super-secret-auth-token
INFLUXDB_ORG=kolam-org
INFLUXDB_BUCKET=sensor-data

# Firebase Configuration
FIREBASE_PROJECT_ID=${firebaseConfig.admin.project_id}
FIREBASE_PRIVATE_KEY="${firebaseConfig.admin.private_key}"
FIREBASE_CLIENT_EMAIL=${firebaseConfig.admin.client_email}

# Logging
LOG_LEVEL=info

# Security
JWT_SECRET=your-jwt-secret-key
API_KEY=your-api-key-for-device-authentication

# Sensor Thresholds
TEMP_MIN=20
TEMP_MAX=30
TEMP_CRITICAL_MIN=15
TEMP_CRITICAL_MAX=35
OXYGEN_MIN=5
OXYGEN_CRITICAL=3
PH_MIN=6.5
PH_MAX=8.5
PH_CRITICAL_MIN=6
PH_CRITICAL_MAX=9
`;

  const envPath = path.join(__dirname, '../docker/backend/.env');
  
  try {
    fs.writeFileSync(envPath, envContent);
    console.log('✅ Backend environment config updated successfully');
  } catch (error) {
    console.error('❌ Error updating backend env:', error);
  }
}

// Run updates
if (require.main === module) {
  updateFlutterConfig();
  updateBackendEnv();
  console.log('🎉 All configurations updated!');
}

module.exports = {
  updateFlutterConfig,
  updateBackendEnv
};