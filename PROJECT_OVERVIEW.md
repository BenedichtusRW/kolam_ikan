# Fish Pond Monitoring System (Kolam Ikan)

## 📱 Multi-Platform IoT Monitoring System

Sistem monitoring kolam ikan berbasis IoT yang mendukung **Mobile (Android/iOS)** dan **Web Dashboard** dengan role-based authentication untuk Admin dan User.

---

## 🏗️ Project Architecture

### Platform Support
- **📱 Mobile App**: Android/iOS dengan Flutter
- **💻 Web Dashboard**: Desktop-optimized interface
- **🌐 Backend**: Firebase (Authentication, Firestore, Real-time)
- **⚡ IoT Integration**: ESP32 sensors untuk monitoring real-time

### User Roles
- **👤 Regular User**: View-only access, personal pond monitoring
- **👨‍💼 Admin**: Full control, multi-pond management, user management

---

## 🎯 Features Overview

### 📊 Real-time Monitoring
- **Temperature**: Water temperature with safe range alerts
- **pH Level**: Acidity/alkalinity monitoring
- **Oxygen (DO)**: Dissolved oxygen levels
- **Turbidity**: Water clarity measurement

### 📈 Data Visualization
- **Gauges**: Real-time circular gauges for instant readings
- **Charts**: 24-hour trend analysis with fl_chart
- **Digital Display**: Precise numerical readings
- **Historical Data**: Hourly data logging and analytics

### 🎛️ Control Systems
- **Manual Control**: Direct pump/actuator operation (Admin only)
- **Automatic Mode**: AI-based system control
- **Alerts & Notifications**: Real-time problem alerts
- **System Status**: Equipment health monitoring

---

## 📂 Project Structure

```
kolam_ikan/
├── lib/
│   ├── main.dart                      # App entry point with role-based routing
│   ├── models/                        # Data models
│   │   ├── sensor_data.dart          # IoT sensor data structure
│   │   ├── user_profile.dart         # User profile & role management
│   │   └── control_system.dart       # Equipment control models
│   ├── providers/                     # State management
│   │   ├── auth_provider.dart        # Authentication & user management
│   │   ├── dashboard_provider.dart   # Real-time data provider
│   │   ├── history_provider.dart     # Historical data management
│   │   └── control_provider.dart     # Equipment control
│   ├── screens/
│   │   ├── login/                    # Authentication screens
│   │   ├── navigation/               # Mobile navigation
│   │   │   └── main_navigation_screen.dart  # Bottom nav + responsive web
│   │   ├── dashboard/                # Dashboard screens
│   │   │   ├── admin_dashboard_screen.dart       # Mobile admin
│   │   │   ├── admin_web_dashboard_screen.dart   # Web admin dashboard
│   │   │   └── user_web_dashboard_screen.dart    # Web user dashboard
│   │   ├── monitoring/               # Real-time monitoring
│   │   ├── history/                  # Historical data & reports
│   │   ├── profile/                  # User profile management
│   │   └── control/                  # Equipment control (Admin only)
│   ├── services/                     # Backend services
│   │   ├── firebase_service.dart     # Firebase integration
│   │   ├── iot_service.dart         # ESP32 communication
│   │   └── notification_service.dart # Push notifications
│   ├── utils/                        # Utilities & constants
│   └── widgets/                      # Reusable components
└── firebase/                         # Firebase configuration
```

---

## 🎨 Design System

### Color Palette
```dart
Primary Color: Color.fromARGB(255, 57, 73, 171)  // Navy blue
Secondary Colors:
  - Temperature: Colors.red (Heat indicators)
  - pH Level: Primary blue (Water quality)
  - Oxygen: Colors.green (Good levels)
  - Turbidity: Colors.orange (Clarity warnings)
```

### Responsive Design
- **Mobile**: Bottom navigation, mobile-optimized cards
- **Web**: Sidebar navigation, desktop-optimized layout
- **Adaptive Components**: Automatic layout switching based on screen size

---

## 🔧 Technical Implementation

### State Management
```dart
// Provider pattern for real-time data
Consumer<DashboardProvider>(
  builder: (context, dashboardProvider, child) {
    return SensorGaugeWidget(
      value: dashboardProvider.currentSensorData?.temperature,
      min: 0, max: 40,
      ranges: [safe, warning, danger],
    );
  },
)
```

### Real-time Data Flow
1. **ESP32 Sensors** → Firebase Firestore
2. **Firebase** → Flutter Provider
3. **Provider** → UI Components
4. **Auto-refresh** every 30 seconds

### Role-based Routing
```dart
// Automatic platform & role detection
if (authProvider.userProfile?.isAdmin == true) {
  return kIsWeb ? AdminWebDashboardScreen() : AdminDashboardScreen();
} else {
  return kIsWeb ? UserWebDashboardScreen() : MainNavigationScreen();
}
```

---

## 📱 Mobile App Features

### Bottom Navigation
- **🏠 Dashboard**: Overview & quick stats
- **🔍 Search**: Pond search & filtering
- **📊 History**: Data history & analytics  
- **👤 Profile**: User settings & logout

### Mobile-specific Optimizations
- Touch-friendly interface
- Portrait/landscape support
- Mobile notifications
- Offline data caching

---

## 💻 Web Dashboard Features

### Admin Web Dashboard
- **📊 Dashboard Overview**: Multi-pond monitoring
- **📈 Real-time Monitoring**: Live sensor data
- **👥 User Management**: Add/edit users & permissions
- **📋 Reports & Analytics**: Advanced reporting tools
- **🎛️ Control Center**: Equipment control panel
- **📚 History Data**: Detailed historical analysis
- **⚙️ System Settings**: Configuration management

### User Web Dashboard  
- **🏠 My Dashboard**: Personal pond overview
- **📊 Live Monitoring**: Real-time sensor readings
- **📈 History & Reports**: Personal data history
- **🔔 Alerts & Notifications**: Personal alerts
- **👤 My Profile**: Profile management

---

## 🛡️ Security & Permissions

### Authentication
- Firebase Authentication
- Email/password login
- Role verification
- Session management

### Authorization Levels
```dart
// User permissions
class UserRole {
  static const String admin = 'admin';
  static const String user = 'user';
  
  // Admin capabilities
  - Full system control
  - User management
  - Multi-pond access
  - Equipment control
  
  // User capabilities  
  - View assigned pond only
  - Personal data access
  - Read-only monitoring
  - Personal alerts
}
```

---

## 🚀 Getting Started

### Prerequisites
```bash
flutter --version  # Flutter 3.0+
firebase --version # Firebase CLI
```

### Installation
```bash
# Clone repository
git clone <repository-url>

# Install dependencies
flutter pub get

# Configure Firebase
firebase login
firebase init

# Run on mobile
flutter run

# Run on web
flutter run -d chrome
```

### Firebase Setup
1. Create Firebase project
2. Enable Authentication (Email/Password)
3. Create Firestore database
4. Configure security rules
5. Add platform configurations

---

## 📊 Data Models

### Sensor Data Structure
```dart
class SensorData {
  final String id;
  final String pondId;
  final double temperature;    // °C
  final double phLevel;        // pH 0-14
  final double oxygen;         // mg/L
  final double turbidity;      // NTU
  final DateTime timestamp;
  final String status;         // normal/warning/critical
}
```

### Control System
```dart
class ControlSystem {
  final String equipmentId;
  final String type;           // pump/aerator/feeder
  final bool isActive;
  final String mode;           // manual/automatic
  final DateTime lastAction;
  final Map<String, dynamic> settings;
}
```

---

## 🔗 IoT Integration

### ESP32 Configuration
```cpp
// Sensor readings sent to Firebase
void sendSensorData() {
  float temp = readTemperature();
  float ph = readPH();
  float oxygen = readOxygen();
  float turbidity = readTurbidity();
  
  // Send to Firebase via REST API
  sendToFirebase(temp, ph, oxygen, turbidity);
}
```

### Data Sync Schedule
- **Real-time**: Critical alerts (immediate)
- **Regular**: Sensor readings (30 seconds)
- **Hourly**: Data aggregation & reports
- **Daily**: System health checks

---

## 🎯 Professor Requirements Compliance

✅ **Data Display Types**
- Gauges (SfRadialGauge)
- Digital displays (precise values)
- Charts (fl_chart line graphs)

✅ **Role-based Access**
- Admin: Full control + viewing
- User: View-only access

✅ **Control Systems**
- Manual control (Admin only)
- Automatic mode (AI-based)

✅ **Platform Support**
- Mobile app (Android/iOS)
- Web dashboard (Desktop-optimized)

✅ **Real-time Features**
- Live sensor monitoring
- Instant alerts & notifications
- Equipment status updates

✅ **Data Management**
- Hourly data logging
- Historical analytics
- Report generation

---

## 🔄 Development Workflow

### Testing Strategy
```bash
# Unit tests
flutter test

# Integration tests  
flutter test integration_test/

# Web testing
flutter run -d chrome --web-port 8080

# Mobile testing
flutter run -d android
```

### Deployment
- **Mobile**: Play Store / App Store
- **Web**: Firebase Hosting
- **Backend**: Firebase Cloud Functions

---

## 🚧 Future Enhancements

### Phase 2 Features
- [ ] AI-powered predictive analytics
- [ ] Multi-language support  
- [ ] Offline mode with sync
- [ ] Advanced reporting tools
- [ ] Integration with external APIs

### Phase 3 Features
- [ ] Machine learning optimization
- [ ] Video monitoring integration
- [ ] Advanced alerting rules
- [ ] Third-party integrations

---

## 📞 Support & Maintenance

### Code Standards
- Dart/Flutter best practices
- Provider pattern for state management
- Responsive design principles
- Security-first development

### Documentation
- Inline code documentation
- API documentation
- User manual
- Admin guide

---

**🐟 Happy Fish Monitoring! 🐟**

---

*Developed for Proyek Pengembangan Perangkat Lunak*  
*Semester 5 - IoT Fish Pond Monitoring System*