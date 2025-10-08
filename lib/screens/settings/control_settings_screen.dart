import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';

class ControlSettingsScreen extends StatelessWidget {
  const ControlSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Kontrol'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header info
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
                        Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Pengaturan Kontrol',
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
                          'Kelola pengaturan otomatis dan manual untuk perangkat IoT',
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
                        _buildDeviceControl(
                          context,
                          'Aerator',
                          'Mengontrol sistem aerasi untuk oksigenasi air',
                          Icons.air,
                          dashboardProvider.isAeratorOn,
                          Colors.blue,
                          (value) => dashboardProvider.toggleAerator(value),
                          dashboardProvider.isLoading,
                        ),
                        
                        Divider(height: 32),
                        
                        // Feeder Control
                        _buildDeviceControl(
                          context,
                          'Pemberi Pakan',
                          'Mengontrol sistem pemberian pakan otomatis',
                          Icons.restaurant,
                          dashboardProvider.isFeederOn,
                          Colors.blue,
                          (value) => dashboardProvider.toggleFeeder(value),
                          dashboardProvider.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Automatic Control Section (TODO)
                Text(
                  'Kontrol Otomatis',
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
                        // Temperature threshold setting
                        _buildThresholdSetting(
                          context,
                          'Batas Suhu',
                          'Aerator akan aktif otomatis jika suhu > 28°C',
                          Icons.thermostat,
                          '28°C',
                          Colors.red,
                          false, // TODO: Implement auto mode state
                        ),
                        
                        Divider(height: 24),
                        
                        // Oxygen threshold setting
                        _buildThresholdSetting(
                          context,
                          'Batas Oksigen',
                          'Aerator akan aktif otomatis jika O₂ < 6 ppm',
                          Icons.air,
                          '6 ppm',
                          Colors.green,
                          false, // TODO: Implement auto mode state
                        ),
                        
                        Divider(height: 24),
                        
                        // Feeding schedule
                        _buildScheduleSetting(
                          context,
                          'Jadwal Pakan',
                          'Pemberian pakan otomatis 3x sehari',
                          Icons.schedule,
                          '07:00, 12:00, 17:00',
                          Colors.purple,
                          false, // TODO: Implement auto feeding state
                        ),
                      ],
                    ),
                  ),
                ),

                // Error message display
                if (dashboardProvider.errorMessage != null)
                  Container(
                    margin: EdgeInsets.only(top: 16),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceControl(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isActive,
    Color color,
    Function(bool) onToggle,
    bool isLoading,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isActive,
          onChanged: isLoading ? null : onToggle,
          activeColor: color,
        ),
      ],
    );
  }

  Widget _buildThresholdSetting(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String threshold,
    Color color,
    bool isEnabled,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            threshold,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(width: 8),
        Switch(
          value: isEnabled,
          onChanged: (value) {
            // TODO: Implement threshold toggle
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('TODO: Implementasi kontrol otomatis'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          activeColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildScheduleSetting(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String schedule,
    Color color,
    bool isEnabled,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  schedule,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isEnabled,
          onChanged: (value) {
            // TODO: Implement schedule toggle
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('TODO: Implementasi jadwal otomatis'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          activeColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}