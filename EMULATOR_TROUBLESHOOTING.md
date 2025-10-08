# 🔧 Android Emulator Troubleshooting Guide

## 🚨 **Masalah yang Terjadi:**
```
[ERR] Error 1 retrieving device properties for Android SDK built for x86:
[ERR] adb.exe: device 'emulator-5554' not found
[ERR] The Android emulator exited with code 1 during startup
```

## 🛠️ **Solusi Step-by-Step:**

### **1️⃣ Restart ADB Server**
```bash
adb kill-server
adb start-server
```

### **2️⃣ Clear Emulator Cache**
```bash
# Di Windows, buka Command Prompt as Administrator
cd %ANDROID_HOME%\emulator
emulator -list-avds
```

### **3️⃣ Launch Emulator Manual**
```bash
# Pilih salah satu AVD dari list
emulator -avd flutter_emulator -no-snapshot-load
```

### **4️⃣ Alternative: Cold Boot Emulator**
```bash
emulator -avd flutter_emulator -no-snapshot-load -wipe-data
```

### **5️⃣ Check Available Devices**
```bash
flutter devices
flutter emulators
```

## 🌐 **Alternative: Test di Browser Dulu**

Sambil troubleshoot emulator, kita bisa test Facebook authentication di browser:

```bash
flutter run -d chrome --web-browser-flag="--disable-web-security"
```

**Note:** Facebook authentication di web memerlukan konfigurasi domain yang berbeda di Facebook Developer Console.

## 🔍 **Debugging Emulator Issues:**

### **Cek Android SDK:**
```bash
flutter doctor -v
```

### **Cek ANDROID_HOME:**
```bash
echo $ANDROID_HOME  # Linux/Mac
echo %ANDROID_HOME% # Windows
```

### **Cek Hardware Acceleration:**
- Pastikan Intel HAXM atau AMD Processor sudah ter-install
- Enable Virtualization di BIOS
- Check Hyper-V settings di Windows

### **Memory & Disk Space:**
- Minimal 8GB RAM available
- Minimal 4GB disk space free
- Close aplikasi lain yang heavy

## 🎯 **Recommended Next Steps:**

1. **Test di browser dulu** untuk verify Facebook auth
2. **Fix emulator** untuk testing mobile-specific features
3. **Update Flutter** jika diperlukan: `flutter upgrade`

## 📞 **Jika Masih Bermasalah:**

1. Restart komputer
2. Update Android Studio dan SDK
3. Recreate emulator dengan AVD Manager
4. Check Windows Defender/Antivirus blocking emulator