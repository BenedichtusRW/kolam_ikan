import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'dart:io';
// ...existing imports...
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/history_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/mock_data_generator.dart';
import '../../models/sensor_data.dart';
import '../admin/user_list_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;
  String _selectedChartType = 'temperature'; // Default chart type
  final Color _primaryColor = const Color.fromARGB(255, 57, 73, 171);
  // Admin controls
  List<String> _availablePonds = ['pond_001', 'pond_002', 'pond_003'];
  String _selectedPondForAdmin = 'pond_001';
  static const String _allPondsKey = 'ALL_PONDS';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Enable testing mode so selecting a date returns mock data for development/demo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
      historyProvider.enableTestingMode();
    });
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
        // normal user: fetch their pond
        await historyProvider.fetchHistoryData(
          picked, 
          authProvider.userProfile!.pondId!
        );
      } else {
        // No authenticated pondId available (development/test).
        // If admin view and selected pond is specific, load that; otherwise load default mock.
        await historyProvider.fetchMockHistoryData(picked, _selectedPondForAdmin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.userProfile?.isAdmin ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Data'),
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
        foregroundColor: Colors.white,
        actions: [
          // Export button - enabled when there is data OR if admin wants to view all users
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, child) {
              // If admin selected 'All Ponds', pressing download should open the user list view
              final authProviderLocal = Provider.of<AuthProvider>(context, listen: false);
              final isAdminLocal = authProviderLocal.userProfile?.isAdmin ?? false;
              final isAllPondsSelected = isAdminLocal && _selectedPondForAdmin == _allPondsKey;

              return IconButton(
                icon: Icon(Icons.download_rounded),
                onPressed: isAllPondsSelected
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserListScreen()),
                        );
                      }
                    : (historyProvider.historyData.isNotEmpty ? () => _showExportDialog(historyProvider) : null),
                tooltip: isAllPondsSelected ? 'Lihat semua user' : 'Export laporan',
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin pond selector
                if (isAdmin)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.pool, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('Pilih Kolam (Admin):', style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _selectedPondForAdmin,
                            items: [
                              ..._availablePonds.map((p) => DropdownMenuItem(value: p, child: Text(p))),
                              DropdownMenuItem(value: _allPondsKey, child: Text('Semua Kolam')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedPondForAdmin = v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                // If admin selected 'All Ponds', show all ponds' charts and allow per-pond download
                if (isAdmin && _selectedPondForAdmin == _allPondsKey)
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availablePonds.length,
                      itemBuilder: (context, index) {
                        final pid = _availablePonds[index];
                        final mockData = MockDataGenerator.generateDailyMockData(date: _selectedDate ?? DateTime.now(), pondId: pid, dataPointsPerHour: 6);
                        // calculate small stats
                        double avgTemp = 0;
                        double avgOxy = 0;
                        if (mockData.isNotEmpty) {
                          avgTemp = mockData.map((m) => m.temperature).reduce((a, b) => a + b) / mockData.length;
                          avgOxy = mockData.map((m) => m.oxygen).reduce((a, b) => a + b) / mockData.length;
                        }

                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Kolam: $pid', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                                          tooltip: 'Download PDF untuk $pid',
                                          onPressed: () => _generatePDFReport(historyProvider, pondIdsOverride: [pid]),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.table_chart, color: Colors.green),
                                          tooltip: 'Download Excel untuk $pid',
                                          onPressed: () => _generateExcelReport(historyProvider, pondIdsOverride: [pid]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 180,
                                  child: _miniChartForData(mockData, _primaryColor, 'Suhu', 'temperature'),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: Text('Suhu rata-rata: ${avgTemp.toStringAsFixed(1)}°C')),
                                    Expanded(child: Text('Oksigen rata-rata: ${avgOxy.toStringAsFixed(1)} ppm')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                                  _primaryColor,
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

  void _showExportDialog(HistoryProvider historyProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.download_rounded, color: const Color.fromARGB(255, 57, 73, 171)),
              SizedBox(width: 8),
              Text('Export Laporan'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('Export sebagai PDF'),
                onTap: () {
                  Navigator.of(context).pop();
                  _generatePDFReport(historyProvider);
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green),
                title: Text('Export sebagai Excel'),
                onTap: () {
                  Navigator.of(context).pop();
                  _generateExcelReport(historyProvider);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
          ],
        );
      },
    );
  }

  Future<void> _generatePDFReport(HistoryProvider provider, {List<String>? pondIdsOverride}) async {
    try {
      _showProgressSnackBar('Membuat laporan PDF...');

      // Simple text-based PDF placeholder
      final buffer = StringBuffer();
      buffer.writeln('Laporan Riwayat - ${_formatDate(_selectedDate ?? DateTime.now())}');
      buffer.writeln('Kolam: ${provider.historyData.isNotEmpty ? provider.historyData.first.pondId : ''}');
      buffer.writeln('User: -');
      buffer.writeln('');
      buffer.writeln('Waktu,Suhu,pH,Oksigen');
      for (final d in provider.historyData) {
        buffer.writeln('${d.timestamp.toIso8601String()},${d.temperature.toStringAsFixed(2)},${d.phLevel.toStringAsFixed(2)},${d.oxygen.toStringAsFixed(2)}');
      }

      // Determine pond scope
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<String> pondIdsToExport;
      if (pondIdsOverride != null) {
        pondIdsToExport = pondIdsOverride;
      } else if (authProvider.userProfile?.isAdmin ?? false && _selectedPondForAdmin == _allPondsKey) {
        pondIdsToExport = _availablePonds;
      } else {
        final scopePondId = authProvider.userProfile?.pondId ?? _selectedPondForAdmin;
        pondIdsToExport = [scopePondId];
      }

      // If provider.historyData is empty or we're exporting 'all', build CSV-like content from mock data
      String content;
      if (pondIdsToExport.length > 1 || provider.historyData.isEmpty) {
        final sb = StringBuffer();
        sb.writeln('Laporan Riwayat Gabungan - ${_formatDate(_selectedDate ?? DateTime.now())}');
        for (final pid in pondIdsToExport) {
          final mock = MockDataGenerator.generateDailyMockData(date: _selectedDate ?? DateTime.now(), pondId: pid, dataPointsPerHour: 6);
          sb.writeln('\nKolam: $pid');
          sb.writeln('Waktu,Suhu,pH,Oksigen');
          for (final d in mock) {
            sb.writeln('${d.timestamp.toIso8601String()},${d.temperature.toStringAsFixed(2)},${d.phLevel.toStringAsFixed(2)},${d.oxygen.toStringAsFixed(2)}');
          }
        }
        content = sb.toString();
      } else {
        content = buffer.toString();
      }

      final Uint8List bytes = Uint8List.fromList(utf8.encode(content));
      final String fileName = 'Laporan_History_${(_selectedDate ?? DateTime.now()).millisecondsSinceEpoch}.pdf';
      final saved = await _saveFileBytes(bytes, fileName);

      if (saved != null) {
        _showSuccessSnackBarWithAction('Laporan PDF disimpan: $saved', 'Copy path', () {
          Clipboard.setData(ClipboardData(text: saved));
        });
      } else {
        _showErrorSnackBar('Gagal menyimpan PDF. Periksa izin penyimpanan.');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal membuat PDF: ${e.toString()}');
    }
  }

  Future<void> _generateExcelReport(HistoryProvider provider, {List<String>? pondIdsOverride}) async {
    try {
      _showProgressSnackBar('Membuat laporan Excel...');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<String> pondIdsToExport;
      if (pondIdsOverride != null) {
        pondIdsToExport = pondIdsOverride;
      } else if (authProvider.userProfile?.isAdmin ?? false && _selectedPondForAdmin == _allPondsKey) {
        pondIdsToExport = _availablePonds;
      } else if (authProvider.userProfile?.isAdmin ?? false) {
        pondIdsToExport = [_selectedPondForAdmin];
      } else {
        pondIdsToExport = [authProvider.userProfile?.pondId ?? 'pond_001'];
      }

      var excel = excel_pkg.Excel.createExcel();
      for (final pid in pondIdsToExport) {
        final sheetName = pondIdsToExport.length == 1 ? 'Sheet1' : 'Pond_$pid';
        excel_pkg.Sheet sheet = excel[sheetName];

        sheet.cell(excel_pkg.CellIndex.indexByString('A1')).value = excel_pkg.TextCellValue('Laporan Riwayat - $pid');
        sheet.cell(excel_pkg.CellIndex.indexByString('A2')).value = excel_pkg.TextCellValue('Tanggal: ${_formatDate(_selectedDate ?? DateTime.now())}');
        sheet.cell(excel_pkg.CellIndex.indexByString('A4')).value = excel_pkg.TextCellValue('Waktu');
        sheet.cell(excel_pkg.CellIndex.indexByString('B4')).value = excel_pkg.TextCellValue('Suhu (°C)');
        sheet.cell(excel_pkg.CellIndex.indexByString('C4')).value = excel_pkg.TextCellValue('pH');
        sheet.cell(excel_pkg.CellIndex.indexByString('D4')).value = excel_pkg.TextCellValue('Oksigen');

        List<SensorData> dataList;
        if (provider.historyData.isNotEmpty && pondIdsToExport.length == 1) {
          dataList = provider.historyData;
        } else {
          dataList = MockDataGenerator.generateDailyMockData(date: _selectedDate ?? DateTime.now(), pondId: pid, dataPointsPerHour: 6);
        }

        for (int i = 0; i < dataList.length; i++) {
          final row = i + 5;
          final d = dataList[i];
          sheet.cell(excel_pkg.CellIndex.indexByString('A$row')).value = excel_pkg.TextCellValue(d.timestamp.toIso8601String());
          sheet.cell(excel_pkg.CellIndex.indexByString('B$row')).value = excel_pkg.TextCellValue(d.temperature.toStringAsFixed(2));
          sheet.cell(excel_pkg.CellIndex.indexByString('C$row')).value = excel_pkg.TextCellValue(d.phLevel.toStringAsFixed(2));
          sheet.cell(excel_pkg.CellIndex.indexByString('D$row')).value = excel_pkg.TextCellValue(d.oxygen.toStringAsFixed(2));
  }
      }

      final List<int>? encoded = excel.encode();
      if (encoded == null) {
        _showErrorSnackBar('Gagal encode Excel');
        return;
      }

      final bytes = Uint8List.fromList(encoded);
      final fileName = 'Laporan_History_${(_selectedDate ?? DateTime.now()).millisecondsSinceEpoch}.xlsx';
      final saved = await _saveFileBytes(bytes, fileName);
      if (saved != null) {
        _showSuccessSnackBarWithAction('Laporan Excel disimpan: $saved', 'Copy path', () {
          Clipboard.setData(ClipboardData(text: saved));
        });
      } else {
        _showErrorSnackBar('Gagal menyimpan Excel. Periksa izin penyimpanan.');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal membuat Excel: ${e.toString()}');
    }
  }

  Future<String?> _saveFileBytes(Uint8List bytes, String fileName) async {
    try {
      // Try to write to Downloads on Android (request permission)
      if (Platform.isAndroid) {
        bool canWrite = false;
        try {
          if (await Permission.storage.isGranted) canWrite = true;
          else {
            final status = await Permission.storage.request();
            if (status.isGranted) canWrite = true;
            else {
              final mgr = await Permission.manageExternalStorage.request();
              if (mgr.isGranted) canWrite = true;
            }
          }
        } catch (_) {
          canWrite = false;
        }

        if (canWrite) {
          try {
            final downloads = Directory('/storage/emulated/0/Download');
            Directory? target = downloads;
            if (!await downloads.exists()) {
              target = await getExternalStorageDirectory();
            }
            if (target != null) {
              final file = File('${target.path}/$fileName');
              await file.writeAsBytes(bytes);
              return file.path;
            }
          } catch (e) {
            // fallback below
          }
        }
      }

      // Fallback: save to app documents
      final appDoc = await getApplicationDocumentsDirectory();
      final file = File('${appDoc.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  void _showSuccessSnackBarWithAction(String message, String actionLabel, VoidCallback onAction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: actionLabel, onPressed: onAction),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 6),
      ),
    );
  }

  void _showProgressSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
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

  // Small helper to render a compact line chart for mini previews
  Widget _miniChartForData(List<SensorData> data, Color color, String label, String chartType) {
    if (data.isEmpty) {
      return Center(child: Text('No data', style: TextStyle(color: Colors.grey[600])));
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final x = i.toDouble();
      double y;
      switch (chartType) {
        case 'ph':
          y = d.phLevel;
          break;
        case 'oxygen':
          y = d.oxygen;
          break;
        default:
          y = d.temperature;
      }
      spots.add(FlSpot(x, y));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.length > 1 ? (data.length - 1).toDouble() : 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          )
        ],
      ),
    );
  }