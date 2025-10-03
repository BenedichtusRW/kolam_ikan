# Kolam Ikan IoT Monitoring System

## Arsitektur Sistem

Sistem monitoring kolam ikan ini menggunakan arsitektur hybrid antara Cloud (Firebase) dan Local Container untuk memastikan reliability dan real-time monitoring.

### 🏗️ Arsitektur Overview

```
📱 Mobile App (Flutter) 
    ↕️
🌐 Firebase Cloud (Firestore, Auth, Storage)
    ↕️
🐳 Local Container Stack
    ├── 🦟 MQTT Broker (Mosquitto)
    ├── 📊 Time-Series DB (InfluxDB)
    ├── 🚀 Backend API (Node.js)
    ├── 🗄️ Cache (Redis)
    └── 📈 Monitoring (Grafana)
    ↕️
🔧 IoT Hardware (ESP32/Arduino + Sensors)
```

### 📋 Fitur Sistem

#### 👤 User Features:
- 📊 Real-time monitoring suhu, oksigen, pH
- 📈 Grafik dan chart data historis
- 🔔 Notifikasi alert kondisi abnormal
- 📱 Laporan masalah dengan foto
- 📋 History data harian/mingguan/bulanan

#### 👨‍💼 Admin Features:
- 🎛️ Manual control perangkat (heater, aerator, pH pump)
- ⚡ Automatic control berdasarkan threshold
- ⏰ Scheduled control berdasarkan waktu
- 🔧 Management setting target values
- 📞 Response laporan user
- 📊 Analytics dan reporting

### 🛠️ Tech Stack

#### Mobile App (Flutter):
- **State Management**: Provider
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Real-time**: MQTT + Firebase Streams
- **Charts**: FL Chart, Syncfusion
- **Local Storage**: SharedPreferences

#### Backend Container:
- **API Server**: Node.js + Express
- **Message Broker**: MQTT (Mosquitto)
- **Time-Series DB**: InfluxDB
- **Cache**: Redis
- **Monitoring**: Grafana
- **Container**: Docker + Docker Compose

#### Cloud Services:
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Push Notifications**: Firebase Cloud Messaging

## 🚀 Setup Instructions

### 1. Prerequisites
```bash
# Install Docker dan Docker Compose
# Install Flutter SDK
# Setup Firebase Project
```

### 2. Firebase Setup
1. Buat project Firebase baru
2. Enable Firestore, Authentication, Storage
3. Download `google-services.json` untuk Android
4. Setup Firebase Admin SDK untuk backend

### 3. Container Setup
```bash
# Clone repository
git clone <repository-url>
cd kolam_ikan

# Setup environment
cp docker/backend/.env.example docker/backend/.env
# Edit .env dengan konfigurasi Firebase

# Start containers
cd docker
docker-compose up -d

# Check container status
docker-compose ps
```

### 4. Mobile App Setup
```bash
# Install dependencies
flutter pub get

# Setup Firebase configuration
# Copy google-services.json to android/app/

# Run app
flutter run
```

### 📡 MQTT Topics Structure

```
kolam/
├── sensor/
│   └── data          # Sensor readings from hardware
├── control/
│   └── command       # Control commands to hardware
├── device/
│   └── status        # Device status updates
└── alert             # Emergency alerts
```

### 📊 Data Models

#### Sensor Data:
```json
{
  "deviceId": "ESP32_001",
  "pondId": "pond_001",
  "location": "Kolam A",
  "temperature": 25.5,
  "oxygen": 6.2,
  "phLevel": 7.1,
  "timestamp": "2025-10-03T10:30:00Z"
}
```

#### Control Command:
```json
{
  "deviceId": "ESP32_001",
  "command": "SET_HEATER",
  "enabled": true,
  "timestamp": "2025-10-03T10:30:00Z"
}
```

### 🔧 Hardware Requirements

#### IoT Device Specs:
- **Microcontroller**: ESP32 atau Arduino dengan WiFi
- **Sensors**:
  - Temperature: DS18B20 atau DHT22
  - Dissolved Oxygen: DO sensor probe
  - pH: pH sensor probe
- **Actuators**:
  - Relay untuk heater/cooler
  - Relay untuk aerator
  - Relay untuk pH dosing pump

#### Sensor Wiring:
```
ESP32 Pinout:
├── GPIO 4  → Temperature sensor (DS18B20)
├── GPIO 32 → DO sensor (analog)
├── GPIO 33 → pH sensor (analog)
├── GPIO 25 → Heater relay
├── GPIO 26 → Aerator relay
└── GPIO 27 → pH pump relay
```

### 📈 Monitoring & Alerts

#### Normal Ranges:
- **Temperature**: 20-30°C
- **Dissolved Oxygen**: >5 mg/L
- **pH Level**: 6.5-8.5

#### Alert Levels:
- **Warning**: Values approaching limits
- **Critical**: Values outside safe range
- **Emergency**: Extreme values requiring immediate action

### 🔐 Security

#### Authentication:
- Firebase Authentication untuk mobile app
- API Key authentication untuk IoT devices
- JWT tokens untuk backend API

#### Network Security:
- MQTT dengan username/password
- HTTPS untuk all API calls
- Firestore security rules

### 📱 Mobile App Screens

1. **Login Screen**: Authentication user/admin
2. **Dashboard**: Real-time monitoring gauges
3. **Charts Screen**: Historical data visualization
4. **History Screen**: Data logs dan trends
5. **Control Screen**: Manual device control (admin only)
6. **Settings Screen**: Auto control configuration
7. **Reports Screen**: User report submission
8. **Alerts Screen**: Notification management

### 🎯 Development Roadmap

#### Phase 1: Basic Monitoring ✅
- [x] Sensor data collection
- [x] Real-time display
- [x] Basic alerts

#### Phase 2: Control System ⏳
- [ ] Manual device control
- [ ] Automatic control logic
- [ ] Schedule-based control

#### Phase 3: Advanced Features 📋
- [ ] Machine learning predictions
- [ ] Advanced analytics
- [ ] Multi-pond management
- [ ] User role management

### 🤝 Team Responsibilities

#### Mobile Developer (Android):
- Flutter app development
- UI/UX implementation
- Firebase integration
- MQTT client integration

#### Backend Developer:
- Node.js API server
- MQTT broker configuration
- Database optimization
- Container orchestration

#### Hardware Developer:
- IoT device programming
- Sensor calibration
- Hardware assembly
- Field testing

#### QA/Testing:
- Integration testing
- Performance testing
- User acceptance testing
- Documentation

## 📞 Support

Untuk pertanyaan atau masalah, silakan buat issue di repository atau hubungi tim development.

## 📄 License

MIT License - see LICENSE file for details.