import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/history_provider.dart';

class DeveloperTestingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Developer Testing Panel'),
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.developer_mode, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Testing Mode Panel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Panel ini untuk testing functionality dengan mock data sesuai requirement dosen.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Dashboard Testing
            Text(
              'Dashboard Testing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: ${dashboardProvider.isTestingMode ? "Testing Mode ON" : "Real Data Mode"}',
                              style: TextStyle(
                                color: dashboardProvider.isTestingMode ? Colors.green : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Switch(
                              value: dashboardProvider.isTestingMode,
                              onChanged: (value) {
                                if (value) {
                                  dashboardProvider.enableTestingMode();
                                } else {
                                  dashboardProvider.disableTestingMode();
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        if (dashboardProvider.isTestingMode) ...[
                          Text(
                            'Test Scenarios:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildScenarioButton(
                                context,
                                'Normal',
                                'normal',
                                Colors.green,
                                dashboardProvider,
                              ),
                              _buildScenarioButton(
                                context,
                                'High Temp',
                                'high_temp',
                                Colors.red,
                                dashboardProvider,
                              ),
                              _buildScenarioButton(
                                context,
                                'Low pH',
                                'low_ph',
                                Colors.orange,
                                dashboardProvider,
                              ),
                              _buildScenarioButton(
                                context,
                                'Low Oxygen',
                                'low_oxygen',
                                Colors.purple,
                                dashboardProvider,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 20),

            // History Testing
            Text(
              'History Chart Testing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            Consumer<HistoryProvider>(
              builder: (context, historyProvider, child) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'History Testing: ${historyProvider.isTestingMode ? "ON" : "OFF"}',
                              style: TextStyle(
                                color: historyProvider.isTestingMode ? Colors.green : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Switch(
                              value: historyProvider.isTestingMode,
                              onChanged: (value) {
                                if (value) {
                                  historyProvider.enableTestingMode();
                                } else {
                                  historyProvider.disableTestingMode();
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enable testing mode untuk history chart dengan mock data 8 AM - 5 PM sesuai requirement dosen.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 20),

            // Fix Overflow Warnings Section
            Text(
              'Responsive Design Testing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Screen Info:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Text('Width: ${MediaQuery.of(context).size.width.toStringAsFixed(0)}px'),
                    Text('Height: ${MediaQuery.of(context).size.height.toStringAsFixed(0)}px'),
                    Text('Is Mobile: ${MediaQuery.of(context).size.width < 800}'),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showResponsiveTestDialog(context);
                      },
                      icon: Icon(Icons.phone_android),
                      label: Text('Test Responsive Layouts'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),

            // ESP32 Integration Status
            Text(
              'ESP32 Integration Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<DashboardProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  provider.isConnected ? Icons.wifi : Icons.wifi_off,
                                  color: provider.isConnected ? Colors.green : Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'MQTT Status: ${provider.isConnected ? "Connected" : "Disconnected"}',
                                  style: TextStyle(
                                    color: provider.isConnected ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Device ID: ${provider.currentDeviceId}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Pond ID: ${provider.currentPondId}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            SizedBox(height: 12),
                            if (!provider.isConnected && !provider.isTestingMode)
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.orange[700]),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'ESP32 tidak terhubung. Gunakan Testing Mode untuk simulasi.',
                                        style: TextStyle(color: Colors.orange[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioButton(
    BuildContext context,
    String label,
    String scenario,
    Color color,
    DashboardProvider provider,
  ) {
    return ElevatedButton(
      onPressed: () {
        provider.loadTestScenario(scenario);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded test scenario: $label'),
            backgroundColor: color,
            duration: Duration(seconds: 2),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label, style: TextStyle(fontSize: 12)),
    );
  }

  void _showResponsiveTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Responsive Design Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Testing Guidelines:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Mobile: < 800px width'),
            Text('• Tablet: 800-1200px width'),
            Text('• Desktop: > 1200px width'),
            SizedBox(height: 12),
            Text('Overflow Fixes Applied:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('✅ Card responsive sizing'),
            Text('✅ Flexible grid layouts'),
            Text('✅ Proper text overflow handling'),
            Text('✅ Chart responsive containers'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}