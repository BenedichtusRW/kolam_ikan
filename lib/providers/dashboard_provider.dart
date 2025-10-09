import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../models/control_settings.dart';
import '../services/firebase_service.dart';
import '../services/mqtt_service.dart';
import '../utils/mock_data_generator.dart';

class DashboardProvider with ChangeNotifier {
  // ====== Core State ======
  bool _isTestingMode = false;
  bool _isLoading = false;
  bool _isConnected = false;
  String? _errorMessage;

  Timer? _mockDataTimer;

  // ====== Current Pond & Device ======
  String _currentPondId = 'pond_001';
  String _currentDeviceId = 'ESP32_001';

  // ====== Sensor & Device Data ======
  SensorData? _currentSensorData;
  List<SensorData> _recentData = [];
  ControlSettings? _controlSettings;
  Map<String, dynamic> _deviceStatus = {};

  // ====== Chart Data ======
  String? selectedRange = 'Harian';
  List<double> chartData = [];
  List<String> chartLabels = [];

  // ====== Stream Subscriptions ======
  StreamSubscription? _firebaseSensorSubscription;
  StreamSubscription? _mqttSensorSubscription;
  StreamSubscription? _mqttStatusSubscription;
  StreamSubscription? _controlSettingsSubscription;

  // ====== Getters ======
  SensorData? get currentSensorData => _currentSensorData;
  List<SensorData> get recentData => _recentData;
  ControlSettings? get controlSettings => _controlSettings;
  Map<String, dynamic> get deviceStatus => _deviceStatus;

  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  bool get isTestingMode => _isTestingMode;
  String? get errorMessage => _errorMessage;

  String get currentPondId => _currentPondId;
  String get currentDeviceId => _currentDeviceId;

  // Device states
  bool get isHeaterOn => _deviceStatus['heaterEnabled'] ?? false;
  bool get isAeratorOn => _deviceStatus['aeratorEnabled'] ?? false;
  bool get isCoolerOn => _deviceStatus['coolerEnabled'] ?? false;
  bool get isPhPumpOn => _deviceStatus['phPumpEnabled'] ?? false;
  bool get isAutoMode => _deviceStatus['autoMode'] ?? false;
  bool get isFeederOn => _deviceStatus['feederEnabled'] ?? false;

  // ====== Constructor ======
  DashboardProvider() {
    _initializeServices();
  }

  // ====== Initialization ======
  Future<void> _initializeServices() async {
    _setLoading(true);
    try {
      final mqttConnected = await MqttService.initialize();
      _isConnected = mqttConnected;

      if (mqttConnected) {
        _setupMqttListeners();
        debugPrint('✅ MQTT connected successfully');
      } else {
        debugPrint('⚠️ MQTT connection failed, using Firebase only');
      }

      _setupFirebaseListeners();
      await _loadInitialData();
    } catch (e) {
      _setError('Failed to initialize services: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ====== Firebase & MQTT Setup ======
  void _setupMqttListeners() {
    _mqttSensorSubscription = MqttService.sensorDataStream.listen(
      (data) {
        if (data['pondId'] == _currentPondId) {
          _updateSensorDataFromMqtt(data);
        }
      },
      onError: (err) => debugPrint('MQTT sensor error: $err'),
    );

    _mqttStatusSubscription = MqttService.deviceStatusStream.listen(
      (status) {
        if (status['deviceId'] == _currentDeviceId) {
          _deviceStatus = status;
          notifyListeners();
        }
      },
      onError: (err) => debugPrint('MQTT status error: $err'),
    );
  }

  void _setupFirebaseListeners() {
    _firebaseSensorSubscription =
        FirebaseService.getSensorDataStream(_currentPondId).listen(
      (dataList) {
        if (dataList.isNotEmpty) {
          _recentData = dataList;
          _currentSensorData ??= dataList.first;
          notifyListeners();
        }
      },
      onError: (err) => _setError('Firebase sensor error: $err'),
    );

    _controlSettingsSubscription =
        FirebaseService.getControlSettingsStream(_currentPondId).listen(
      (settingsMap) {
        if (settingsMap != null) {
          _controlSettings = ControlSettings.fromMap(
            settingsMap as Map<String, dynamic>,
            _currentPondId,
          );
          notifyListeners();
        }
      },
      onError: (err) => debugPrint('Control settings error: $err'),
    );
  }

  // ====== Data Update ======
  void _updateSensorDataFromMqtt(Map<String, dynamic> data) {
    try {
      _currentSensorData = SensorData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        temperature: (data['temperature'] ?? 0).toDouble(),
        oxygen: (data['oxygen'] ?? 0).toDouble(),
        phLevel: (data['phLevel'] ?? 7).toDouble(),
        turbidity: (data['turbidity'] ?? 0).toDouble(),
        timestamp: DateTime.now(),
        pondId: data['pondId'] ?? _currentPondId,
        deviceId: data['deviceId'] ?? _currentDeviceId,
        location: data['location'] ?? '',
      );

      _recentData.insert(0, _currentSensorData!);
      if (_recentData.length > 100) {
        _recentData = _recentData.take(100).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing MQTT data: $e');
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final latest = await FirebaseService.getLatestSensorData(_currentPondId);
      if (latest != null) _currentSensorData = latest;

      final settingsMap =
          await FirebaseService.getControlSettings(_currentPondId);
      if (settingsMap != null) {
        _controlSettings = ControlSettings.fromMap(
          settingsMap as Map<String, dynamic>,
          _currentPondId,
        );
      }

      if (_isConnected) {
        await MqttService.requestDeviceStatus(_currentDeviceId);
      }

      loadChartData(selectedRange ?? 'Harian');
      notifyListeners();
    } catch (e) {
      _setError('Failed to load data: $e');
    }
  }

  // ====== Update Control Settings ======
  Future<bool> updateControlSettings(ControlSettings updatedSettings) async {
    try {
      await FirebaseService.updateControlSettings(updatedSettings);

      // Optional: jika ingin juga kirim ke MQTT
      if (_isConnected && MqttService.hasPublishFunction) {
        await MqttService.publishMessage(
            'control/update', updatedSettings.toMap());
      }

      _controlSettings = updatedSettings;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update control settings: $e');
      return false;
    }
  }

  // ====== Chart Data ======
  void loadChartData(String range) {
    selectedRange = range;
    switch (range) {
      case 'Harian':
        chartData = [26.5, 27.0, 27.8, 28.1, 27.6, 26.9, 27.3];
        chartLabels = ['06', '08', '10', '12', '14', '16', '18'];
        break;
      case 'Mingguan':
        chartData = [27.2, 27.4, 27.8, 28.0, 27.9, 27.5, 27.3];
        chartLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        break;
      case 'Tahunan':
        chartData = [
          26.8, 27.0, 27.5, 28.2, 28.0, 27.7,
          27.3, 27.0, 26.9, 27.1, 27.4, 27.8
        ];
        chartLabels = [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        break;
      default:
        chartData = [];
        chartLabels = [];
    }
    notifyListeners();
  }

  // ====== Device Control ======
  Future<bool> _toggleDevice(
    String name,
    bool enabled,
    Future<bool> Function(String, bool) method,
  ) async {
    try {
      if (_isConnected) {
        final success = await method(_currentDeviceId, enabled);
        if (success) {
          _deviceStatus[name] = enabled;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _setError('Failed to control $name: $e');
      return false;
    }
  }

  Future<bool> toggleHeater([bool? enabled]) =>
      _toggleDevice('heaterEnabled', enabled ?? !isHeaterOn, MqttService.setHeater);

  Future<bool> toggleAerator([bool? enabled]) =>
      _toggleDevice('aeratorEnabled', enabled ?? !isAeratorOn, MqttService.setAerator);

  Future<bool> togglePhPump([bool? enabled]) =>
      _toggleDevice('phPumpEnabled', enabled ?? !isPhPumpOn, MqttService.setPHPump);

  Future<bool> toggleFeeder([bool? enabled]) =>
      _toggleDevice('feederEnabled', enabled ?? !isFeederOn, MqttService.setFeeder);

  Future<bool> setAutoMode(bool enabled) =>
      _toggleDevice('autoMode', enabled, MqttService.setAutoMode);

  // ====== Target Controls ======
  Future<bool> setTargetTemperature(double val) async {
    try {
      return _isConnected
          ? await MqttService.setTargetTemperature(_currentDeviceId, val)
          : false;
    } catch (e) {
      _setError('Failed to set target temperature: $e');
      return false;
    }
  }

  Future<bool> setTargetOxygen(double val) async {
    try {
      return _isConnected
          ? await MqttService.setTargetOxygen(_currentDeviceId, val)
          : false;
    } catch (e) {
      _setError('Failed to set target oxygen: $e');
      return false;
    }
  }

  Future<bool> setTargetPH(double val) async {
    try {
      return _isConnected
          ? await MqttService.setTargetPH(_currentDeviceId, val)
          : false;
    } catch (e) {
      _setError('Failed to set target PH: $e');
      return false;
    }
  }

  // ====== Developer / Testing ======
  void loadTestScenario(dynamic scenario) {
    try {
      Map<String, dynamic> data = scenario is String
          ? jsonDecode(scenario)
          : Map<String, dynamic>.from(scenario);

      _currentSensorData = SensorData(
        id: DateTime.now().toString(),
        temperature: data['temperature'] ?? 27.0,
        oxygen: data['oxygen'] ?? 6.0,
        phLevel: data['phLevel'] ?? 7.0,
        turbidity: data['turbidity'] ?? 10.0,
        timestamp: DateTime.now(),
        pondId: _currentPondId,
        deviceId: _currentDeviceId,
        location: 'Test Lab',
      );

      notifyListeners();
      debugPrint('🧪 Test scenario loaded successfully');
    } catch (e) {
      _setError('Failed to load test scenario: $e');
    }
  }

  // ====== Utility ======
  Future<void> refreshData() async {
    _setLoading(true);
    try {
      await _loadInitialData();
      if (_isConnected) await MqttService.requestDeviceStatus(_currentDeviceId);
    } catch (e) {
      _setError('Failed to refresh data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> switchPond(String newPondId, String newDeviceId) async {
    if (newPondId == _currentPondId) return;
    _cancelSubscriptions();
    _currentPondId = newPondId;
    _currentDeviceId = newDeviceId;
    _currentSensorData = null;
    _recentData.clear();
    _controlSettings = null;
    _deviceStatus.clear();
    _setupFirebaseListeners();
    await _loadInitialData();
    notifyListeners();
  }

  void enableTestingMode() {
    _isTestingMode = true;
    _isConnected = true;
    _generateMockData();
    _startMockDataTimer();
    notifyListeners();
    debugPrint('🧪 Testing mode enabled');
  }

  void disableTestingMode() {
    _isTestingMode = false;
    _mockDataTimer?.cancel();
    _initializeServices();
    notifyListeners();
    debugPrint('🔌 Testing mode disabled');
  }

  void _generateMockData() {
    _currentSensorData =
        MockDataGenerator.generateCurrentMockData(_currentPondId);
    _recentData = MockDataGenerator.generateDailyMockData(
      date: DateTime.now(),
      pondId: _currentPondId,
    );
    _deviceStatus = {
      'heaterEnabled': false,
      'aeratorEnabled': true,
      'coolerEnabled': false,
      'phPumpEnabled': false,
      'autoMode': true,
      'feederEnabled': false,
    };
    loadChartData('Harian');
  }

  void _startMockDataTimer() {
    _mockDataTimer?.cancel();
    _mockDataTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (_isTestingMode) {
        _currentSensorData =
            MockDataGenerator.generateCurrentMockData(_currentPondId);
        notifyListeners();
      }
    });
  }

  // ====== Error & State ======
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    debugPrint('DashboardProvider Error: $msg');
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _firebaseSensorSubscription?.cancel();
    _mqttSensorSubscription?.cancel();
    _mqttStatusSubscription?.cancel();
    _controlSettingsSubscription?.cancel();
    _mockDataTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void initialize(String pondId) {}
}
