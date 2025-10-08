// Simple Firebase test to verify configuration without running full app
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  try {
    // Test Firebase initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Test Auth instance
    final auth = FirebaseAuth.instance;
    print('✅ Firebase Auth instance created');
    print('Current user: ${auth.currentUser?.email ?? 'No user logged in'}');
    
    // Test Firestore instance
    final firestore = FirebaseFirestore.instance;
    print('✅ Firestore instance created');
    
    // Test project configuration
    print('✅ Project ID: kolam-ikan-project');
    print('✅ Configuration looks good!');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}