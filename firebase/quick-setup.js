#!/usr/bin/env node
// Quick Firebase Setup Script untuk Kolam Ikan IoT

const admin = require('firebase-admin');

// Initialize Firebase Admin dengan service account (jika ada)
try {
  // Try to use service account from environment atau file
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT 
    ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
    : require('./service-account-key.json'); // Jika ada file

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'kolam-ikan-a8191'
  });
  
  console.log('✅ Firebase Admin initialized with service account');
  
} catch (error) {
  // Fallback: Initialize tanpa service account (limited functionality)
  console.log('⚠️  Service account not found, using limited mode');
  console.log('For full functionality, download service account key from Firebase Console');
  process.exit(1);
}

async function quickSetup() {
  console.log('🚀 Quick Firebase Setup untuk Kolam Ikan IoT...');
  
  try {
    // Create test users
    console.log('👤 Creating test users...');
    
    // Admin user
    const adminUser = await admin.auth().createUser({
      email: 'admin@kolamikan.com',
      password: 'admin123',
      displayName: 'Administrator',
      emailVerified: true,
    });
    console.log('✅ Admin user created');
    
    // Regular user
    const testUser = await admin.auth().createUser({
      email: 'user@kolamikan.com', 
      password: 'user123',
      displayName: 'Test User',
      emailVerified: true,
    });
    console.log('✅ Test user created');

    // Create user profiles in Firestore
    const db = admin.firestore();
    
    await db.collection('users').doc(adminUser.uid).set({
      email: 'admin@kolamikan.com',
      name: 'Administrator',
      role: 'admin',
      createdAt: admin.firestore.Timestamp.now(),
      isActive: true
    });
    
    await db.collection('users').doc(testUser.uid).set({
      email: 'user@kolamikan.com',
      name: 'Test User', 
      role: 'user',
      createdAt: admin.firestore.Timestamp.now(),
      isActive: true
    });
    
    console.log('✅ User profiles created in Firestore');
    
    console.log('\n🎉 Setup completed successfully!');
    console.log('\n📋 Login Credentials:');
    console.log('Admin: admin@kolamikan.com / admin123');
    console.log('User:  user@kolamikan.com / user123');
    
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      console.log('✅ Users already exist - using existing credentials');
      console.log('\n📋 Login Credentials:');
      console.log('Admin: admin@kolamikan.com / admin123');
      console.log('User:  user@kolamikan.com / user123');
    } else {
      console.error('❌ Error during setup:', error);
    }
  }
}

// Run setup
quickSetup().then(() => process.exit(0));