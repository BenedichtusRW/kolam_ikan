import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static MqttServerClient? _client;
  static bool _isConnected = false;
  
  // MQTT Configuration
  static const String _broker = 'your-local-container-ip'; // Ganti dengan IP container
  static const int _port = 1883;
  static const String _clientId = 'flutter_mobile_app';
  
  // Topics
  static const String SENSOR_TOPIC = 'kolam/sensor/data';
  static const String CONTROL_TOPIC = 'kolam/control/command';
  static const String STATUS_TOPIC = 'kolam/device/status';
  static const String ALERT_TOPIC = 'kolam/alert';
  
  // Streams for real-time data
  static final StreamController<Map<String, dynamic>> _sensorDataController = 
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _deviceStatusController = 
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _alertController = 
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController.stream;
  static Stream<Map<String, dynamic>> get deviceStatusStream => _deviceStatusController.stream;
  static Stream<Map<String, dynamic>> get alertStream => _alertController.stream;

  /// Initialize MQTT connection
  static Future<bool> initialize({
    String? brokerAddress,
    int? port,
    String? username,
    String? password,
  }) async {
    try {
      _client = MqttServerClient(brokerAddress ?? _broker, _clientId);
      _client!.port = port ?? _port;
      _client!.logging(on: true);
      _client!.keepAlivePeriod = 60;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;

      // Set connection message
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      
      if (username != null && password != null) {
        connMessage.authenticateAs(username, password);
      }
      
      _client!.connectionMessage = connMessage;

      // Connect
      final status = await _client!.connect();
      if (status?.state == MqttConnectionState.connected) {
        print('MQTT Connected successfully');
        _isConnected = true;
        
        // Subscribe to topics
        _subscribeToTopics();
        
        // Setup message listener
        _client!.updates!.listen(_onMessage);
        
        return true;
      } else {
        print('MQTT Connection failed - disconnecting, status is ${status?.state}');
        _client!.disconnect();
        return false;
      }
    } catch (e) {
      print('MQTT Connection error: $e');
      return false;
    }
  }

  /// Subscribe to all necessary topics
  static void _subscribeToTopics() {
    _client!.subscribe(SENSOR_TOPIC, MqttQos.atMostOnce);
    _client!.subscribe(STATUS_TOPIC, MqttQos.atMostOnce);
    _client!.subscribe(ALERT_TOPIC, MqttQos.atMostOnce);
    print('MQTT Subscribed to topics');
  }

  /// Handle incoming messages
  static void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final topic = message.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
        (message.payload as MqttPublishMessage).payload.message,
      );

      try {
        final data = json.decode(payload) as Map<String, dynamic>;
        
        switch (topic) {
          case SENSOR_TOPIC:
            _sensorDataController.add(data);
            break;
          case STATUS_TOPIC:
            _deviceStatusController.add(data);
            break;
          case ALERT_TOPIC:
            _alertController.add(data);
            break;
        }
      } catch (e) {
        print('Error parsing MQTT message: $e');
      }
    }
  }

  /// Send control command to device
  static Future<bool> sendControlCommand(Map<String, dynamic> command) async {
    if (!_isConnected || _client == null) {
      print('MQTT not connected');
      return false;
    }

    try {
      final payload = json.encode(command);
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      
      _client!.publishMessage(CONTROL_TOPIC, MqttQos.atLeastOnce, builder.payload!);
      print('Control command sent: $payload');
      return true;
    } catch (e) {
      print('Error sending control command: $e');
      return false;
    }
  }

  /// Send manual control commands
  static Future<bool> setHeater(String deviceId, bool enabled) async {
    return await sendControlCommand({
      'deviceId': deviceId,
      'command': 'SET_HEATER',
      'enabled': enabled,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> setAerator(String deviceId, bool enabled) async {
    return await sendControlCommand({
      'deviceId': deviceId,
      'command': 'SET_AERATOR', 
      'enabled': enabled,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> setPHPump(String deviceId, bool enabled) async {
    return await sendControlCommand({
      'deviceId': deviceId,
      'command': 'SET_PH_PUMP',
      'enabled': enabled,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> setFeeder(String deviceId, bool enabled) async {
    return await sendControlCommand({
      'deviceId': deviceId,
      'command': 'SET_FEEDER',
      'enabled': enabled,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Set target values for automatic control
  static Future<bool> setTargetTemperature(String deviceId, double temperature) async {
    return await sendControlCommand({
      'deviceId': deviceId,
      'command': 'SET_TARGET_TEMP',
      'value': temperature,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> setTargetOxygen(String deviceId, double oxygen) async {
    return await sendControlCommand({
      'deviceId': deviceId,
      'command': 'SET_TARGET_OXYGEN',
      'value': oxygen,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> setTargetPH(String deviceId, double ph) async {
    return await sendControlCommand({
      'deviceId': deviceId,
      'command': 'SET_TARGET_PH',
      'value': ph,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Enable/disable automatic mode
  static Future<bool> setAutoMode(String deviceId, bool enabled) async {
    return await sendControlCommand({
      'deviceId': deviceId,
      'command': 'SET_AUTO_MODE',
      'enabled': enabled,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Request current device status
  static Future<bool> requestDeviceStatus(String deviceId) async {
    return await sendControlCommand({
      'deviceId': deviceId,
      'command': 'GET_STATUS',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Connection event handlers
  static void _onConnected() {
    print('MQTT Connected');
    _isConnected = true;
  }

  static void _onDisconnected() {
    print('MQTT Disconnected');
    _isConnected = false;
  }

  static void _onSubscribed(String topic) {
    print('MQTT Subscribed to: $topic');
  }

  /// Disconnect from MQTT
  static void disconnect() {
    if (_client != null) {
      _client!.disconnect();
      _isConnected = false;
    }
  }

  /// Check connection status
  static bool get isConnected => _isConnected;

  /// Dispose streams
  static void dispose() {
    _sensorDataController.close();
    _deviceStatusController.close();
    _alertController.close();
    disconnect();
  }
}