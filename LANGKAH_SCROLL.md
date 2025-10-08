# 📱 Langkah Setup Android App di Firebase Console

## 🎯 Anda sudah berada di halaman yang benar!

**URL saat ini**: console.firebase.google.com/u/7/project/kolam-ikan-project/settings/general

## 📋 Data Project yang Benar:
✅ **Nama proyek**: Kolam Ikan Project  
✅ **ID Proyek**: `proyek kolam ikan`  
✅ **Nomor proyek**: `685083671333`

## 🔽 SCROLL KE BAWAH!

Di halaman yang sama, **scroll ke bawah** sampai Anda menemukan:

```
📱 Aplikasi Anda
atau
📱 Your apps
```

## ➕ Tambah Android App

1. **Klik tombol "Add app"** atau **"Tambah aplikasi"**
2. **Pilih Android** (ikon robot hijau 🤖)
3. **Isi form**:
   - **Package name**: `com.example.kolam_ikan`
   - **App nickname**: `Kolam Ikan Flutter` (opsional)
   - **Debug SHA-1**: kosongkan untuk sekarang

4. **Klik "Register app"**

5. **Download google-services.json**
   - Setelah register, akan ada tombol download
   - Save file ke: `android/app/google-services.json`
   - Replace file yang sudah ada

## 🔧 Setelah Download

1. **Buka google-services.json** yang baru didownload
2. **Copy API key** dan **App ID** dari file tersebut
3. **Update Firebase configuration** di Flutter

## 📍 File yang Perlu Update:
- `android/app/google-services.json` ← Replace dengan yang baru
- `lib/config/firebase_options.dart` ← Update API key dan App ID

---

**🎯 Ikuti langkah ini untuk mendapatkan konfigurasi Firebase yang benar!**