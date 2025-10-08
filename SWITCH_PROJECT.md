# 🔄 Switch ke Database "Kolam Ikan Project"

## 📋 **Project Information (Yang Anda Inginkan):**
- **Nama Project**: Kolam Ikan Project
- **ID Proyek**: `proyek kolam ikan` 
- **Nomor proyek**: `685083671333`
- **Console URL**: https://console.firebase.google.com/u/7/project/kolam-ikan-project

## ✅ **Yang Sudah Diupdate:**
- ✅ `firebase_options.dart` → project ID: `proyek-kolam-ikan`
- ✅ Project Number: `685083671333`

## ⚠️ **Yang Masih Perlu Dilakukan:**

### 1. **Download Google Services JSON Baru**
**PENTING**: Anda harus download file baru dari project yang benar!

#### Langkah Download:
1. **Buka**: https://console.firebase.google.com/u/7/project/kolam-ikan-project/settings/general
2. **Scroll ke bawah** sampai bagian **"Aplikasi Anda"** / **"Your apps"**
3. **Jika belum ada Android app**:
   - Klik **"Add app"** → **Android** 
   - Package name: `com.example.kolam_ikan`
   - App nickname: `Kolam Ikan Flutter`
   - Register app
4. **Download google-services.json**
5. **Replace file** di: `android/app/google-services.json`

### 2. **Update API Key**
Setelah download google-services.json baru:
- Buka file tersebut
- Copy `"current_key"` (API key)
- Update di `lib/config/firebase_options.dart`

### 3. **Enable Services di Console Project yang Benar**
URL: https://console.firebase.google.com/u/7/project/kolam-ikan-project

**Authentication:**
- https://console.firebase.google.com/u/7/project/kolam-ikan-project/authentication
- Enable Email/Password

**Firestore:**
- https://console.firebase.google.com/u/7/project/kolam-ikan-project/firestore
- Create database (test mode)

## 🚨 **Atau Alternatif Mudah:**
Jika Anda ingin tetap pakai project `kolam-ikan-a8191` yang sudah bekerja, saya bisa revert konfigurasi. Tapi kalau mau pakai "Kolam Ikan Project", ikuti langkah di atas.

## 📱 **Setelah Setup:**
```bash
flutter clean
flutter pub get
flutter run
```

---
**🎯 Pilih project mana yang mau dipakai, nanti saya bantu sesuaikan konfigurasinya!**