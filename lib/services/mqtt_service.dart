import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static late MqttServerClient _client;
  static final StreamController<Map<String, dynamic>> _sensorDataController =
      StreamController.broadcast();
  static final StreamController<Map<String, dynamic>> _deviceStatusController =
      StreamController.broadcast();

  static Stream<Map<String, dynamic>> get sensorDataStream =>
      _sensorDataController.stream;
  static Stream<Map<String, dynamic>> get deviceStatusStream =>
      _deviceStatusController.stream;

  static bool _isConnected = false;
  static bool hasPublishFunction = false;

  static Future<bool> initialize() async {
    try {
      _client = MqttServerClient('broker.hivemq.com', 'kolam_ikan_${DateTime.now().millisecondsSinceEpoch}');
      _client.port = 1883;
      _client.keepAlivePeriod = 20;
      _client.logging(on: false);
      _client.onConnected = _onConnected;
      _client.onDisconnected = _onDisconnected;
      _client.onSubscribed = _onSubscribed;
      _client.onUnsubscribed = _onUnsubscribed;
      _client.pongCallback = _pong;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
          .keepAliveFor(20)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _client.connectionMessage = connMessage;

      print('🔌 Connecting to MQTT broker...');
      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        print('✅ Connected to MQTT broker');
        _isConnected = true;
        hasPublishFunction = true;
        _subscribeToTopics();
        return true;
      } else {
        print('❌ MQTT connection failed: ${_client.connectionStatus}');
        _isConnected = false;
        hasPublishFunction = false;
        return false;
      }
    } catch (e) {
      print('❌ MQTT connection error: $e');
      _client.disconnect();
      _isConnected = false;
      hasPublishFunction = false;
      return false;
    }
  }

  static void _subscribeToTopics() {
    if (!_isConnected) return;
    _client.subscribe('kolam/sensor', MqttQos.atLeastOnce);
    _client.subscribe('kolam/status', MqttQos.atLeastOnce);

    _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      try {
        final jsonData = jsonDecode(pt);
        if (c[0].topic == 'kolam/sensor') {
          _sensorDataController.add(jsonData);
        } else if (c[0].topic == 'kolam/status') {
          _deviceStatusController.add(jsonData);
        }
      } catch (e) {
        print('⚠️ Error parsing MQTT message: $e');
      }
    });
  }

  static Future<bool> publishMessage(String topic, Map<String, dynamic> message) async {
    if (!_isConnected) {
      print('⚠️ Not connected to MQTT');
      return false;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(jsonEncode(message));
      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('📤 Published to $topic: $message');
      return true;
    } catch (e) {
      print('❌ Failed to publish message: $e');
      return false;
    }
  }

  static Future<bool> requestDeviceStatus(String deviceId) async {
    return await publishMessage('kolam/request_status', {'device_id': deviceId});
  }

  static Future<bool> setHeater(String deviceId, bool state) async {
    return await publishMessage('kolam/set_heater', {'device_id': deviceId, 'state': state});
  }

  static Future<bool> setAerator(String deviceId, bool state) async {
    return await publishMessage('kolam/set_aerator', {'device_id': deviceId, 'state': state});
  }

  static Future<bool> setPHPump(String deviceId, bool state) async {
    return await publishMessage('kolam/set_ph_pump', {'device_id': deviceId, 'state': state});
  }

  static Future<bool> setFeeder(String deviceId, bool state) async {
    return await publishMessage('kolam/set_feeder', {'device_id': deviceId, 'state': state});
  }

  static Future<bool> setAutoMode(String deviceId, bool state) async {
    return await publishMessage('kolam/set_auto', {'device_id': deviceId, 'state': state});
  }

  static Future<bool> setTargetTemperature(String deviceId, double value) async {
    return await publishMessage('kolam/set_target_temp', {'device_id': deviceId, 'value': value});
  }

  static Future<bool> setTargetOxygen(String deviceId, double value) async {
    return await publishMessage('kolam/set_target_o2', {'device_id': deviceId, 'value': value});
  }

  static Future<bool> setTargetPH(String deviceId, double value) async {
    return await publishMessage('kolam/set_target_ph', {'device_id': deviceId, 'value': value});
  }

  static void disconnect() {
    if (_isConnected) {
      _client.disconnect();
      _isConnected = false;
      hasPublishFunction = false;
      print('🔌 Disconnected from MQTT broker');
    }
  }

  static void _onConnected() => print('✅ MQTT Connected');
  static void _onDisconnected() => print('🔴 MQTT Disconnected');
  static void _onSubscribed(String topic) => print('📡 Subscribed to $topic');
  static void _onUnsubscribed(String? topic) => print('❎ Unsubscribed from $topic');
  static void _pong() => print('🏓 Ping response received');
}
