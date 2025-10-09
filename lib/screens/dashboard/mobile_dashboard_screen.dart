import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/control_settings.dart';

class MobileDashboardScreen extends StatefulWidget {
  @override
  _MobileDashboardScreenState createState() => _MobileDashboardScreenState();
}

class _MobileDashboardScreenState extends State<MobileDashboardScreen> {
  String _selectedFilter = 'Hari Ini'; // Filter grafik
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      
      if (authProvider.userProfile?.pondId != null) {
        dashboardProvider.initialize(authProvider.userProfile!.pondId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Monitoring',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Kolam Ikan',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.userProfile?.pondId != null) {
                dashboardProvider.initialize(authProvider.userProfile!.pondId!);
              }
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Sensor Data dengan Gauge - Copy dari Admin Dashboard yang sukses
                  Consumer<DashboardProvider>(
                    builder: (context, dashboardProvider, child) {
                      final sensorData = dashboardProvider.currentSensorData;
                      
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildSensorCard(
                                  'Suhu Air',
                                  (sensorData?.temperature ?? 25.2).toStringAsFixed(1),
                                  '°C',
                                  Icons.thermostat,
                                  Colors.orange,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildSensorCard(
                                  'Oksigen',
                                  (sensorData?.oxygen ?? 7.0).toStringAsFixed(1),
                                  'ppm',
                                  Icons.air,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSensorCard(
                                  'pH',
                                  (sensorData?.phLevel ?? 6.7).toStringAsFixed(1),
                                  '',
                                  Icons.science,
                                  Colors.green,
                                ),
                              ),
                              SizedBox(width: 12),
                              // Empty space to maintain layout
                              Expanded(
                                child: SizedBox(),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Grafik Rangkuman Section - Sesuai requirement
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grafik Rangkuman',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Filter Buttons
                        Row(
                          children: [
                            _buildFilterButton('Hari Ini'),
                            SizedBox(width: 8),
                            _buildFilterButton('Bulan Ini'),
                            SizedBox(width: 8),
                            _buildFilterButton('Tahun Ini'),
                          ],
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Chart Container
                        Container(
                          height: 250,
                          child: _buildChart(),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Status & Control Section - Hanya untuk Admin sesuai requirement dosen
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      // Panel kontrol hanya ditampilkan untuk admin
                      if (authProvider.userProfile?.isAdmin == true) {
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.settings_outlined, color: const Color.fromARGB(255, 57, 73, 171)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Status & Kontrol Perangkat (Admin Only)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              
                              // Aerator Control
                              _buildControlRow(
                                'Aerator:',
                                dashboardProvider.isAeratorOn,
                                () => dashboardProvider.toggleAerator(!dashboardProvider.isAeratorOn),
                              ),
                              SizedBox(height: 12),
                              
                              // Auto Mode Control
                              _buildControlRow(
                                'Mode Auto:',
                                dashboardProvider.isAutoMode,
                                () => dashboardProvider.setAutoMode(!dashboardProvider.isAutoMode),
                              ),
                              SizedBox(height: 16),
                              
                              // pH Range Settings
                              Text(
                                'Auto pH Range:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text('Min pH', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        Text(
                                          dashboardProvider.controlSettings?.phMin.toString() ?? '6.50',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(' - ', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text('Max pH', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        Text(
                                          dashboardProvider.controlSettings?.phMax.toString() ?? '8.50',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showUpdateRangeDialog(context, dashboardProvider);
                                  },
                                  icon: Icon(Icons.edit, size: 16),
                                  label: Text('Update Range'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 57, 73, 171),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // User biasa hanya melihat informasi status tanpa kontrol
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: const Color.fromARGB(255, 57, 73, 171)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Status Sistem',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              
                              _buildStatusRow('Aerator:', dashboardProvider.isAeratorOn ? 'Aktif' : 'Tidak Aktif'),
                              SizedBox(height: 12),
                              _buildStatusRow('Mode Auto:', dashboardProvider.isAutoMode ? 'Aktif' : 'Manual'),
                              SizedBox(height: 12),
                              _buildStatusRow('Status pH:', _getPhStatus(dashboardProvider.currentSensorData?.phLevel)),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Information Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: const Color.fromARGB(255, 57, 73, 171)),
                            SizedBox(width: 8),
                            Text(
                              'Informasi Waktu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        _buildInfoRow('Tanggal:', 'Rabu, 8 Oktober 2025'),
                        _buildInfoRow('Waktu:', '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
                        _buildInfoRow('Last Update:', '5/10/2025, 14.11.23'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlRow(String label, bool value, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: value ? Colors.red[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'OFF',
                style: TextStyle(
                  fontSize: 12,
                  color: value ? Colors.red[700] : Colors.grey[600],
                ),
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: value ? Colors.green[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ON',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateRangeDialog(BuildContext context, DashboardProvider provider) {
    final minController = TextEditingController(
      text: provider.controlSettings?.phMin.toString() ?? '6.50'
    );
    final maxController = TextEditingController(
      text: provider.controlSettings?.phMax.toString() ?? '8.50'
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update pH Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              decoration: InputDecoration(
                labelText: 'Min pH',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: maxController,
              decoration: InputDecoration(
                labelText: 'Max pH',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final min = double.tryParse(minController.text);
              final max = double.tryParse(maxController.text);
              if (min != null && max != null && provider.controlSettings != null) {
                // Create updated control settings
                final updatedSettings = ControlSettings(
                  id: provider.controlSettings!.id,
                  pondId: provider.controlSettings!.pondId,
                  autoMode: provider.controlSettings!.autoMode,
                  manualMode: provider.controlSettings!.manualMode,
                  targetTemperature: provider.controlSettings!.targetTemperature,
                  temperatureMin: provider.controlSettings!.temperatureMin,
                  temperatureMax: provider.controlSettings!.temperatureMax,
                  heaterEnabled: provider.controlSettings!.heaterEnabled,
                  coolerEnabled: provider.controlSettings!.coolerEnabled,
                  targetOxygen: provider.controlSettings!.targetOxygen,
                  oxygenMin: provider.controlSettings!.oxygenMin,
                  aeratorEnabled: provider.controlSettings!.aeratorEnabled,
                  targetPh: provider.controlSettings!.targetPh,
                  phMin: min,
                  phMax: max,
                  phPumpEnabled: provider.controlSettings!.phPumpEnabled,
                  scheduleRules: provider.controlSettings!.scheduleRules,
                  createdAt: provider.controlSettings!.createdAt,
                  updatedAt: DateTime.now(),
                  userId: provider.controlSettings!.userId,
                );
                
                final success = await provider.updateControlSettings(updatedSettings);
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('pH range updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update pH range')),
                  );
                }
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  // Method untuk build status row (hanya read-only untuk user)
  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: value.contains('Aktif') ? Colors.green[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: value.contains('Aktif') ? Colors.green[700] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Method untuk mendapatkan status pH
  String _getPhStatus(double? phLevel) {
    if (phLevel == null) return 'Tidak Diketahui';
    if (phLevel >= 6.5 && phLevel <= 8.0) return 'Normal';
    if (phLevel < 6.5) return 'Terlalu Asam';
    return 'Terlalu Basa';
  }

  // Method _buildSensorCard yang sukses dari Admin Dashboard
  Widget _buildSensorCard(String title, String value, String unit, IconData icon, Color color) {
    // Parse value untuk gauge calculation
    double numericValue = double.tryParse(value) ?? 0.0;
    
    // Tentukan range berdasarkan jenis sensor
    double minValue = 0.0;
    double maxValue = 100.0;
    List<GaugeRange> ranges = [];
    
    if (title.contains('Suhu')) {
      minValue = 20.0;
      maxValue = 35.0;
      ranges = [
        GaugeRange(startValue: 20, endValue: 25, color: Colors.blue.shade300),
        GaugeRange(startValue: 25, endValue: 32, color: Colors.green),
        GaugeRange(startValue: 32, endValue: 35, color: Colors.red.shade400),
      ];
    } else if (title.contains('pH')) {
      minValue = 6.0;
      maxValue = 9.0;
      ranges = [
        GaugeRange(startValue: 6.0, endValue: 6.5, color: Colors.red.shade400),
        GaugeRange(startValue: 6.5, endValue: 8.5, color: Colors.green),
        GaugeRange(startValue: 8.5, endValue: 9.0, color: Colors.red.shade400),
      ];
    } else if (title.contains('Oksigen')) {
      minValue = 0.0;
      maxValue = 12.0;
      ranges = [
        GaugeRange(startValue: 0, endValue: 5, color: Colors.red.shade400),
        GaugeRange(startValue: 5, endValue: 7, color: Colors.orange),
        GaugeRange(startValue: 7, endValue: 12, color: Colors.blue),
      ];
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Gauge Speedometer - Sama seperti di Admin Dashboard!
            Container(
              height: 120,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: minValue,
                    maximum: maxValue,
                    showLabels: true,
                    showTicks: true,
                    axisLabelStyle: GaugeTextStyle(fontSize: 10),
                    majorTickStyle: MajorTickStyle(length: 6),
                    minorTickStyle: MinorTickStyle(length: 3),
                    ranges: ranges,
                    pointers: <GaugePointer>[
                      // Jarum penunjuk
                      NeedlePointer(
                        value: numericValue,
                        needleLength: 0.7,
                        needleStartWidth: 1,
                        needleEndWidth: 3,
                        needleColor: Colors.grey[800],
                        knobStyle: KnobStyle(
                          knobRadius: 0.05,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      // Nilai di tengah gauge
                      GaugeAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$value',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              unit,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.75,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 8),
            
            // Status text
            Center(
              child: Text(
                _getStatusText(title, numericValue),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(title, numericValue),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(String title, double value) {
    if (title.contains('Suhu')) {
      if (value < 25) return Colors.blue;
      if (value > 32) return Colors.red;
      return Colors.green;
    } else if (title.contains('pH')) {
      if (value < 6.5 || value > 8.5) return Colors.red;
      return Colors.green;
    } else if (title.contains('Oksigen')) {
      if (value < 5) return Colors.red;
      if (value < 7) return Colors.orange;
      return Colors.blue;
    }
    return Colors.grey;
  }
  
  String _getStatusText(String title, double value) {
    if (title.contains('Suhu')) {
      if (value < 25) return 'Rendah';
      if (value > 32) return 'Tinggi';
      return 'Normal';
    } else if (title.contains('pH')) {
      if (value < 6.5 || value > 8.5) return 'Tidak Normal';
      return 'Normal';
    } else if (title.contains('Oksigen')) {
      if (value < 5) return 'Rendah';
      if (value < 7) return 'Sedang';
      return 'Baik';
    }
    return 'Normal';
  }

  // Filter Button Widget
  Widget _buildFilterButton(String title) {
    final isSelected = _selectedFilter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = title;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromARGB(255, 57, 73, 171) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // Chart Widget dengan data dummy
  Widget _buildChart() {
    List<FlSpot> temperatureData = _getChartData('temperature');
    List<FlSpot> oxygenData = _getChartData('oxygen');
    List<FlSpot> phData = _getChartData('ph');

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: _selectedFilter == 'Hari Ini' ? 23 : (_selectedFilter == 'Bulan Ini' ? 30 : 12),
        minY: 0,
        maxY: 35,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (_selectedFilter == 'Hari Ini') {
                  return Text('${value.toInt()}h', style: TextStyle(fontSize: 10));
                } else if (_selectedFilter == 'Bulan Ini') {
                  return Text('${value.toInt()}', style: TextStyle(fontSize: 10));
                } else {
                  return Text('${value.toInt()}', style: TextStyle(fontSize: 10));
                }
              },
              reservedSize: 25,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}', style: TextStyle(fontSize: 10));
              },
              reservedSize: 35,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: _selectedFilter == 'Hari Ini' ? 4 : 5,
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          // Temperature line (Orange)
          LineChartBarData(
            spots: temperatureData,
            isCurved: true,
            color: Colors.orange,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
          ),
          // Oxygen line (Blue)
          LineChartBarData(
            spots: oxygenData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
          ),
          // pH line (Green)
          LineChartBarData(
            spots: phData,
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  // Generate chart data based on filter
  List<FlSpot> _getChartData(String type) {
    List<FlSpot> data = [];
    
    if (_selectedFilter == 'Hari Ini') {
      // Data per jam (0-23)
      for (int i = 0; i <= 23; i++) {
        double value = 0;
        if (type == 'temperature') {
          value = 24 + (i % 6); // Variasi suhu 24-30
        } else if (type == 'oxygen') {
          value = 6 + (i % 4); // Variasi oksigen 6-10
        } else if (type == 'ph') {
          value = 6.5 + (i % 2) * 0.5; // Variasi pH 6.5-7.5
        }
        data.add(FlSpot(i.toDouble(), value));
      }
    } else if (_selectedFilter == 'Bulan Ini') {
      // Data per hari (1-30)
      for (int i = 1; i <= 30; i++) {
        double value = 0;
        if (type == 'temperature') {
          value = 25 + (i % 5); // Variasi suhu 25-30
        } else if (type == 'oxygen') {
          value = 7 + (i % 3); // Variasi oksigen 7-10
        } else if (type == 'ph') {
          value = 6.8 + (i % 2) * 0.3; // Variasi pH 6.8-7.4
        }
        data.add(FlSpot(i.toDouble(), value));
      }
    } else {
      // Data per bulan (1-12)
      for (int i = 1; i <= 12; i++) {
        double value = 0;
        if (type == 'temperature') {
          value = 26 + (i % 4); // Variasi suhu 26-30
        } else if (type == 'oxygen') {
          value = 7 + (i % 2); // Variasi oksigen 7-9
        } else if (type == 'ph') {
          value = 7.0 + (i % 2) * 0.2; // Variasi pH 7.0-7.4
        }
        data.add(FlSpot(i.toDouble(), value));
      }
    }
    
    return data;
  }
}