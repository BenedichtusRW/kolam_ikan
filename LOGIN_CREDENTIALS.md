# 🔐 Login Credentials - Kolam Ikan IoT

## 📋 Default Test Accounts

### 👤 Administrator Account
```
Email:    admin@kolamikan.com
Password: admin123
Role:     Admin
Access:   Full system access
```

**Permissions:**
- ✅ View all data
- ✅ Control devices
- ✅ Manage users
- ✅ Generate reports
- ✅ System settings

---

### 👤 Regular User Account
```
Email:    user@kolamikan.com
Password: user123
Role:     User
Access:   Limited access
```

**Permissions:**
- ✅ View assigned pond data
- ✅ Control devices in assigned ponds
- ❌ Manage users
- ❌ Generate reports
- ❌ System settings

---

## 🚀 Quick Login (Development)

Di login screen, tap pada hint box untuk auto-fill credentials:

1. **Admin Login** - Tap kotak biru "Admin" untuk auto-fill
2. **User Login** - Tap kotak biru "User" untuk auto-fill

---

## 🔧 Setup Instructions

### 1. Create Firebase Project
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Buat project baru: `kolam-ikan-iot`
3. Enable Authentication, Firestore, Storage

### 2. Setup Authentication
```bash
cd firebase
npm install
node create-test-users.js
```

### 3. Update Configuration
Edit `firebase/firebase-config.js` dengan data project Anda:
```javascript
const firebaseConfig = {
  web: {
    apiKey: "AIza...",
    authDomain: "kolam-ikan-iot.firebaseapp.com",
    projectId: "kolam-ikan-iot",
    // ... etc
  }
};
```

---

## 📱 Mobile App Testing

1. **Start Flutter App:**
```bash
flutter run
```

2. **Login dengan salah satu akun:**
   - Admin: `admin@kolamikan.com` / `admin123`
   - User: `user@kolamikan.com` / `user123`

3. **Navigation:**
   - Admin → `AdminDashboardScreen`
   - User → `UserDashboardScreen`

---

## 🔍 Troubleshooting

### Firebase Not Configured
```
Error: Firebase project not configured
```
**Solution:** Update `firebase-config.js` dengan credentials project Anda

### User Not Found
```
Error: User not found
```
**Solution:** Run `node create-test-users.js` untuk create default users

### Authentication Error
```
Error: Authentication failed
```
**Solution:** Check Firebase Authentication is enabled di console

---

## 🛡️ Production Notes

⚠️ **WARNING:** Credentials ini hanya untuk development/testing!

Untuk production:
1. Hapus default credentials
2. Implement proper user registration
3. Use secure password policies
4. Enable Firebase security rules
5. Setup email verification

---

**Last Updated:** October 2025  
**Environment:** Development/Testing Only