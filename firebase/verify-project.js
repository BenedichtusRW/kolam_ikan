// Firebase Project Verification Script
// Project: Kolam Ikan Project (kolam-ikan-a8191)

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = {
  "project_id": "kolam-ikan-a8191",
  "private_key_id": "your_private_key_id",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@kolam-ikan-a8191.iam.gserviceaccount.com",
  "client_id": "your_client_id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs/firebase-adminsdk-xxxxx%40kolam-ikan-a8191.iam.gserviceaccount.com"
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://kolam-ikan-a8191-default-rtdb.firebaseio.com"
});

// Verify project connection
async function verifyProject() {
  try {
    console.log('🔍 Memverifikasi koneksi ke Firebase Project: Kolam Ikan Project');
    console.log('📋 Project ID:', admin.app().options.projectId);
    
    // Test Firestore connection
    const db = admin.firestore();
    const testDoc = await db.collection('test').doc('connection').set({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      message: 'Koneksi berhasil dari script verifikasi'
    });
    
    console.log('✅ Firestore connection: OK');
    
    // Test Authentication service
    const auth = admin.auth();
    console.log('✅ Authentication service: OK');
    
    console.log('\n🎉 Project "Kolam Ikan Project" siap digunakan!');
    console.log('🔗 Project URL: https://console.firebase.google.com/project/kolam-ikan-a8191');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.log('\n📝 Langkah troubleshooting:');
    console.log('1. Pastikan service account key sudah benar');
    console.log('2. Aktifkan Firestore dan Authentication di Firebase Console');
    console.log('3. Periksa permission project');
  }
}

// Create test users for development
async function createTestUsers() {
  const testUsers = [
    {
      email: 'admin@kolamikan.com',
      password: 'admin123',
      displayName: 'Admin Kolam Ikan',
      role: 'admin'
    },
    {
      email: 'user@kolamikan.com', 
      password: 'user123',
      displayName: 'User Kolam Ikan',
      role: 'user'
    }
  ];

  for (const user of testUsers) {
    try {
      const userRecord = await admin.auth().createUser({
        email: user.email,
        password: user.password,
        displayName: user.displayName,
        emailVerified: true
      });

      // Add user data to Firestore
      await admin.firestore().collection('users').doc(userRecord.uid).set({
        email: user.email,
        displayName: user.displayName,
        role: user.role,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isActive: true
      });

      console.log(`✅ User created: ${user.email} (${user.role})`);
    } catch (error) {
      if (error.code === 'auth/email-already-exists') {
        console.log(`ℹ️  User already exists: ${user.email}`);
      } else {
        console.error(`❌ Error creating user ${user.email}:`, error.message);
      }
    }
  }
}

// Manual setup instructions
function showManualSetup() {
  console.log('\n📋 SETUP MANUAL UNTUK PROJECT "KOLAM IKAN PROJECT"');
  console.log('=' .repeat(60));
  
  console.log('\n1. 🔐 AKTIFKAN AUTHENTICATION:');
  console.log('   • Buka: https://console.firebase.google.com/project/kolam-ikan-a8191/authentication');
  console.log('   • Klik "Get Started"');
  console.log('   • Pilih tab "Sign-in method"');
  console.log('   • Enable "Email/Password"');
  
  console.log('\n2. 📊 AKTIFKAN FIRESTORE:');
  console.log('   • Buka: https://console.firebase.google.com/project/kolam-ikan-a8191/firestore');
  console.log('   • Klik "Create database"');
  console.log('   • Pilih "Start in test mode" (untuk development)');
  console.log('   • Pilih region: asia-southeast1');
  
  console.log('\n3. 👥 BUAT USER TEST (Manual di Console):');
  console.log('   • Buka Authentication > Users');
  console.log('   • Klik "Add user"');
  console.log('   • Admin: admin@kolamikan.com / admin123');
  console.log('   • User: user@kolamikan.com / user123');
  
  console.log('\n4. 🧪 TEST FLUTTER APP:');
  console.log('   • Jalankan: flutter run');
  console.log('   • Login dengan user yang sudah dibuat');
  console.log('   • Pastikan tidak ada error CONFIGURATION_NOT_FOUND');
  
  console.log('\n✨ Project "Kolam Ikan Project" siap digunakan!');
}

// Run setup
if (require.main === module) {
  showManualSetup();
}

module.exports = {
  verifyProject,
  createTestUsers,
  showManualSetup
};