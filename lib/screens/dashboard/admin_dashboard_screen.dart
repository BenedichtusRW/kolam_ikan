import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../admin/control_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      
      String pondId = authProvider.userProfile?.pondId ?? 'pond_001';
      
      // Force enable testing mode for demo
      dashboardProvider.enableTestingMode();
      dashboardProvider.initialize(pondId);
      
      print('Admin Dashboard initialized with mock data');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ControlSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 80), // Extra bottom padding for navigation
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card - Panel Admin
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 57, 73, 171),
                      const Color.fromARGB(255, 67, 83, 191),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Panel Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kelola dan kontrol sistem kolam ikan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Kondisi Terkini Section
            Text(
              'Kondisi Terkini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            // Sensor Data Cards
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
                            (sensorData?.temperature ?? 0).toStringAsFixed(1),
                            '°C',
                            Icons.thermostat,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildSensorCard(
                            'Oksigen',
                            (sensorData?.oxygen ?? 0).toStringAsFixed(1),
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
                            (sensorData?.phLevel ?? 0).toStringAsFixed(1),
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
            
            SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'System Status',
                    'Cek status sistem',
                    Icons.monitor_heart,
                    Colors.teal,
                    () {
                      // Navigate to system status
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Checking System Status...')),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    'Control Settings',
                    'Kelola kontrol otomatis',
                    Icons.settings,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ControlSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Requirements Status
            Text(
              'Requirements Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            _buildRequirementCard('3 Jenis Tampilan Data', 'Gauge, Digital, Grafik', Icons.dashboard, true),
            _buildRequirementCard('Role-based System', 'Admin vs User', Icons.people, true),
            _buildRequirementCard('Kontrol Otomatis', 'Parameter-based Control', Icons.settings_applications, true),
            _buildRequirementCard('Monitoring System', 'Real-time data monitoring', Icons.monitor, true),
            _buildRequirementCard('Cloud & Local Storage', 'Firebase + Local Server', Icons.storage, false),
            _buildRequirementCard('ESP32 Integration', 'Hardware sensor data', Icons.sensors, false),
          ],
        ),
      ),
    );
  }

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
            
            // Gauge Speedometer - Ini yang diminta dosen!
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

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementCard(String title, String description, IconData icon, bool isComplete) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon, 
          color: isComplete ? Colors.green : Colors.orange,
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(
          isComplete ? Icons.check_circle : Icons.schedule,
          color: isComplete ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}