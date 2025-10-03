import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../models/control_settings.dart';
import '../services/firebase_service.dart';
import '../services/mqtt_service.dart';

class DashboardProvider with ChangeNotifier {
  // Current data
  SensorData? _currentSensorData;
  List<SensorData> _recentData = [];
  ControlSettings? _controlSettings;
  Map<String, dynamic> _deviceStatus = {};
  
  // Loading states
  bool _isLoading = false;
  String? _errorMessage;
  bool _isConnected = false;
  
  // Stream subscriptions
  StreamSubscription? _firebaseSensorSubscription;
  StreamSubscription? _mqttSensorSubscription;
  StreamSubscription? _mqttStatusSubscription;
  StreamSubscription? _controlSettingsSubscription;
  
  // Current pond ID
  String _currentPondId = 'pond_001';
  String _currentDeviceId = 'ESP32_001';

  // Getters
  SensorData? get currentSensorData => _currentSensorData;
  List<SensorData> get recentData => _recentData;
  ControlSettings? get controlSettings => _controlSettings;
  Map<String, dynamic> get deviceStatus => _deviceStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _isConnected;
  String get currentPondId => _currentPondId;
  String get currentDeviceId => _currentDeviceId;

  // Device control getters
  bool get isHeaterOn => _deviceStatus['heaterEnabled'] ?? false;
  bool get isAeratorOn => _deviceStatus['aeratorEnabled'] ?? false;
  bool get isCoolerOn => _deviceStatus['coolerEnabled'] ?? false;
  bool get isPhPumpOn => _deviceStatus['phPumpEnabled'] ?? false;
  bool get isAutoMode => _deviceStatus['autoMode'] ?? false;
  bool get isFeederOn => _deviceStatus['feederEnabled'] ?? false;

  // Constructor
  DashboardProvider() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _setLoading(true);
    try {
      // Initialize MQTT connection
      final mqttConnected = await MqttService.initialize();
      _isConnected = mqttConnected;
      
      if (mqttConnected) {
        _setupMqttListeners();
        print('MQTT connected successfully');
      } else {
        print('MQTT connection failed, using Firebase only');
      }
      
      // Setup Firebase listeners
      _setupFirebaseListeners();
      
      // Load initial data
      await _loadInitialData();
      
    } catch (e) {
      _setError('Failed to initialize services: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setupMqttListeners() {
    // Listen to real-time sensor data from MQTT
    _mqttSensorSubscription = MqttService.sensorDataStream.listen(
      (data) {
        if (data['pondId'] == _currentPondId) {
          _updateSensorDataFromMqtt(data);
        }
      },
      onError: (error) {
        print('MQTT sensor data error: $error');
      },
    );

    // Listen to device status updates
    _mqttStatusSubscription = MqttService.deviceStatusStream.listen(
      (status) {
        if (status['deviceId'] == _currentDeviceId) {
          _deviceStatus = status;
          notifyListeners();
        }
      },
      onError: (error) {
        print('MQTT device status error: $error');
      },
    );
  }

  void _setupFirebaseListeners() {
    // Listen to sensor data from Firebase
    _firebaseSensorSubscription = FirebaseService.getSensorDataStream(_currentPondId).listen(
      (dataList) {
        if (dataList.isNotEmpty) {
          _recentData = dataList;
          if (_currentSensorData == null) {
            // Use Firebase data if no MQTT data available
            _currentSensorData = dataList.first;
          }
          notifyListeners();
        }
      },
      onError: (error) {
        _setError('Firebase sensor data error: $error');
      },
    );

    // Listen to control settings
    _controlSettingsSubscription = FirebaseService.getControlSettingsStream(_currentPondId).listen(
      (settings) {
        _controlSettings = settings;
        notifyListeners();
      },
      onError: (error) {
        print('Control settings error: $error');
      },
    );
  }

  void _updateSensorDataFromMqtt(Map<String, dynamic> data) {
    try {
      _currentSensorData = SensorData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        temperature: data['temperature']?.toDouble() ?? 0.0,
        oxygen: data['oxygen']?.toDouble() ?? 0.0,
        phLevel: data['phLevel']?.toDouble() ?? 7.0,
        timestamp: DateTime.now(),
        pondId: data['pondId'] ?? _currentPondId,
        deviceId: data['deviceId'] ?? _currentDeviceId,
        location: data['location'] ?? '',
      );
      
      // Add to recent data list
      _recentData.insert(0, _currentSensorData!);
      if (_recentData.length > 100) {
        _recentData = _recentData.take(100).toList();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error updating sensor data from MQTT: $e');
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Load latest sensor data
      final latestData = await FirebaseService.getLatestSensorData(_currentPondId);
      if (latestData != null) {
        _currentSensorData = latestData;
      }

      // Load control settings
      final settings = await FirebaseService.getControlSettings(_currentPondId);
      if (settings != null) {
        _controlSettings = settings;
      }

      // Request device status via MQTT
      if (_isConnected) {
        await MqttService.requestDeviceStatus(_currentDeviceId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load initial data: $e');
    }
  }

  // Manual device control methods
  Future<bool> setHeater(bool enabled) async {
    try {
      if (_isConnected) {
        final success = await MqttService.setHeater(_currentDeviceId, enabled);
        if (success) {
          _deviceStatus['heaterEnabled'] = enabled;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _setError('Failed to control heater: $e');
      return false;
    }
  }

  Future<bool> setAerator(bool enabled) async {
    try {
      if (_isConnected) {
        final success = await MqttService.setAerator(_currentDeviceId, enabled);
        if (success) {
          _deviceStatus['aeratorEnabled'] = enabled;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _setError('Failed to control aerator: $e');
      return false;
    }
  }

  Future<bool> setPhPump(bool enabled) async {
    try {
      if (_isConnected) {
        final success = await MqttService.setPHPump(_currentDeviceId, enabled);
        if (success) {
          _deviceStatus['phPumpEnabled'] = enabled;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _setError('Failed to control pH pump: $e');
      return false;
    }
  }

  Future<bool> setAutoMode(bool enabled) async {
    try {
      if (_isConnected) {
        final success = await MqttService.setAutoMode(_currentDeviceId, enabled);
        if (success) {
          _deviceStatus['autoMode'] = enabled;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _setError('Failed to set auto mode: $e');
      return false;
    }
  }

  // Target value setting methods
  Future<bool> setTargetTemperature(double temperature) async {
    try {
      if (_isConnected) {
        return await MqttService.setTargetTemperature(_currentDeviceId, temperature);
      }
      return false;
    } catch (e) {
      _setError('Failed to set target temperature: $e');
      return false;
    }
  }

  Future<bool> setTargetOxygen(double oxygen) async {
    try {
      if (_isConnected) {
        return await MqttService.setTargetOxygen(_currentDeviceId, oxygen);
      }
      return false;
    } catch (e) {
      _setError('Failed to set target oxygen: $e');
      return false;
    }
  }

  Future<bool> setTargetPH(double ph) async {
    try {
      if (_isConnected) {
        return await MqttService.setTargetPH(_currentDeviceId, ph);
      }
      return false;
    } catch (e) {
      _setError('Failed to set target pH: $e');
      return false;
    }
  }

  // Update control settings
  Future<bool> updateControlSettings(ControlSettings newSettings) async {
    try {
      final success = await FirebaseService.updateControlSettings(newSettings);
      if (success) {
        _controlSettings = newSettings;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to update control settings: $e');
      return false;
    }
  }

  // Get historical data
  Future<List<SensorData>> getHistoryData(DateTime startDate, DateTime endDate) async {
    try {
      return await FirebaseService.getSensorDataHistory(_currentPondId, startDate, endDate);
    } catch (e) {
      _setError('Failed to get history data: $e');
      return [];
    }
  }

  // Refresh data manually
  Future<void> refreshData() async {
    _setLoading(true);
    try {
      await _loadInitialData();
      if (_isConnected) {
        await MqttService.requestDeviceStatus(_currentDeviceId);
      }
    } catch (e) {
      _setError('Failed to refresh data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Switch pond
  Future<void> switchPond(String newPondId, String newDeviceId) async {
    if (newPondId != _currentPondId) {
      _currentPondId = newPondId;
      _currentDeviceId = newDeviceId;
      
      // Cancel existing subscriptions
      _cancelSubscriptions();
      
      // Reset data
      _currentSensorData = null;
      _recentData.clear();
      _controlSettings = null;
      _deviceStatus.clear();
      
      // Setup new listeners and load data
      _setupFirebaseListeners();
      await _loadInitialData();
      
      notifyListeners();
    }
  }

  // Initialize with pond ID
  Future<void> initialize(String pondId) async {
    _currentPondId = pondId;
    _setLoading(true);
    try {
      await _loadInitialData();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle feeder
  Future<bool> toggleFeeder([bool? enabled]) async {
    try {
      final newState = enabled ?? !isFeederOn;
      if (_isConnected) {
        final success = await MqttService.setFeeder(_currentDeviceId, newState);
        if (success) {
          _deviceStatus['feederEnabled'] = newState;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _setError('Failed to toggle feeder: $e');
      return false;
    }
  }

  // Toggle aerator
  Future<bool> toggleAerator([bool? enabled]) async {
    try {
      final newState = enabled ?? !isAeratorOn;
      if (_isConnected) {
        final success = await MqttService.setAerator(_currentDeviceId, newState);
        if (success) {
          _deviceStatus['aeratorEnabled'] = newState;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _setError('Failed to toggle aerator: $e');
      return false;
    }
  }

  // Toggle heater
  Future<bool> toggleHeater([bool? enabled]) async {
    try {
      final newState = enabled ?? !isHeaterOn;
      return await setHeater(newState);
    } catch (e) {
      _setError('Failed to toggle heater: $e');
      return false;
    }
  }

  // Toggle pH pump
  Future<bool> togglePhPump([bool? enabled]) async {
    try {
      final newState = enabled ?? !isPhPumpOn;
      if (_isConnected) {
        final success = await MqttService.setPHPump(_currentDeviceId, newState);
        if (success) {
          _deviceStatus['phPumpEnabled'] = newState;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _setError('Failed to toggle pH pump: $e');
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    print('DashboardProvider Error: $error');
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _firebaseSensorSubscription?.cancel();
    _mqttSensorSubscription?.cancel();
    _mqttStatusSubscription?.cancel();
    _controlSettingsSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}