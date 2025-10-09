import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/history_provider.dart';
import '../../providers/auth_provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;
  String _selectedChartType = 'temperature'; // Default chart type

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
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
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
                          color: const Color.fromARGB(255, 57, 73, 171),
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
                            backgroundColor: const Color.fromARGB(255, 57, 73, 171),
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
                            valueColor: AlwaysStoppedAnimation(const Color.fromARGB(255, 57, 73, 171)),
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

                          // Grafik Tren Data Historis sesuai requirement dosen
                          Text(
                            'Grafik Tren Data Historis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),

                          // Chart dengan fl_chart - implementasi sesuai requirement dosen
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              height: 300,
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Chart selector tabs
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildChartTab('Suhu', _selectedChartType == 'temperature'),
                                        _buildChartTab('pH', _selectedChartType == 'ph'),
                                        _buildChartTab('Oksigen', _selectedChartType == 'oxygen'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  
                                  // Chart area
                                  Expanded(
                                    child: historyProvider.historyData.isNotEmpty 
                                      ? _buildLineChart(historyProvider)
                                      : Container(
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
                                                  'Pilih tanggal untuk melihat grafik',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
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

  // Method untuk membuat tab selector chart
  Widget _buildChartTab(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            switch (label) {
              case 'Suhu':
                _selectedChartType = 'temperature';
                break;
              case 'pH':
                _selectedChartType = 'ph';
                break;
              case 'Oksigen':
                _selectedChartType = 'oxygen';
                break;
            }
          });
        },
        child: Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromARGB(255, 57, 73, 171) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method untuk membuat line chart dengan fl_chart
  Widget _buildLineChart(HistoryProvider provider) {
    if (provider.historyData.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data untuk ditampilkan',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Prepare data points based on selected chart type
    List<FlSpot> spots = [];
    Color lineColor = Colors.blue;
    String yAxisLabel = '';
    double minY = 0, maxY = 100;

    switch (_selectedChartType) {
      case 'temperature':
        lineColor = Colors.orange;
        yAxisLabel = '°C';
        minY = 20;
        maxY = 35;
        for (int i = 0; i < provider.historyData.length; i++) {
          final data = provider.historyData[i];
          final hour = data.timestamp.hour + (data.timestamp.minute / 60.0);
          spots.add(FlSpot(hour, data.temperature));
        }
        break;
      case 'ph':
        lineColor = const Color.fromARGB(255, 57, 73, 171);
        yAxisLabel = 'pH';
        minY = 6.0;
        maxY = 8.5;
        for (int i = 0; i < provider.historyData.length; i++) {
          final data = provider.historyData[i];
          final hour = data.timestamp.hour + (data.timestamp.minute / 60.0);
          spots.add(FlSpot(hour, data.phLevel));
        }
        break;
      case 'oxygen':
        lineColor = Colors.green;
        yAxisLabel = 'mg/L';
        minY = 0;
        maxY = 15;
        for (int i = 0; i < provider.historyData.length; i++) {
          final data = provider.historyData[i];
          final hour = data.timestamp.hour + (data.timestamp.minute / 60.0);
          spots.add(FlSpot(hour, data.oxygen));
        }
        break;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (double value, TitleMeta meta) {
                final hour = value.toInt();
                if (hour >= 8 && hour <= 17) {
                  return Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        minX: 8, // 8 AM
        maxX: 17, // 5 PM
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: lineColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final hour = flSpot.x.toInt();
                final minute = ((flSpot.x - hour) * 60).toInt();
                return LineTooltipItem(
                  '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}\n${flSpot.y.toStringAsFixed(2)} $yAxisLabel',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}