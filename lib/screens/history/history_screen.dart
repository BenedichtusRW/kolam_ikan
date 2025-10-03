import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/auth_provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: Locale('id', 'ID'), // Indonesian locale
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      // Fetch data untuk tanggal yang dipilih
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
      
      if (authProvider.userProfile?.pondId != null) {
        await historyProvider.fetchHistoryData(
          picked, 
          authProvider.userProfile!.pondId!
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Data'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date selector
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.indigo[600],
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih Tanggal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _selectedDate != null 
                                  ? _formatDate(_selectedDate!)
                                  : 'Belum dipilih',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _selectDate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Pilih'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Loading state
                if (historyProvider.isLoading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.indigo[600]),
                          ),
                          SizedBox(height: 16),
                          Text('Memuat data riwayat...'),
                        ],
                      ),
                    ),
                  )
                
                // Error state
                else if (historyProvider.errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            historyProvider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              historyProvider.clearError();
                              if (_selectedDate != null) {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                if (authProvider.userProfile?.pondId != null) {
                                  historyProvider.fetchHistoryData(
                                    _selectedDate!, 
                                    authProvider.userProfile!.pondId!
                                  );
                                }
                              }
                            },
                            child: Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                
                // Data display
                else if (historyProvider.historyData.isEmpty && _selectedDate != null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tidak ada data untuk tanggal yang dipilih',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                
                // Content with data
                else if (historyProvider.historyData.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Statistics summary
                          Text(
                            'Ringkasan Statistik',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Suhu Rata-rata',
                                  '${historyProvider.avgTemperature.toStringAsFixed(1)}°C',
                                  Icons.thermostat,
                                  Colors.blue,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard(
                                  'Oksigen Rata-rata',
                                  '${historyProvider.avgOxygen.toStringAsFixed(1)} ppm',
                                  Icons.air,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Suhu Min/Max',
                                  '${historyProvider.minTemperature.toStringAsFixed(1)}° / ${historyProvider.maxTemperature.toStringAsFixed(1)}°',
                                  Icons.trending_up,
                                  Colors.orange,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard(
                                  'O₂ Min/Max',
                                  '${historyProvider.minOxygen.toStringAsFixed(1)} / ${historyProvider.maxOxygen.toStringAsFixed(1)}',
                                  Icons.trending_up,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Chart placeholder
                          Text(
                            'Grafik Tren',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),

                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              height: 250,
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
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
                                            SizedBox(height: 4),
                                            Text(
                                              '${historyProvider.historyData.length} data points',
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                
                // Initial state
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Pilih tanggal untuk melihat riwayat',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // TODO: Use intl package for better localization
    List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}