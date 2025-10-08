// Setup Firebase Auth Users untuk Testing
// Script ini membuat user default untuk development dan testing

const admin = require('firebase-admin');
const { setupFirebase } = require('./setup-firebase');

async function createDefaultUsers() {
  console.log('👤 Creating default users for testing...');

  try {
    // Create Admin User
    const adminUser = await admin.auth().createUser({
      email: 'admin@kolamikan.com',
      password: 'admin123',
      displayName: 'Administrator',
      emailVerified: true,
    });

    console.log('✅ Admin user created:', {
      email: 'admin@kolamikan.com',
      password: 'admin123',
      uid: adminUser.uid
    });

    // Create Test User
    const testUser = await admin.auth().createUser({
      email: 'user@kolamikan.com',
      password: 'user123',
      displayName: 'Test User',
      emailVerified: true,
    });

    console.log('✅ Test user created:', {
      email: 'user@kolamikan.com',
      password: 'user123',
      uid: testUser.uid
    });

    // Update Firestore user profiles with correct UIDs
    const db = admin.firestore();

    // Update admin user document
    await db.collection('users').doc(adminUser.uid).set({
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
    });

    // Create test user document
    await db.collection('users').doc(testUser.uid).set({
      email: 'user@kolamikan.com',
      name: 'Test User',
      role: 'user',
      assignedPonds: ['pond_001'],
      createdAt: admin.firestore.Timestamp.now(),
      isActive: true,
      permissions: {
        viewAllData: false,
        controlDevices: true,
        manageUsers: false,
        manageReports: false,
        systemSettings: false
      }
    });

    console.log('✅ User profiles updated in Firestore');

    console.log('\n🎉 Default users created successfully!');
    console.log('\n📋 Login Credentials:');
    console.log('┌─────────────────────────────────────────┐');
    console.log('│                ADMIN LOGIN              │');
    console.log('├─────────────────────────────────────────┤');
    console.log('│ Email:    admin@kolamikan.com           │');
    console.log('│ Password: admin123                      │');
    console.log('│ Role:     Admin                         │');
    console.log('├─────────────────────────────────────────┤');
    console.log('│                USER LOGIN               │');
    console.log('├─────────────────────────────────────────┤');
    console.log('│ Email:    user@kolamikan.com            │');
    console.log('│ Password: user123                       │');
    console.log('│ Role:     User                          │');
    console.log('└─────────────────────────────────────────┘');

  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      console.log('⚠️  Users already exist. Current credentials:');
      console.log('\n📋 Login Credentials:');
      console.log('┌─────────────────────────────────────────┐');
      console.log('│                ADMIN LOGIN              │');
      console.log('├─────────────────────────────────────────┤');
      console.log('│ Email:    admin@kolamikan.com           │');
      console.log('│ Password: admin123                      │');
      console.log('│ Role:     Admin                         │');
      console.log('├─────────────────────────────────────────┤');
      console.log('│                USER LOGIN               │');
      console.log('├─────────────────────────────────────────┤');
      console.log('│ Email:    user@kolamikan.com            │');
      console.log('│ Password: user123                       │');
      console.log('│ Role:     User                          │');
      console.log('└─────────────────────────────────────────┘');
    } else {
      console.error('❌ Error creating users:', error);
    }
  }
}

// Export function
module.exports = { createDefaultUsers };

// Run if executed directly
if (require.main === module) {
  createDefaultUsers().then(() => process.exit(0));
}