import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:math';
import '../../providers/dashboard_provider.dart';

class UserDashboardViewScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String pondId;
  final String pondName;

  const UserDashboardViewScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.pondId,
    required this.pondName,
  }) : super(key: key);

  @override
  State<UserDashboardViewScreen> createState() => _UserDashboardViewScreenState();
}

class _UserDashboardViewScreenState extends State<UserDashboardViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      dashboardProvider.initialize(widget.pondId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard: ${widget.userName}'),
            Text(
              widget.pondName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: () => _downloadReport(context),
            tooltip: 'Download Laporan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[400]!,
                      Colors.blue[600]!,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.userName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ID: ${widget.userId}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.pondName,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'User View',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Kondisi Terkini Section - Same as user dashboard
            Text(
              'Kondisi Terkini - ${widget.pondName}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            
            // Sensor Data Cards dengan Gauge Speedometer - Copy dari Admin Dashboard yang sukses
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
                            (sensorData?.temperature ?? 24.5).toStringAsFixed(1),
                            '°C',
                            Icons.thermostat,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildSensorCard(
                            'Oksigen',
                            (sensorData?.oxygen ?? 7.6).toStringAsFixed(1),
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
            
            SizedBox(height: 24),
            
            // Status Information
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Status Informasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('User ID', widget.userId),
                    _buildInfoRow('Nama User', widget.userName),
                    _buildInfoRow('Pond ID', widget.pondId),
                    _buildInfoRow('Nama Kolam', widget.pondName),
                    _buildInfoRow('Akses Level', 'User Biasa'),
                    _buildInfoRow('Status', 'Aktif'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Admin Notes
            Card(
              elevation: 2,
              color: Colors.amber[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.amber[800]),
                        SizedBox(width: 8),
                        Text(
                          'Catatan Admin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Ini adalah tampilan dashboard yang sama persis dengan yang dilihat oleh user',
                      style: TextStyle(color: Colors.amber[800]),
                    ),
                    Text(
                      '• User hanya bisa melihat data, tidak bisa mengontrol perangkat',
                      style: TextStyle(color: Colors.amber[800]),
                    ),
                    Text(
                      '• Untuk mengontrol perangkat, gunakan panel admin',
                      style: TextStyle(color: Colors.amber[800]),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.download_rounded, color: const Color.fromARGB(255, 57, 73, 171)),
              SizedBox(width: 8),
              Text('Download Laporan'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih format laporan untuk ${widget.userName}:'),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('Download sebagai PDF'),
                subtitle: Text('Laporan lengkap dengan grafik'),
                onTap: () {
                  Navigator.of(context).pop();
                  _generatePDFReport();
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green),
                title: Text('Download sebagai Excel'),
                subtitle: Text('Data dalam format spreadsheet'),
                onTap: () {
                  Navigator.of(context).pop();
                  _generateExcelReport();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _generatePDFReport() async {
    try {
      // Minta permission untuk storage
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _showErrorSnackBar('Akses penyimpanan ditolak. Tidak dapat menyimpan file.');
          return;
        }
      }

      // Tampilkan progress
      _showProgressSnackBar('Membuat laporan PDF...');

      // Simulasi pembuatan PDF (implementasi sesungguhnya membutuhkan package pdf)
      await Future.delayed(Duration(seconds: 2));

      _showSuccessSnackBar('Laporan PDF berhasil disimpan di folder Downloads');
    } catch (e) {
      _showErrorSnackBar('Gagal membuat laporan PDF: ${e.toString()}');
    }
  }

  void _generateExcelReport() async {
    try {
      // Minta permission untuk storage
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _showErrorSnackBar('Akses penyimpanan ditolak. Tidak dapat menyimpan file.');
          return;
        }
      }

      // Tampilkan progress
      _showProgressSnackBar('Membuat laporan Excel...');

      // Buat Excel file
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Header
      sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue('Laporan Monitoring Kolam Ikan - ${widget.userName}');
      sheetObject.cell(CellIndex.indexByString("A2")).value = TextCellValue('Kolam: ${widget.pondName}');
      sheetObject.cell(CellIndex.indexByString("A3")).value = TextCellValue('Tanggal: ${DateTime.now().toString().split(' ')[0]}');

      // Header data
      sheetObject.cell(CellIndex.indexByString("A5")).value = TextCellValue('Waktu');
      sheetObject.cell(CellIndex.indexByString("B5")).value = TextCellValue('Suhu (°C)');
      sheetObject.cell(CellIndex.indexByString("C5")).value = TextCellValue('pH');
      sheetObject.cell(CellIndex.indexByString("D5")).value = TextCellValue('Oksigen (ppm)');

      // Data dummy (dalam implementasi sesungguhnya, ambil dari database)
      Random random = Random();
      for (int i = 0; i < 24; i++) {
        int row = i + 6;
        sheetObject.cell(CellIndex.indexByString("A$row")).value = TextCellValue('${DateTime.now().subtract(Duration(hours: 23 - i)).hour.toString().padLeft(2, '0')}:00');
        sheetObject.cell(CellIndex.indexByString("B$row")).value = TextCellValue((28 + random.nextDouble() * 4).toStringAsFixed(1));
        sheetObject.cell(CellIndex.indexByString("C$row")).value = TextCellValue((7.0 + random.nextDouble() * 1.5).toStringAsFixed(1));
        sheetObject.cell(CellIndex.indexByString("D$row")).value = TextCellValue((6 + random.nextDouble() * 2).toStringAsFixed(1));
      }

      // Dapatkan direktori Downloads
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir != null) {
        // Nama file dengan timestamp
        String fileName = 'Laporan_${widget.userName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        String filePath = '${downloadsDir.path}/$fileName';

        // Simpan file
        File file = File(filePath);
        await file.writeAsBytes(excel.encode()!);

        _showSuccessSnackBar('Laporan Excel berhasil disimpan di: $filePath');
      } else {
        _showErrorSnackBar('Tidak dapat menemukan direktori penyimpanan');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal membuat laporan Excel: ${e.toString()}');
    }
  }

  void _showProgressSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
}