import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/data_card.dart';
import '../../widgets/gauge_indicator.dart';
import '../../utils/routes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, Routes.history);
            },
            tooltip: 'Lihat Riwayat',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, Routes.controlSettings);
            },
            tooltip: 'Pengaturan Kontrol',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              // TODO: Implement refresh logic
              dashboardProvider.initialize('pond_1'); // Replace with dynamic pond ID
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Panel Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Kelola dan kontrol sistem kolam ikan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Manual Control Section
                  Text(
                    'Kontrol Manual',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Aerator Control
                          Row(
                            children: [
                              Icon(
                                Icons.air,
                                color: dashboardProvider.isAeratorOn 
                                  ? Colors.green[600] 
                                  : Colors.grey[600],
                                size: 32,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Aerator',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      dashboardProvider.isAeratorOn ? 'Aktif' : 'Tidak Aktif',
                                      style: TextStyle(
                                        color: dashboardProvider.isAeratorOn 
                                          ? Colors.green[600] 
                                          : Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: dashboardProvider.isAeratorOn,
                                onChanged: dashboardProvider.isLoading 
                                  ? null 
                                  : (value) {
                                      dashboardProvider.toggleAerator(value);
                                    },
                                activeColor: Colors.green[600],
                              ),
                            ],
                          ),
                          Divider(height: 32),
                          
                          // Feeder Control
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: dashboardProvider.isFeederOn 
                                  ? Colors.orange[600] 
                                  : Colors.grey[600],
                                size: 32,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pemberi Pakan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      dashboardProvider.isFeederOn ? 'Aktif' : 'Tidak Aktif',
                                      style: TextStyle(
                                        color: dashboardProvider.isFeederOn 
                                          ? Colors.orange[600] 
                                          : Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: dashboardProvider.isFeederOn,
                                onChanged: dashboardProvider.isLoading 
                                  ? null 
                                  : (value) {
                                      dashboardProvider.toggleFeeder(value);
                                    },
                                activeColor: Colors.orange[600],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Status indicators
                  Text(
                    'Kondisi Terkini',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DataCard(
                          title: 'Suhu Air',
                          value: dashboardProvider.currentSensorData?.temperature.toStringAsFixed(1) ?? '--',
                          unit: '°C',
                          icon: Icons.thermostat,
                          color: _getTemperatureColor(dashboardProvider.currentSensorData?.temperature),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: DataCard(
                          title: 'Oksigen',
                          value: dashboardProvider.currentSensorData?.oxygen.toStringAsFixed(1) ?? '--',
                          unit: 'ppm',
                          icon: Icons.air,
                          color: _getOxygenColor(dashboardProvider.currentSensorData?.oxygen),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Gauge indicators
                  Row(
                    children: [
                      Expanded(
                        child: GaugeIndicator(
                          title: 'Suhu',
                          value: dashboardProvider.currentSensorData?.temperature ?? 0,
                          minValue: 20,
                          maxValue: 35,
                          unit: '°C',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GaugeIndicator(
                          title: 'Oksigen',
                          value: dashboardProvider.currentSensorData?.oxygen ?? 0,
                          minValue: 0,
                          maxValue: 15,
                          unit: 'ppm',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Error message display
                  if (dashboardProvider.errorMessage != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600], size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dashboardProvider.errorMessage!,
                              style: TextStyle(color: Colors.red[800]),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 20),
                            onPressed: () => dashboardProvider.clearError(),
                          ),
                        ],
                      ),
                    ),

                  // Last update info
                  if (dashboardProvider.currentSensorData != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'Terakhir diperbarui: ${_formatDateTime(dashboardProvider.currentSensorData!.timestamp)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getTemperatureColor(double? temperature) {
    if (temperature == null) return Colors.grey;
    if (temperature < 24 || temperature > 30) return Colors.red;
    if (temperature < 26 || temperature > 28) return Colors.orange;
    return Colors.green;
  }

  Color _getOxygenColor(double? oxygen) {
    if (oxygen == null) return Colors.grey;
    if (oxygen < 4) return Colors.red;
    if (oxygen < 6) return Colors.orange;
    return Colors.green;
  }

  String _formatDateTime(DateTime dateTime) {
    // TODO: Use intl package for better formatting
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Keluar'),
          content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, Routes.login);
              },
              child: Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}