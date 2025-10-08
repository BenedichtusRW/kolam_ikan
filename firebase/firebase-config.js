// Firebase Configuration for Kolam Ikan IoT Project
// Shared configuration untuk Flutter dan JavaScript backend

const firebaseConfig = {
  // Web/Flutter Configuration
  web: {
    apiKey: "AIzaSyBvOiF8oaEP32-your-api-key",
    authDomain: "kolam-ikan-project.firebaseapp.com",
    projectId: "kolam-ikan-project",
    storageBucket: "kolam-ikan-project.appspot.com",
    messagingSenderId: "685083671333",
    appId: "1:685083671333:android:your-app-id",
  },

  // Admin SDK Configuration (untuk Node.js backend)
  admin: {
    type: "service_account",
    project_id: "your-project-id",
    private_key_id: "your-private-key-id",
    private_key: "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n",
    client_email: "firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com",
    client_id: "123456789",
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project.iam.gserviceaccount.com"
  },

  // Database Collections Structure
  collections: {
    users: "users",
    sensor_data: "sensor_data",
    control_settings: "control_settings",
    user_reports: "user_reports",
    devices: "devices",
    device_status: "device_status",
    device_commands: "device_commands",
    alerts: "alerts",
    ponds: "ponds",
    analytics: "analytics"
  },

  // Storage Buckets
  storage: {
    reports: "reports/",
    device_images: "devices/",
    user_avatars: "avatars/",
    system_backup: "backups/"
  },

  // FCM Topics
  fcm: {
    all_users: "all_users",
    admins: "admins",
    alerts: "critical_alerts",
    pond_updates: "pond_updates"
  }
};

// Export untuk berbagai environment
if (typeof module !== 'undefined' && module.exports) {
  // Node.js environment
  module.exports = firebaseConfig;
} else if (typeof window !== 'undefined') {
  // Browser environment
  window.firebaseConfig = firebaseConfig;
}

// Dart export untuk Flutter (akan di-generate oleh script)
const dartConfig = `
// Auto-generated Firebase config for Flutter
// DO NOT EDIT MANUALLY - Use update-flutter-config.js script

const firebaseOptions = FirebaseOptions(
  apiKey: '${firebaseConfig.web.apiKey}',
  appId: '${firebaseConfig.web.appId}',
  messagingSenderId: '${firebaseConfig.web.messagingSenderId}',
  projectId: '${firebaseConfig.web.projectId}',
  authDomain: '${firebaseConfig.web.authDomain}',
  storageBucket: '${firebaseConfig.web.storageBucket}',
  measurementId: '${firebaseConfig.web.measurementId}',
);
`;

// Simpan Dart config ke file terpisah jika dijalankan di Node.js
if (typeof require !== 'undefined') {
  const fs = require('fs');
  const path = require('path');
  
  try {
    const dartConfigPath = path.join(__dirname, '../lib/config/firebase_options.dart');
    fs.writeFileSync(dartConfigPath, dartConfig);
    console.log('✅ Flutter Firebase config updated');
  } catch (error) {
    console.log('⚠️ Could not update Flutter config:', error.message);
  }
}