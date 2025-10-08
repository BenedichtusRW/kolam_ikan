# � Firebase Setup - Kolam Ikan Project

## 📋 Project Information
✅ **Project Name**: Kolam Ikan Project  
✅ **Project ID**: `kolam-ikan-a8191`  
✅ **Console URL**: https://console.firebase.google.com/project/kolam-ikan-a8191  
✅ **Configuration**: Sudah benar untuk "Kolam Ikan Project"

---

## 🚀 Setup yang Harus Dilakukan

### Step 1: Aktifkan Authentication
1. Buka: https://console.firebase.google.com/project/kolam-ikan-a8191/authentication
2. Klik "Get Started"
3. Pilih tab "Sign-in method"
4. Enable "Email/Password"
5. Klik "Save"

### Step 2: Aktifkan Firestore Database
1. Buka: https://console.firebase.google.com/project/kolam-ikan-a8191/firestore
2. Klik "Create database"
3. Pilih "Start in test mode" (untuk development)
4. Pilih region: asia-southeast1
5. Klik "Done"

### Step 3: Buat User Test
Di Firebase Console > Authentication > Users, tambahkan:

**Admin User:**
- Email: `admin@kolamikan.com`
- Password: `admin123`

**Regular User:**
- Email: `user@kolamikan.com`
- Password: `user123`

### Step 4: Test Flutter App
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 Test Login

Setelah setup:
1. Run Flutter app: `flutter run`
2. Di login screen, tap kotak biru untuk auto-fill credentials
3. Login dengan admin atau user credentials

---

## 🔧 Advanced Setup (Optional)

### Download Service Account Key
1. Firebase Console → **Project Settings** → **Service accounts**
2. Click **Generate new private key**
3. Save as `firebase/service-account-key.json`
4. Run: `node firebase/quick-setup.js`

### Enable Firestore
1. Firebase Console → **Firestore Database**
2. Create database in **test mode**
3. Choose region (asia-southeast1)

---

## 🎯 Project Configuration

**Project ID:** `kolam-ikan-a8191`  
**Web App ID:** `1:662701231859:android:0245330fc1923a26663186`  
**Package Name:** `com.example.kolam_ikan`

---

## 🐛 Troubleshooting

### Error: CONFIGURATION_NOT_FOUND
- ✅ **Fixed:** Updated `firebase_options.dart` with real credentials

### Error: Firebase project not found
- ✅ **Fixed:** Using real project ID `kolam-ikan-a8191`

### Error: Auth domain not authorized
- 🔧 **Solution:** Add `kolam-ikan-a8191.firebaseapp.com` to authorized domains

### Error: User creation failed
- 🔧 **Solution:** Create users manually via Firebase Console

---

## 📋 Next Steps

1. **Test login** dengan credentials yang sudah dibuat
2. **Enable Firestore** untuk data storage
3. **Setup Cloud Functions** untuk backend logic (optional)
4. **Configure FCM** untuk push notifications (optional)

---

**Status:** Ready untuk development testing! 🎉