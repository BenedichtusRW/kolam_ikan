import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data.dart';

class HistoryProvider with ChangeNotifier {

  List<SensorData> _historyData = [];
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  // Statistics
  double _avgTemperature = 0.0;
  double _avgOxygen = 0.0;
  double _minTemperature = 0.0;
  double _maxTemperature = 0.0;
  double _minOxygen = 0.0;
  double _maxOxygen = 0.0;

  // Getters
  List<SensorData> get historyData => _historyData;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get avgTemperature => _avgTemperature;
  double get avgOxygen => _avgOxygen;
  double get minTemperature => _minTemperature;
  double get maxTemperature => _maxTemperature;
  double get minOxygen => _minOxygen;
  double get maxOxygen => _maxOxygen;

  Future<void> fetchHistoryData(DateTime date, String pondId) async {
    _isLoading = true;
    _selectedDate = date;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Fetch data history berdasarkan tanggal dari Firestore
      DateTime startDate = DateTime(date.year, date.month, date.day);
      DateTime endDate = startDate.add(Duration(days: 1));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('sensor_data')
          .where('pondId', isEqualTo: pondId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('timestamp', isLessThan: endDate.millisecondsSinceEpoch)
          .orderBy('timestamp', descending: false)
          .get();

      _historyData = snapshot.docs
          .map((doc) => SensorData.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _calculateStatistics();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _calculateStatistics() {
    if (_historyData.isEmpty) {
      _avgTemperature = 0.0;
      _avgOxygen = 0.0;
      _minTemperature = 0.0;
      _maxTemperature = 0.0;
      _minOxygen = 0.0;
      _maxOxygen = 0.0;
      return;
    }

    // Calculate averages
    _avgTemperature = _historyData
        .map((data) => data.temperature)
        .reduce((a, b) => a + b) / _historyData.length;
    
    _avgOxygen = _historyData
        .map((data) => data.oxygen)
        .reduce((a, b) => a + b) / _historyData.length;

    // Calculate min/max
    List<double> temperatures = _historyData.map((data) => data.temperature).toList();
    List<double> oxygenLevels = _historyData.map((data) => data.oxygen).toList();

    temperatures.sort();
    oxygenLevels.sort();

    _minTemperature = temperatures.first;
    _maxTemperature = temperatures.last;
    _minOxygen = oxygenLevels.first;
    _maxOxygen = oxygenLevels.last;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    _historyData.clear();
    _selectedDate = null;
    _errorMessage = null;
    notifyListeners();
  }
}