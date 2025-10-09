import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../login/login_screen.dart';
import '../../widgets/modern_gauge_widget.dart';

class UserWebDashboardScreen extends StatefulWidget {
  @override
  _UserWebDashboardScreenState createState() => _UserWebDashboardScreenState();
}

class _UserWebDashboardScreenState extends State<UserWebDashboardScreen> {
  int _selectedIndex = 0;
  String _selectedFilter = 'Hari Ini';
  
  final List<String> _menuItems = [
    'My Dashboard',
    'Live Monitoring', 
    'History & Reports',
    'Alerts & Notifications',
    'My Profile'
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard,
    Icons.monitor,
    Icons.history,
    Icons.notifications,
    Icons.person
  ];

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
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 57, 73, 171),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      SizedBox(height: 16),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Column(
                            children: [
                              Text(
                                'Welcome,',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                authProvider.userProfile?.name ?? 'User',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Pond ID: ${authProvider.userProfile?.pondId ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                Divider(color: Colors.white24),
                
                // Menu Items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      return _buildSidebarItem(
                        icon: _menuIcons[index],
                        label: _menuItems[index],
                        index: index,
                        isSelected: _selectedIndex == index,
                      );
                    },
                  ),
                ),
                
                // Logout Button
                Container(
                  padding: EdgeInsets.all(16),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showLogoutDialog(context, authProvider),
                          icon: Icon(Icons.logout, size: 16),
                          label: Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.white.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildMyDashboard();
      case 1:
        return _buildLiveMonitoring();
      case 2:
        return _buildHistoryReports();
      case 3:
        return _buildAlertsNotifications();
      case 4:
        return _buildMyProfile();
      default:
        return _buildMyDashboard();
    }
  }

  Widget _buildMyDashboard() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Pond Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Monitor your pond conditions in real-time',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'All Systems Normal',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 32),
              
              // Status Cards Row
              Row(
                children: [
                  Expanded(child: _buildStatusCard('Temperature', '${dashboardProvider.currentSensorData?.temperature.toStringAsFixed(1) ?? '25.0'}°C', Icons.thermostat, Colors.red, 'Normal')),
                  SizedBox(width: 16),
                  Expanded(child: _buildStatusCard('pH Level', '${dashboardProvider.currentSensorData?.phLevel.toStringAsFixed(2) ?? '7.00'}', Icons.water_drop, const Color.fromARGB(255, 57, 73, 171), 'Optimal')),
                  SizedBox(width: 16),
                  Expanded(child: _buildStatusCard('Oxygen', '${dashboardProvider.currentSensorData?.oxygen.toStringAsFixed(1) ?? '8.5'} mg/L', Icons.air, Colors.green, 'Good')),
                  SizedBox(width: 16),
                  Expanded(child: _buildStatusCard('Turbidity', '${dashboardProvider.currentSensorData?.turbidity.toStringAsFixed(1) ?? '2.3'} NTU', Icons.visibility, Colors.orange, 'Clear')),
                ],
              ),
              
              SizedBox(height: 32),
              
              // Main Content Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column - Gauges & Current Reading
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildCurrentReadings(dashboardProvider),
                        SizedBox(height: 24),
                        _buildTodaySummary(),
                      ],
                    ),
                  ),
                  
                  SizedBox(width: 24),
                  
                  // Right Column - Chart & Activity
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildTrendChart(dashboardProvider),
                        SizedBox(height: 24),
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color, String status) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentReadings(DashboardProvider dashboardProvider) {
    final temp = dashboardProvider.currentSensorData?.temperature ?? 25.2;
    final oxygen = dashboardProvider.currentSensorData?.oxygen ?? 6.6;
    final ph = dashboardProvider.currentSensorData?.phLevel ?? 6.8;
    
    final tempStatus = GaugeHelper.getTemperatureStatus(temp);
    final oxygenStatus = GaugeHelper.getOxygenStatus(oxygen);
    final phStatus = GaugeHelper.getPhStatus(ph);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kondisi Terkini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 24),
            
            // Modern Gauges Grid
            Row(
              children: [
                // Temperature Gauge
                Expanded(
                  child: ModernGaugeWidget(
                    title: 'Suhu Air',
                    value: temp,
                    unit: '°C',
                    minValue: 20,
                    maxValue: 30,
                    status: tempStatus['status'],
                    statusColor: tempStatus['color'],
                    icon: Icons.thermostat,
                    ranges: GaugeHelper.getTemperatureRanges(),
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Oxygen Gauge
                Expanded(
                  child: ModernGaugeWidget(
                    title: 'Oksigen',
                    value: oxygen,
                    unit: 'ppm',
                    minValue: 0,
                    maxValue: 10,
                    status: oxygenStatus['status'],
                    statusColor: oxygenStatus['color'],
                    icon: Icons.air,
                    ranges: GaugeHelper.getOxygenRanges(),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // pH Gauge (centered)
            Row(
              children: [
                Expanded(flex: 1, child: SizedBox()), // Spacer
                Expanded(
                  flex: 2,
                  child: ModernGaugeWidget(
                    title: 'pH',
                    value: ph,
                    unit: '',
                    minValue: 6,
                    maxValue: 8,
                    status: phStatus['status'],
                    statusColor: phStatus['color'],
                    icon: Icons.water_drop,
                    ranges: GaugeHelper.getPhRanges(),
                  ),
                ),
                Expanded(flex: 1, child: SizedBox()), // Spacer
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            _buildSummaryItem('Avg Temperature', '26.2°C', Icons.thermostat, Colors.red),
            _buildSummaryItem('Avg pH Level', '7.1', Icons.water_drop, const Color.fromARGB(255, 57, 73, 171)),
            _buildSummaryItem('Avg Oxygen', '8.3 mg/L', Icons.air, Colors.green),
            _buildSummaryItem('Data Points', '24 readings', Icons.analytics, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(DashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(24),
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
            SizedBox(height: 20),
            
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
            
            // Chart
            Container(
              height: 250,
              child: _buildChart(),
            ),
            
            // Legend
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Suhu Air', Colors.orange),
                _buildLegendItem('Oksigen', Colors.blue),
                _buildLegendItem('pH', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
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

  Widget _buildRecentActivity() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            ..._buildActivityItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActivityItems() {
    final activities = [
      {'title': 'System Check Completed', 'time': '2 minutes ago', 'type': 'success'},
      {'title': 'Data Reading Recorded', 'time': '1 hour ago', 'type': 'info'},
      {'title': 'Daily Report Generated', 'time': '3 hours ago', 'type': 'info'},
      {'title': 'Temperature Alert Cleared', 'time': '5 hours ago', 'type': 'success'},
    ];

    return activities.map((activity) {
      Color activityColor;
      IconData activityIcon;
      
      switch (activity['type']) {
        case 'success':
          activityColor = Colors.green;
          activityIcon = Icons.check_circle;
          break;
        case 'warning':
          activityColor = Colors.orange;
          activityIcon = Icons.warning;
          break;
        default:
          activityColor = Colors.blue;
          activityIcon = Icons.info;
      }

      return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: activityColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(activityIcon, color: activityColor, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    activity['time']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Placeholder methods for other tabs
  Widget _buildLiveMonitoring() {
    return Center(
      child: Text(
        'Live Monitoring View\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildHistoryReports() {
    return Center(
      child: Text(
        'History & Reports View\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildAlertsNotifications() {
    return Center(
      child: Text(
        'Alerts & Notifications View\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildMyProfile() {
    return Center(
      child: Text(
        'My Profile View\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Keluar'),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog first
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Keluar...'),
                      ],
                    ),
                  ),
                ),
              );
              
              try {
                // Perform logout
                await authProvider.logout();
                
                // Close loading dialog
                Navigator.of(context, rootNavigator: true).pop();
                
                // Navigate to login and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
                
                print('User web logout successful');
                
              } catch (e) {
                // Close loading dialog
                Navigator.of(context, rootNavigator: true).pop();
                
                print('User web logout error: $e');
                
                // Show error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout gagal: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Keluar'),
          ),
        ],
      ),
    );
  }
}