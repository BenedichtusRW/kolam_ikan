# 🚀 Setup Guide - Kolam Ikan IoT Project

## 📋 Prerequisites

### Software yang Dibutuhkan:
- **Docker Desktop** (Windows/Mac) atau **Docker Engine** (Linux)
- **Node.js** (v16 atau lebih baru)
- **Flutter SDK** (3.0 atau lebih baru)
- **Firebase CLI** (`npm install -g firebase-tools`)
- **Git**

### Hardware yang Dibutuhkan:
- **ESP32** atau Arduino dengan WiFi
- **Sensor**: Temperature (DS18B20), DO sensor, pH sensor
- **Actuators**: Relay modules untuk heater, aerator, pH pump

---

## 🔧 Setup Development Environment

### 1. Clone Repository
```bash
git clone <repository-url>
cd kolam_ikan
```

### 2. Setup Firebase

#### A. Buat Firebase Project
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Buat project baru dengan nama `kolam-ikan-iot`
3. Enable **Authentication**, **Firestore**, **Storage**
4. Download **Service Account Key** (JSON file)

#### B. Konfigurasi Firebase
```bash
cd firebase
npm install
```

Edit `firebase/firebase-config.js` dengan data project Anda:
```javascript
const firebaseConfig = {
  web: {
    apiKey: "AIza...",           // Dari Firebase Console
    authDomain: "kolam-ikan-iot.firebaseapp.com",
    projectId: "kolam-ikan-iot",
    storageBucket: "kolam-ikan-iot.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef",
    measurementId: "G-XXXXXXXXXX"
  },
  admin: {
    // Copy paste dari Service Account Key JSON
    type: "service_account",
    project_id: "kolam-ikan-iot",
    private_key_id: "...",
    private_key: "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
    client_email: "firebase-adminsdk-...@kolam-ikan-iot.iam.gserviceaccount.com",
    // ... dst
  }
};
```

#### C. Setup Firebase Data & Rules
```bash
# Setup initial data
node setup-firebase.js

# Deploy security rules
firebase login
firebase deploy --only firestore:rules

# Update Flutter config
node update-flutter-config.js
```

### 3. Setup Docker Container

#### A. Windows (PowerShell)
```powershell
# Jalankan setup script
.\setup_docker.ps1
```

#### B. Linux/Mac
```bash
# Make script executable
chmod +x setup_docker.sh

# Run setup
./setup_docker.sh
```

#### C. Manual Setup
```bash
cd docker

# Copy environment file
cp backend/.env.example backend/.env

# Edit dengan konfigurasi Firebase
nano backend/.env

# Start containers
docker-compose up -d

# Check status
docker-compose ps
```

### 4. Setup Flutter App

#### A. Install Dependencies
```bash
flutter pub get
```

#### B. Setup Firebase untuk Flutter
1. Copy `google-services.json` ke `android/app/`
2. Copy `GoogleService-Info.plist` ke `ios/Runner/` (jika ada iOS)

#### C. Update Firebase Config
```bash
# Update Flutter config dari JavaScript config
cd firebase
node update-flutter-config.js
```

#### D. Test Flutter App
```bash
flutter test
flutter run
```

---

## 🌐 Service URLs

Setelah setup berhasil, services tersedia di:

| Service | URL | Login |
|---------|-----|-------|
| 📊 Grafana Dashboard | http://localhost:3001 | admin/admin123 |
| 🗄️  InfluxDB | http://localhost:8086 | admin/admin123 |
| 🚀 API Server | http://localhost:3000 | - |
| 🦟 MQTT Broker | localhost:1883 | - |
| 🗄️  Redis | localhost:6379 | - |

---

## 🔧 Hardware Setup

### ESP32 Configuration
```cpp
// WiFi Configuration
const char* ssid = "your-wifi-name";
const char* password = "your-wifi-password";

// MQTT Configuration  
const char* mqtt_server = "192.168.1.100";  // IP container Anda
const int mqtt_port = 1883;
const char* mqtt_client_id = "ESP32_001";

// Topics
const char* sensor_topic = "kolam/sensor/data";
const char* control_topic = "kolam/control/command";
const char* status_topic = "kolam/device/status";
```

### Sensor Wiring
```
ESP32 Pinout:
├── GPIO 4  → DS18B20 (Temperature)
├── GPIO 32 → DO Sensor (Analog)
├── GPIO 33 → pH Sensor (Analog) 
├── GPIO 25 → Heater Relay
├── GPIO 26 → Aerator Relay
└── GPIO 27 → pH Pump Relay
```

---

## 🧪 Testing

### 1. Test Docker Services
```bash
# Check all containers
docker-compose ps

# Check logs
docker-compose logs api_server
docker-compose logs mosquitto

# Test API
curl http://localhost:3000/health
```

### 2. Test MQTT
```bash
# Install MQTT client (untuk testing)
npm install -g mqtt

# Subscribe to sensor data
mqtt sub -t 'kolam/sensor/data' -h localhost

# Publish test data
mqtt pub -t 'kolam/sensor/data' -h localhost -m '{"temperature":25.5,"oxygen":6.2,"phLevel":7.1,"pondId":"pond_001","deviceId":"ESP32_001","timestamp":"2025-10-03T10:30:00Z"}'
```

### 3. Test Flutter App
```bash
flutter test
flutter run --debug
```

### 4. Test Firebase Connection
```bash
cd firebase

# Test Firebase connection
node -e "
const admin = require('./setup-firebase.js').admin;
admin.firestore().collection('ponds').get()
  .then(() => console.log('✅ Firebase connected'))
  .catch(err => console.log('❌ Firebase error:', err));
"
```

---

## 🚨 Troubleshooting

### Docker Issues
```bash
# Restart containers
docker-compose restart

# Rebuild containers
docker-compose up --build

# Check logs
docker-compose logs -f [service_name]

# Reset everything
docker-compose down -v
docker system prune -f
```

### MQTT Issues
```bash
# Check MQTT broker logs
docker-compose logs mosquitto

# Test with mosquitto client
docker exec -it kolam_mqtt mosquitto_pub -t test -m "hello"
```

### Firebase Issues
```bash
# Check Firebase config
firebase projects:list

# Test Firestore rules
firebase emulators:start --only firestore

# Deploy rules again
firebase deploy --only firestore:rules
```

### Flutter Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check Firebase config
flutter packages pub run build_runner build
```

---

## 📱 Mobile App Development

### 1. Development Mode
```bash
# Run dengan hot reload
flutter run --debug

# Test di emulator
flutter emulators --launch <emulator_id>
flutter run
```

### 2. Production Build
```bash
# Build APK
flutter build apk --release

# Build AAB untuk Play Store
flutter build appbundle --release
```

---

## 📊 Monitoring & Maintenance

### 1. Monitor Services
- **Grafana**: Dashboard untuk monitoring sensor data
- **Docker Stats**: `docker stats` untuk monitoring container
- **Logs**: `docker-compose logs -f` untuk real-time logs

### 2. Backup
```bash
# Backup Firestore data
cd firebase
node setup-firebase.js --backup

# Backup Docker volumes
docker run --rm -v kolam_data:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz /data
```

### 3. Updates
```bash
# Update Docker images
docker-compose pull
docker-compose up -d

# Update Flutter dependencies
flutter pub upgrade

# Update Firebase config
cd firebase
node update-flutter-config.js
```

---

## 👥 Team Collaboration

### File Structure untuk Kolaborasi:
```
kolam_ikan/
├── 📱 lib/                    # Flutter (Mobile Developer)
├── 🐳 docker/                 # Backend & Container (Backend Developer)
├── 🔥 firebase/               # Firebase Config (Shared)
├── 📄 docs/                   # Documentation (All)
└── 🔧 hardware/               # ESP32 Code (Hardware Developer)
```

### Git Workflow:
1. **Firebase**: Edit `firebase/firebase-config.js` lalu run `node update-flutter-config.js`
2. **Mobile**: Work di `lib/` folder
3. **Backend**: Work di `docker/backend/` 
4. **Hardware**: Work di `hardware/` folder

---

## 🎯 Next Steps

1. ✅ Setup development environment
2. 📱 Implement Flutter UI screens
3. 🔧 Program ESP32 dengan MQTT
4. 🧪 Integration testing
5. 🚀 Production deployment

**Happy Coding! 🚀**