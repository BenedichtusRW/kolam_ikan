import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/data_card.dart';
import '../../widgets/gauge_indicator.dart';
import '../../utils/routes.dart';

class UserDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard User'),
        backgroundColor: Colors.blue[600],
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
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.userProfile?.pondId != null) {
                dashboardProvider.initialize(authProvider.userProfile!.pondId!);
              }
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
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return Text(
                                'Monitor kondisi kolam Anda secara real-time',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              );
                            },
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

                  // Recent data chart placeholder
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grafik Tren (24 Jam Terakhir)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.show_chart,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'TODO: Implementasi Chart dengan fl_chart',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Last update info
                  if (dashboardProvider.currentSensorData != null)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Row(
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