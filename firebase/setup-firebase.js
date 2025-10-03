// Firebase Setup Script untuk Kolam Ikan IoT Project
// Script ini membantu setup initial data dan konfigurasi Firebase

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Load service account key
const serviceAccount = require('./firebase-config.js').admin;

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`
});

const db = admin.firestore();

async function setupFirebase() {
  console.log('🔥 Setting up Firebase for Kolam Ikan IoT...');

  try {
    // Create initial collections and sample data
    await createInitialData();
    
    // Setup security rules (jika menggunakan Admin SDK)
    console.log('✅ Firebase setup completed successfully!');
    
  } catch (error) {
    console.error('❌ Error setting up Firebase:', error);
  }
}

async function createInitialData() {
  console.log('📊 Creating initial data...');

  // Create sample pond
  const pondData = {
    name: 'Kolam A',
    location: 'Area Utama',
    capacity: 1000, // liters
    species: 'Lele',
    createdAt: admin.firestore.Timestamp.now(),
    isActive: true,
    assignedUsers: []
  };

  await db.collection('ponds').doc('pond_001').set(pondData);
  console.log('✅ Sample pond created');

  // Create sample device
  const deviceData = {
    name: 'ESP32 Sensor Unit 1',
    type: 'sensor',
    pondId: 'pond_001',
    location: 'Kolam A - Tengah',
    ipAddress: '192.168.1.100',
    lastOnline: admin.firestore.Timestamp.now(),
    isOnline: false,
    firmware: '1.0.0',
    sensors: ['temperature', 'oxygen', 'ph'],
    actuators: ['heater', 'aerator', 'ph_pump']
  };

  await db.collection('devices').doc('ESP32_001').set(deviceData);
  console.log('✅ Sample device created');

  // Create default control settings
  const controlSettings = {
    pondId: 'pond_001',
    autoMode: false,
    manualMode: true,
    targetTemperature: 25.0,
    temperatureMin: 20.0,
    temperatureMax: 30.0,
    heaterEnabled: false,
    coolerEnabled: false,
    targetOxygen: 6.0,
    oxygenMin: 5.0,
    aeratorEnabled: false,
    targetPh: 7.0,
    phMin: 6.5,
    phMax: 8.5,
    phPumpEnabled: false,
    scheduleRules: [],
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
    userId: 'system'
  };

  await db.collection('control_settings').doc('control_pond_001').set(controlSettings);
  console.log('✅ Default control settings created');

  // Create sample admin user
  const adminUserData = {
    email: 'admin@kolamikan.com',
    name: 'Administrator',
    role: 'admin',
    assignedPonds: ['pond_001'],
    createdAt: admin.firestore.Timestamp.now(),
    isActive: true,
    permissions: {
      viewAllData: true,
      controlDevices: true,
      manageUsers: true,
      manageReports: true,
      systemSettings: true
    }
  };

  // Note: In production, you would create the user through Firebase Auth first
  await db.collection('users').doc('admin_user').set(adminUserData);
  console.log('✅ Sample admin user created');

  console.log('📊 Initial data creation completed');
}

// Function to backup Firestore data
async function backupFirestore() {
  console.log('💾 Creating Firestore backup...');
  
  const collections = ['users', 'sensor_data', 'control_settings', 'user_reports', 'devices', 'ponds'];
  const backup = {};
  
  for (const collection of collections) {
    const snapshot = await db.collection(collection).get();
    backup[collection] = {};
    
    snapshot.forEach(doc => {
      backup[collection][doc.id] = doc.data();
    });
  }
  
  const backupPath = path.join(__dirname, `backup_${Date.now()}.json`);
  fs.writeFileSync(backupPath, JSON.stringify(backup, null, 2));
  
  console.log(`✅ Backup created: ${backupPath}`);
}

// Function to restore from backup
async function restoreFromBackup(backupFile) {
  console.log(`📥 Restoring from backup: ${backupFile}`);
  
  const backup = JSON.parse(fs.readFileSync(backupFile, 'utf8'));
  
  for (const [collectionName, documents] of Object.entries(backup)) {
    console.log(`Restoring collection: ${collectionName}`);
    
    for (const [docId, docData] of Object.entries(documents)) {
      await db.collection(collectionName).doc(docId).set(docData);
    }
  }
  
  console.log('✅ Restore completed');
}

// Export functions
module.exports = {
  setupFirebase,
  backupFirestore,
  restoreFromBackup,
  db,
  admin
};

// Run setup if this file is executed directly
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.includes('--backup')) {
    backupFirestore();
  } else if (args.includes('--restore') && args[1]) {
    restoreFromBackup(args[1]);
  } else {
    setupFirebase();
  }
}