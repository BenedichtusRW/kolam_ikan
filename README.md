# Kolam Ikan Monitor - Flutter Application

Aplikasi monitoring kolam ikan berbasis IoT menggunakan Flutter dengan Firebase sebagai backend.

## 🏗️ Struktur Proyek

```
lib/
├── models/              # Data models
│   ├── sensor_data.dart
│   └── user_profile.dart
├── providers/           # State management (Provider pattern)
│   ├── auth_provider.dart
│   ├── dashboard_provider.dart
│   └── history_provider.dart
├── screens/             # UI screens
│   ├── login/
│   │   └── login_screen.dart
│   ├── dashboard/
│   │   ├── user_dashboard_screen.dart
│   │   └── admin_dashboard_screen.dart
│   ├── history/
│   │   └── history_screen.dart
│   └── settings/
│       └── control_settings_screen.dart
├── widgets/             # Custom reusable widgets
│   ├── data_card.dart
│   └── gauge_indicator.dart
├── services/            # External service integrations
│   └── firestore_service.dart
├── utils/               # Utilities and helpers
│   └── routes.dart
└── main.dart           # Entry point
```

## 🚀 Setup dan Instalasi

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Setup Firebase (TODO)

1. Buat project baru di [Firebase Console](https://console.firebase.google.com/)
2. Aktifkan Authentication dan Firestore
3. Download file konfigurasi:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. Uncomment baris Firebase initialization di `main.dart`

### 3. Jalankan Aplikasi

```bash
flutter run
```

## 📱 Fitur Aplikasi

### User Dashboard
- ✅ Real-time monitoring suhu dan oksigen air
- ✅ Gauge indicators untuk visualisasi data
- ✅ History/riwayat data sensor
- 🔄 Grafik tren (TODO: implementasi dengan fl_chart)

### Admin Dashboard
- ✅ Semua fitur User Dashboard
- ✅ Kontrol manual aerator dan feeder
- ✅ Pengaturan kontrol otomatis
- 🔄 Threshold settings (TODO: implementasi logika otomatis)

### Authentication
- ✅ Login dengan email/password
- 🔄 Firebase Authentication integration (TODO)
- ✅ Role-based access (user/admin)

## 🛠️ Dependencies

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  
  # State Management
  provider: ^6.1.2
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  
  # Charts
  fl_chart: ^0.66.2
  
  # Utilities
  intl: ^0.19.0
```

## 🔧 Todo List

### High Priority
- [ ] Setup Firebase configuration
- [ ] Implement Firebase Authentication
- [ ] Implement real-time Firestore data sync
- [ ] Add chart visualization dengan fl_chart

### Medium Priority
- [ ] Implementasi automatic control logic
- [ ] Push notifications untuk alert
- [ ] Offline data caching
- [ ] Data export functionality

### Low Priority
- [ ] Dark theme support
- [ ] Internationalization (i18n)
- [ ] Unit tests
- [ ] Integration tests

## 🎨 Design Pattern

Aplikasi ini menggunakan:
- **Provider Pattern** untuk state management
- **Repository Pattern** di FirestoreService
- **Separation of Concerns** dengan struktur folder yang jelas
- **Material Design** untuk UI consistency

## 📊 Database Structure (Firestore)

### Collections

#### `users`
```json
{
  "uid": "string",
  "email": "string",
  "name": "string", 
  "role": "user|admin",
  "pondId": "string?" // null for admin
}
```

#### `sensor_data`
```json
{
  "temperature": "number",
  "oxygen": "number",
  "timestamp": "number",
  "pondId": "string"
}
```

#### `device_status`
```json
{
  "aerator": "boolean",
  "feeder": "boolean"
}
```

## 🔐 Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Sensor data access based on pond assignment
    match /sensor_data/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Device control only for admins
    match /device_status/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 📱 Screenshots

*Screenshots akan ditambahkan setelah implementasi UI selesai*

## 🤝 Contributing

1. Fork repository
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
**Note**: Aplikasi ini masih dalam tahap development. Beberapa fitur masih berupa placeholder dan memerlukan implementasi lebih lanjut.
