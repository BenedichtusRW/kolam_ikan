# 🚨 PENTING: Setup untuk Project Firebase yang Benar

## 📋 Project Information
- **Project Console**: https://console.firebase.google.com/u/7/project/kolam-ikan-project/overview
- **Project ID**: kolam-ikan-project (berdasarkan screenshot)

## ⚠️ KONFIGURASI BELUM LENGKAP
Saya sudah update project ID ke "kolam-ikan-project", tapi masih perlu **API key dan credentials yang benar**.

## 🔧 Langkah yang Harus Dilakukan

### 1. Download Google Services JSON
1. Buka: https://console.firebase.google.com/u/7/project/kolam-ikan-project/settings/general
2. Scroll ke "Your apps"
3. Jika belum ada Android app:
   - Klik "Add app" → Android
   - Package name: `com.example.kolam_ikan`
   - App nickname: `Kolam Ikan Flutter`
4. Download `google-services.json`
5. Replace file di: `android/app/google-services.json`

### 2. Update Firebase Options
Setelah download google-services.json, ambil data berikut:
- `project_id` 
- `current_key` (API key)
- `mobilesdk_app_id`
- `project_number` (messaging sender ID)

### 3. Update Configuration Files
Update file-file berikut dengan data dari google-services.json:
- `lib/config/firebase_options.dart`
- `firebase/firebase-config.js`

## 🔍 Cara Cepat Update Configuration

### Option A: Manual Update
1. Buka google-services.json yang baru
2. Copy data ke firebase_options.dart:
   ```dart
   projectId: 'kolam-ikan-project',
   apiKey: 'your-api-key-from-json',
   appId: 'your-app-id-from-json',
   messagingSenderId: 'your-sender-id-from-json',
   ```

### Option B: Otomatis (Recommended)
Setelah download google-services.json:
```bash
flutter packages pub run flutter_launcher_icons:main
flutter pub get
```

## 📱 Test Connection
```bash
flutter run
```

---
**🎯 Setelah setup selesai, aktifkan Authentication dan Firestore di console project yang benar!**