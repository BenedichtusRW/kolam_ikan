import 'dart:math';
import '../models/sensor_data.dart';

class MockDataGenerator {
  static final Random _random = Random();
  
  /// Generate mock sensor data untuk testing chart functionality
  /// Sesuai requirement dosen: data per jam dari 8 pagi - 5 sore
  static List<SensorData> generateDailyMockData({
    required DateTime date,
    required String pondId,
    int dataPointsPerHour = 6, // 1 data setiap 10 menit
  }) {
    List<SensorData> mockData = [];
    
    // Generate data dari jam 8 pagi sampai 5 sore (9 jam)
    for (int hour = 8; hour <= 17; hour++) {
      for (int point = 0; point < dataPointsPerHour; point++) {
        int minute = (point * (60 ~/ dataPointsPerHour));
        
        DateTime timestamp = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        
        mockData.add(_generateSensorDataPoint(timestamp, pondId));
      }
    }
    
    return mockData;
  }
  
  /// Generate single sensor data point dengan variasi yang realistis
  static SensorData _generateSensorDataPoint(DateTime timestamp, String pondId) {
    // Base values dengan variasi per jam untuk simulasi kondisi real
    double hourFactor = timestamp.hour / 24.0;
    
    // Suhu: Lebih tinggi siang hari, lebih rendah pagi/sore
    double baseTemp = 26.0 + (sin(hourFactor * 2 * pi) * 2);
    double temperature = baseTemp + _randomVariation(0.5);
    
    // pH: Cenderung stabil dengan sedikit fluktuasi
    double basePh = 7.0;
    double phLevel = basePh + _randomVariation(0.3);
    
    // Oksigen: Lebih tinggi pagi hari, turun siang hari
    double baseOxygen = 8.0 - (hourFactor * 2) + _randomVariation(1.0);
    double oxygen = max(4.0, baseOxygen); // Minimum 4.0
    
    // Turbidity: Kekeruhan air, biasanya rendah untuk air yang baik
    double turbidity = 2.0 + _randomVariation(1.0);
    turbidity = max(0.5, turbidity); // Minimum 0.5 NTU
    
    return SensorData(
      id: 'mock_${timestamp.millisecondsSinceEpoch}',
      pondId: pondId,
      temperature: double.parse(temperature.toStringAsFixed(2)),
      phLevel: double.parse(phLevel.toStringAsFixed(2)),
      oxygen: double.parse(oxygen.toStringAsFixed(2)),
      turbidity: double.parse(turbidity.toStringAsFixed(2)),
      timestamp: timestamp,
      deviceId: 'MOCK_ESP32_001',
      location: 'Kolam Testing Area',
    );
  }
  
  /// Generate current sensor data untuk dashboard
  static SensorData generateCurrentMockData(String pondId) {
    return _generateSensorDataPoint(DateTime.now(), pondId);
  }
  
  /// Generate historical data untuk beberapa hari
  static List<SensorData> generateHistoricalMockData({
    required String pondId,
    int daysBack = 7,
  }) {
    List<SensorData> allData = [];
    DateTime now = DateTime.now();
    
    for (int i = 0; i < daysBack; i++) {
      DateTime date = now.subtract(Duration(days: i));
      allData.addAll(generateDailyMockData(
        date: date,
        pondId: pondId,
      ));
    }
    
    return allData;
  }
  
  /// Helper untuk variasi random
  static double _randomVariation(double maxVariation) {
    return (_random.nextDouble() - 0.5) * 2 * maxVariation;
  }
  
  /// Generate data dengan kondisi tertentu untuk testing
  static List<SensorData> generateTestScenarioData({
    required DateTime date,
    required String pondId,
    required String scenario,
  }) {
    switch (scenario) {
      case 'normal':
        return generateDailyMockData(date: date, pondId: pondId);
        
      case 'high_temp':
        return _generateScenarioData(date, pondId, 
          tempBase: 32.0, phBase: 7.0, oxygenBase: 6.0);
        
      case 'low_ph':
        return _generateScenarioData(date, pondId,
          tempBase: 27.0, phBase: 6.0, oxygenBase: 8.0);
        
      case 'low_oxygen':
        return _generateScenarioData(date, pondId,
          tempBase: 28.0, phBase: 7.2, oxygenBase: 3.5);
        
      default:
        return generateDailyMockData(date: date, pondId: pondId);
    }
  }
  
  static List<SensorData> _generateScenarioData(
    DateTime date, 
    String pondId, {
    required double tempBase,
    required double phBase, 
    required double oxygenBase,
  }) {
    List<SensorData> data = [];
    
    for (int hour = 8; hour <= 17; hour++) {
      for (int minute = 0; minute < 60; minute += 10) {
        DateTime timestamp = DateTime(date.year, date.month, date.day, hour, minute);
        
        data.add(SensorData(
          id: 'scenario_${timestamp.millisecondsSinceEpoch}',
          pondId: pondId,
          temperature: tempBase + _randomVariation(0.5),
          phLevel: phBase + _randomVariation(0.2),
          oxygen: oxygenBase + _randomVariation(0.5),
          turbidity: 2.0 + _randomVariation(0.5),
          timestamp: timestamp,
          deviceId: 'MOCK_ESP32_SCENARIO',
          location: 'Kolam Testing Scenario',
        ));
      }
    }
    
    return data;
  }
}