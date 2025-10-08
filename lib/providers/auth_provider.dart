import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _userProfile != null;

  // Constructor untuk mendengarkan perubahan auth state
  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    if (user != null) {
      await _loadUserProfile(user.uid);
    } else {
      _userProfile = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data();
        if (data is Map<String, dynamic>) {
          _userProfile = UserProfile.fromMap(data, uid);
        } else {
          print('Invalid data format from Firestore: ${data.runtimeType}');
          await _createDefaultUserProfile(uid);
        }
      } else {
        // Jika user belum ada di Firestore, create default profile
        await _createDefaultUserProfile(uid);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
      _errorMessage = 'Error loading user profile: ${e.toString()}';
      // Fallback: create default profile
      await _createDefaultUserProfile(uid);
      notifyListeners();
    }
  }

  Future<void> _createDefaultUserProfile(String uid) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final defaultProfile = UserProfile(
          uid: uid,
          email: user.email ?? '',
          name: user.email?.split('@')[0] ?? 'User',
          role: 'user', // Default role
        );

        await _firestore.collection('users').doc(uid).set(defaultProfile.toMap());
        _userProfile = defaultProfile;
        print('Created default profile for user: ${user.email}');
      }
    } catch (e) {
      print('Error creating user profile: $e');
      _errorMessage = 'Error creating user profile: ${e.toString()}';
    }
  }

  Future<bool> loginUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserProfile(credential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          _errorMessage = 'Password salah';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        case 'user-disabled':
          _errorMessage = 'Akun telah dinonaktifkan';
          break;
        default:
          _errorMessage = 'Login gagal: ${e.message}';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Manual Signup Method
  Future<bool> signUpUser(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        UserProfile userProfile = UserProfile(
          uid: credential.user!.uid,
          email: email,
          name: name,
          role: 'user', // Default role for signup users
          pondId: 'pond_001', // Default pond assignment
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userProfile.toMap());

        await _loadUserProfile(credential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'Password terlalu lemah';
          break;
        case 'email-already-in-use':
          _errorMessage = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        default:
          _errorMessage = 'Signup gagal: ${e.message}';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Google Sign In Method
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists in Firestore, if not create profile
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!doc.exists) {
          // Create new user profile for Google sign-in
          UserProfile userProfile = UserProfile(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName ?? 'Google User',
            role: 'user', // Default role for Google users
            pondId: 'pond_001', // Default pond assignment
          );

          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userProfile.toMap());
        }

        await _loadUserProfile(userCredential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Google Sign-In gagal: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Facebook Sign In Method
  Future<bool> signInWithFacebook() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    return false;
  }

  // Google Sign Out
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  // Enhanced logout that handles all sign-in methods
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await signOutGoogle();
      _userProfile = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}